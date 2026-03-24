use strict;
use warnings;
use utf8;
use JSON::PP;
use v5.30;

my $json = JSON::PP->new->utf8->pretty->canonical;

my $json_file = 'scripts/chakobsa.json';
my $dict_file = 'scripts/chakobsa_dictionary.json';

open my $fh, '<:encoding(UTF-8)', $json_file or die "Cannot open $json_file: $!";
my $data = decode_json(do { local $/; <$fh> });
close $fh;

my %dictionary;

foreach my $entry (@$data) {
    # We want to match the phonetic spelling to the transliteration.
    # After removing (implied words/phrases) from transliteration, there should be a one-to-one mapping between words.

    my $transliteration = $entry->{transliteration} 
                            =~ s/[\.",!?]//gr
                            =~ s/--/ /gr;
    my $phonetic = lc($entry->{phonetic}) 
                            =~ s/[\.",!?]//gr
                            =~ s/--/ /gr;
    
    # Remove implied words/phrases from transliteration.
    $transliteration =~ s/\(.*?\)//g;
    
    # Split transliteration into words
    my @transliteration_words = grep { $_ } split /\s+/, $transliteration;
    my @phonetic_words = grep { $_ } split /\s+/, $phonetic;

    if( $#transliteration_words != $#phonetic_words ) {
        say STDERR "Line " . $entry->{line} . " has different number of words in transliteration and phonetic spelling.";
        say STDERR " Transliteration: " . join( ' ', map { "[$_]" } @transliteration_words);
        say STDERR " Phonetic: " . join( ' ', map { "[$_]" } @phonetic_words);
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
        $dictionary{$key} = $word_pairs{$key};
    }
}

say $json->encode(\%dictionary);
