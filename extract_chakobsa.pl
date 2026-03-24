use strict;
use warnings;
use utf8;
use JSON::PP;
use v5.30;

my $json = JSON::PP->new->utf8->pretty;

my @files = ('scripts/raw/master_dune_diaglogue.txt', 'scripts/raw/master_dune2_dialogue.txt');

my @chakobsa;

foreach my $f (@files) {
    say STDERR "Processing $f";
    open my $in, '<', $f or die "$!\n";
    my $number = $f =~ /dune2/ ? 2 : 1;
    my $entry;
    my $state = 'seeking_next_entry';

    while( <$in> ) {
        chomp;
        next if $_ eq '';
        next if /^-----/;

        s/\x{2019}/'/g;

        if( /TRANSLATION/ ) {
            $state = 'reading_translation';
            next;
        }

        if( /PHONETIC/ ) {
            $state = 'reading_phonetic';
            next;
        }

        if( $state eq 'reading_translation' ) {
            $entry->{translation} = $_;
            $state = '';
            next;
        }

        if( $state eq 'reading_phonetic' ) {
            $entry->{phonetic} = $_;
            $state = 'reading_transliteration';
            next;
        }

        if( $state eq 'reading_transliteration' ) {
            $entry->{transliteration} = $_;
            push @chakobsa, $entry if valid($entry);
            $entry = { d => $number, line => $. };
            $state = 'seeking_next_entry';
            next;
        }

        if( $state eq 'seeking_next_entry') {
            next;
        }
    }

    push @chakobsa, $entry if $entry;
}

say $json->encode(\@chakobsa);

sub valid {
    my ($entry) = @_;
    return undef if $entry->{translation} eq '(Please see video.)';
    return undef if $entry->{translation} eq 'N/A';
    return undef if $entry->{transliteration} eq 'Literal translation.';
    return 1;
}

__END__

GROUP
Do you really think he is the One?
TRANSLATION
Vii minaazashaho vejii ho Chausij?
PHONETIC
vii mi-NAA-za-sha-ho ve-JII ho CHAU-sij?
Do you-think-it truly (that) he (is) the-One?
------------------------------------------------------------------(GROUP_DUNE_23.mp3)
GROUP
Liet favors him.
TRANSLATION
Yazaalahao Liiyet.
PHONETIC
ya-ZAA-la-ha-o LII-yet.
He-favors-him Liet.
------------------------------------------------------------------(GROUP_DUNE_24.mp3)
GROUP
He looks young to me.
TRANSLATION
Azaagahayi ho ludhii.
PHONETIC
a-ZAA-ga-ha-yi ho lu-DHII.
It-appears-to-me (that) he is-young.
