use strict;
use warnings;
use utf8;
use JSON::PP;
use Text::Unidecode;
use v5.40;

my $json = JSON::PP->new->utf8->pretty->canonical;

my @files = ('text/raw/master_dune_diaglogue.txt', 'text/raw/master_dune2_dialogue.txt');

my @chakobsa;

foreach my $f (@files) {
    say STDERR "Processing $f";
    open my $in, '<', $f or die "$!\n";
    my $number = $f =~ /dune2/ ? 2 : 1;
    my $entry;
    my $state = 'seeking_next_entry';

    my $ctr = 0;
    while( <$in> ) {
        $ctr++;
        # exit(0) if $ctr > 100;
        chomp;
        $_ = unidecode($_);
        next if $_ eq '';

        say STDERR "$state: $_";

        if( /TRANSLATION/ ) {
            $state = 'reading_translation';
            $entry = { line => $number . '/' . $. };
            next;
        }

        if( /PHONETIC/ ) {
            $state = 'reading_phonetic';
            next;
        }

        if( /^-----/ ) {
            say STDERR " ** pushing entry";
            push @chakobsa, $entry if valid($entry);
            $state = 'seeking_next_entry';
            next;
        }

        if( $state eq 'reading_translation' ) {
            $entry->{translation} .= trim(' ' . $_);
            next;
        }

        if( $state eq 'reading_phonetic' ) {
            $entry->{phonetic} .= trim(' ' . $_);
            next;
        }

        if( $state eq 'reading_transliteration' ) {
            $entry->{transliteration} .= trim(' ' . $_);
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
