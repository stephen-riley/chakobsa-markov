use strict;
use warnings;
use utf8;
use JSON::PP;
use Lingua::EN::Tagger;
use v5.30;

my $p = new Lingua::EN::Tagger( relax => 0 );

while( <DATA> ) {
    chomp;
    my @words = grep { $_ !~ /\(|\)/ } split( /\s+/, $_ );
    foreach my $w ( @words ) {
        my @phrases = split( "-", $w );
        foreach my $ph ( @phrases ) {
            my $tagged = $p->get_readable( $ph );
            say $tagged . " ";
        }
    }
    print "\n";
}

__DATA__
it was written.
it-was-written.
Bring-me drop of-Water of-Life.
Do you-think-it truly (that) he (is) the-Mahdi?