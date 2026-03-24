#!/usr/bin/perl

# extract_chakobsa.pl
# 
# This script extracts Chakobsa language data from raw text scripts.
# It processes all files in scripts/raw/ and outputs a single JSON file
# to scripts/chakobsa.json.
#
# Requirements:
# - Perl 5.30+
# - JSON::PP (Standard module)
#
# Usage: perl extract_chakobsa.pl

use strict;
use warnings;
use utf8;
use JSON::PP;
use File::Spec;

# Set encoding for output to handle special characters correctly
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# Configuration
my $raw_dir     = 'scripts/raw';
my $output_file = 'scripts/chakobsa.json';

my @all_data;
my $current_scene = 'Unknown';

# Locate files to process
my @files = (
    File::Spec->catfile($raw_dir, 'master_dune_diaglogue.txt'),
    File::Spec->catfile($raw_dir, 'master_dune2_dialogue.txt')
);

# Process each file
foreach my $file (@files) {
    if (!-e $file) {
        warn "Warning: File not found: $file\n";
        next;
    }

    print "Processing $file...\n";
    open my $fh, "<:encoding(UTF-8)", $file or die "Could not open $file: $!";
    my $content = do { local $/; <$fh> };
    close $fh;

    # Normalize line endings
    $content =~ s/\r\n/\n/g;

    # Pre-clean page-break markings that span multiple lines.
    # These typically look like a Form Feed followed by repeated headers and scene numbers.
    $content =~ s/\f.*?\n\s*\d+\.\s*\n//gs;

    # Split the file by the dashed separator line into logical blocks
    my @blocks = split(/^-{10,}/m, $content);

    foreach my $block (@blocks) {
        next if $block =~ /^\s*$/;

        # Extraction of scene number from separator line or first line of block
        if ($block =~ s/^\s*(\(?[A-Z0-9_\.]+\)?)\s*\n//) {
            my $marker = $1;
            # Check if this marker is a scene number or code (digits or ADR/BG/etc)
            if ($marker =~ /^\d+[A-Z]?$/ || $marker =~ /^(ADR|BG)$/) {
                $current_scene = $marker;
            }
        }

        # Clean "Junk" from the block to simplify parsing
        $block = clean_junk($block, \$current_scene);

        # Parse specific dialogue data from the cleaned block
        parse_block($block, $current_scene, \@all_data);
    }
}

# Encode all gathered data into a pretty-printed JSON file
my $json_coder = JSON::PP->new->utf8(0)->pretty->canonical;
my $json_text  = $json_coder->encode(\@all_data);

open my $out, ">:encoding(UTF-8)", $output_file or die "Could not open $output_file: $!";
print $out $json_text;
close $out;

print "Successfully extracted " . scalar(@all_data) . " entries to $output_file\n";

# --- Helper Functions ---

# Removes headers, footers, and repeated markings found in the source scripts
sub clean_junk {
    my ($text, $scene_ref) = @_;
    my @lines = split(/\n/, $text);
    my @clean;

    foreach my $line (@lines) {
        $line =~ s/^\s+|\s+$//g;
        next if $line eq "";
        
        # Skip labels and page headers
        next if $line =~ /^(Dune|DUNE 2|Dune: Part Two)$/i;
        next if $line =~ /^Language Translations$/i;
        next if $line =~ /^David J. Peterson/i;
        next if $line =~ /^Jessie Sams/i;
        next if $line =~ /^Revised \d/i;
        next if $line =~ /^\d{1,2}\/\d{1,2}\/\d{2}$/; # Dates like 09/27/20
        next if $line =~ /^\d+\.$/;                   # Page numbers like 1.
        next if $line =~ /^CONTINUED:/i;
        next if $line =~ /^\(CONTINUED\)$/i;
        next if $line =~ /^\*+$/;                     # Asterisk separators
        next if $line =~ /^(INT\.|EXT\.).*$/;         # Scene location headers
        next if $line =~ /^\([^\)]+\.mp[34]\)$/;      # Audio filenames
        
        # Detect scene numbers found standing alone in blocks
        if ($line =~ /^(\d+[A-Z]?)$/ || $line =~ /^(ADR|BG)$/) {
            $$scene_ref = $1;
            next;
        }

        push @clean, $line;
    }
    return join("\n", @clean);
}

