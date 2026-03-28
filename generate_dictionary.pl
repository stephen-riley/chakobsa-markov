use strict;
use warnings;
use utf8;
use JSON::PP;
use v5.30;

my $json = JSON::PP->new->utf8->pretty->canonical;

my $json_file = 'text/chakobsa.json';
my $dict_file = 'text/chakobsa_dictionary.json';

open my $fh, '<:encoding(UTF-8)', $json_file or die "Cannot open $json_file: $!";
my $data = decode_json(do { local $/; <$fh> });
close $fh;

my %dictionary;

foreach my $entry (@$data) {
    # We want to match the phonetic spelling to the transliteration.
    # After removing (implied words/phrases) from transliteration, there should be a one-to-one mapping between words.

    my $transliteration = lc($entry->{translation_english}) 
                            =~ s/[\.",!?]//gr
                            =~ s/--/ /gr;
    my $phonetic = lc($entry->{phonetic_transcription}) 
                            =~ s/[\.",!?]//gr
                            =~ s/--/ /gr;
    
    # Remove implied words/phrases from transliteration.
    $transliteration =~ s/\(.*?\)//g;
    
    # Split transliteration into words
    my @transliteration_words = grep { $_ } split /\s+/, $transliteration;
    my @phonetic_words = grep { $_ } split /\s+/, $phonetic;

    if( $#transliteration_words != $#phonetic_words ) {
        say STDERR "Scene " . $entry->{scene} . " has different number of words in transliteration and phonetic spelling.";
        say_arrays_vertically( \@phonetic_words, \@transliteration_words );
        say STDERR "";
        exit( -1 );
        next;
    }

    # Zip the two arrays together
    my %word_pairs;
    for my $i (0 .. $#transliteration_words) {
        $word_pairs{$phonetic_words[$i]} = $transliteration_words[$i];
    }

    foreach my $key (sort keys %word_pairs) {
        # Skip empty words
        next unless $key;
        
        # Store translation
        if( exists( $dictionary{$key} ) ) {
            $dictionary{$key}{count}++;
        } else {
            my $w = $word_pairs{$key};
            my $c = $key =~ s/-//gr;
            $dictionary{$key} = { chakobsa => $c, word => $w, count => 1, phonetic => $key };
        }
    }
}

say $json->encode(\%dictionary);

sub say_arrays_vertically {
    my( $a1, $a2 ) = @_;
    my $count = scalar( @$a1 ) >= scalar( @$a2 ) ? scalar( @$a1 ) : scalar( @$a2 );
    for my $i (0 .. $count - 1) {
        my $a = $a1->[$i] // "";
        my $b = $a2->[$i] // "";
        say STDERR sprintf( "%-20s : %-20s", $a, $b );
    }
}
