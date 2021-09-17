package Modules::Useful_Subs;

use v5.32;
use warnings;
use diagnostics;
use experimentals;
use Exporter ('import');
use Regexp::Grammars;
use Data::Show;

#list of exported subroutines
our @EXPORT = ('readFile', 'remLinebreak', 'remLeadAndTrailWs', 'beforeSlash', 'afterSlash', 'remQuotes');


#############################################
#   This module provides useful sub-        #
#   routines used in the entire project     #
#############################################



#subroutine to open and read file
# parameters:
# - $file: path to the file
# return:
# - $lines: file content as lines
sub readFile($file){
    open(my $fileHandle, "<", $file) or die "Can't open \"$file\": $!";
    my @lines = readline $fileHandle;
    my $lines = join '', @lines;
    close($fileHandle);
    return $lines;
}

#remove linebreaks
# parameters:
# - $string: string to be formatted
# return:
# - $string: formatted string (w/o linebreaks)
sub remLinebreak($string){
    $string =~ s/\R//g;
    return $string;
}

#remove leading and trailing whitespaces
# parameters:
# - $string: string to be formatted
# return:
# - $string: formatted string (w/o leading and trailing whitespaces)
sub remLeadAndTrailWs($string){
    $string =~ s/^\s+|\s+$//g;
    return $string;
}

#get everything before a slash (by removing the slash and everything after the slash)
# parameters:
# - $string: string to be formatted
# return:
# - $string: formatted string
sub beforeSlash($string){
    $string =~ s/\/.*//g;
    return $string;
}

#get everything after a slash (by removing the slash and everything before the slash)
# parameters:
# - $string: string to be formatted
# return:
# - $string: formatted string
sub afterSlash($string){
    $string =~ s/.*\///g;
    return $string;
}

#remove quotes
# parameters:
# - $string: string to be formatted
# return:
# - $string: formatted string (w/o quotes)
sub remQuotes($string){
    $string =~ s/"//g;
    return $string;
}

1; #return true