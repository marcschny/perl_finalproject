use v5.32;
use strict;
use warnings;
use experimental ('signatures');

#############################################
#   This file creates the empty exam file   #
#   from a master file                      #
#############################################

my $masterfile;

#check for input
if(@ARGV != 1){
    die "You need to provide one master file as an argument!";
}else{
    say "Creating empty exam file from \"$ARGV[0]\"...";
    $masterfile = $ARGV[0];
}


my $content = readFile($masterfile);

#open and read file
sub readFile($file){
    open(my $fileHandle, "<", $file) or die "Can't open \"$file\": $!";
    my @lines = readline $fileHandle;
    my $lines = join '', @lines;
    close($fileHandle);
    return $lines;
}

#say $content;

my $intro = parseIntro($content);

#parse the intro of the master file
sub parseIntro($content) {
    $content =~ m/([^_]*[\n]*)/;
    return "$1";
}

#decoration line from master file
my $decorationLine = "________________________________________________________________________________";

#parse the entire exam with the Regex Grammar module from today's tutorial!
#https://metacpan.org/pod/Regexp::Grammars


say $intro.$decorationLine;