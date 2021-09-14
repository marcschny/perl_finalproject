package Modules::Useful_Subs;

use v5.32;
use warnings;
use diagnostics;
use experimentals;
use Exporter ('import');
use Regexp::Grammars;
use Data::Show;

our @EXPORT = ('readFile', 'remLinebreak', 'remLeadAndTrailWs');


#############################################
#   This module provides useful sub-        #
#   routines used in the entire project     #
#############################################


#subroutine to open and read file
sub readFile($file){
    open(my $fileHandle, "<", $file) or die "Can't open \"$file\": $!";
    my @lines = readline $fileHandle;
    my $lines = join '', @lines;
    close($fileHandle);
    return $lines;
}

#remove linebreaks
sub remLinebreak($string){
    $string =~ s/\R//g;
    return $string;
}

#remove leading and trailing whitespaces
sub remLeadAndTrailWs($string){
    $string =~ s/^\s+|\s+$//g;
    return $string;
}