# State-based parser for extracting character, dialogue, and translations
sub parse_block {
    my ($text, $scene, $data_ref) = @_;
    
    my @lines = split(/\n/, $text);
    my $i = 0;
    while ($i < @lines) {
        my $line = $lines[$i];

        # Look for Character Name (ALL CAPS)
        # We screen out keywords and location-like words to avoid false positives
        if ($line =~ /^[A-Z][A-Z\s’'\-\.\(\)]+$/ && 
            length($line) < 40 &&
            $line !~ /^(TRANSLATION|PHONETIC|KEY|CHARACTER NAME|CONTINUED|N\/A|ADR|BG|DUNE|INT\.|EXT\.|POSTPRODUCTION|VOICE COMMANDS|WALLAH|DUNE 2)$/ &&
            $line !~ /(HALL|ROOM|LANDSCAPE|MOMENT|DAY|NIGHT|DESERT|SIETCH|BASIN|CORRIDOR)/) {
            
            my $char = $line;
            # Cleanup common name suffixes like (CONT'D)
            $char =~ s/\s+\(CONT’D\)$//;
            $char =~ s/\s+\(O\.S\.\)$//;
            $char =~ s/\s+\(V\.O\.\)$//;

            $i++;
            
            # 1. Collect English Dialogue (lines until "TRANSLATION" keyword)
            my @english;
            while ($i < @lines && $lines[$i] !~ /^TRANSLATION$/) {
                # Ensure we don't accidentally capture the PHONETIC keyword
                last if $lines[$i] =~ /^PHONETIC$/;
                push @english, $lines[$i] unless $lines[$i] =~ /^CONTINUED/i;
                $i++;
            }
            
            # 2. Collect Chakobsa Translation (lines until "PHONETIC" keyword)
            if ($i < @lines && $lines[$i] =~ /^TRANSLATION$/) {
                $i++;
                my @chakobsa;
                while ($i < @lines && $lines[$i] !~ /^PHONETIC$/) {
                    push @chakobsa, $lines[$i] unless $lines[$i] =~ /^CONTINUED/i;
                    $i++;
                }
                
                # 3. Collect Phonetic transcription and English translation of Chakobsa
                if ($i < @lines && $lines[$i] =~ /^PHONETIC$/) {
                    $i++;
                    my @phonetic;
                    my @literal;
                    
                    # Heuristic: Phonetic lines and Literal lines were often originally written 1:1.
                    # However, we detect the transition based on content (Literal contains English words).
                    while ($i < @lines) {
                        # Break if we hit a new character name
                        last if $lines[$i] =~ /^[A-Z][A-Z\s]+$/ && length($lines[$i]) < 40 && $lines[$i] !~ /-/;
                        last if $lines[$i] =~ /^TRANSLATION$/;
                        
                        my $curr = $lines[$i];
                        if (is_literal_line($curr) && @phonetic) {
                            # Transition to Literal section
                            while ($i < @lines && $lines[$i] !~ /^[A-Z][A-Z\s]+$/) {
                                push @literal, $lines[$i] unless $lines[$i] =~ /^CONTINUED/i;
                                $i++;
                            }
                            last;
                        } else {
                            push @phonetic, $curr;
                        }
                        $i++;
                    }
                    
                    # Final string preparation
                    my $engl_str = trim_space(join(' ', @english));
                    my $chak_str = trim_space(join(' ', @chakobsa));
                    my $phon_str = trim_space(join(' ', @phonetic));
                    my $lit_str  = trim_space(join(' ', @literal));

                    # Replace U+2019 curly apostrophes with standard ones as per follow-up request
                    foreach my $str (\$engl_str, \$chak_str, \$phon_str, \$lit_str, \$char) {
                        $$str =~ s/\x{2019}/'/g;
                    }

                    # Skip entries where English dialogue contains "(Please see video.)"
                    if ($chak_str !~ /\(Please see video\.\)/i && $chak_str ne "N/A" && $char ne "SARDAUKAR PRIEST") {
                        push @$data_ref, {
                            scene => $scene,
                            character => $char,
                            english_dialogue => $engl_str,
                            chakobsa_translation => $chak_str,
                            phonetic_transcription => $phon_str,
                            translation_english => $lit_str
                        };
                    }
                }
            }
        }
        $i++;
    }
}

# Heuristic to distinguish English literal translation from Phonetic transcription
sub is_literal_line {
    my $line = shift;
    
    # Check for common English functional words that don't appear in Phonetic syllables
    return 1 if $line =~ /\b(is|the|to|with|in|and|your|my|our|will|be|from|for|he|she|they|them|has|been|that|those|there|these|until|word|promise|fates|countenance)\b/i;
    # Check for leading parentheses common in literal translations like "(It is)"
    return 1 if $line =~ /^\(/;
    
    return 0;
}

# Utility to trim whitespace from both ends of a string
sub trim_space {
    my $str = shift;
    $str =~ s/^\s+|\s+$//g;
    return $str;
}
