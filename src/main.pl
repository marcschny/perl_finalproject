use v5.32;
use strict;
use warnings;
use experimental ('signatures');
use Data::Show;

use lib 'C:\Users\schny\Desktop\perl\Project\perl_finalproject\src';
use Modules::Exam_Parser('parseExam', 'parseIntro');
use Modules::Create_Exam('createExam');


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

#store raw content
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

#store parsed intro
my $intro = parseIntro($content);

#store entire parsed exam
my %parsedExam = parseExam($content);

#show (%parsedExam);

#store new created exam (w/ randomized answers)
my $newExam = createExam($intro, %parsedExam);

say $newExam;

#say $intro.$decorationLine;