use v5.32;
use strict;
use warnings;
use experimental ('signatures');
use Data::Show;
use Cwd;
use File::Spec;
use Time::Moment;
use File::Basename;

use lib 'C:\Users\schny\Desktop\perl\Project\perl_finalproject\src';
use Modules::Exam_Parser('parseExam', 'parseIntro');
use Modules::Create_Exam('createExam');
use Modules::Useful_Subs('readFile');


#############################################
#   MAIN TASK: PART 1A                      #
#                                           #
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

#store parsed intro
my $intro = parseIntro($content);

#store entire parsed exam
my %parsedExam = parseExam($content);

#show (%parsedExam);

#store new created exam (w/ randomized answers)
my $newExam = createExam($intro, %parsedExam);

#say $newExam;

saveFile($newExam);

#subroutine to save the new generated file
sub saveFile($examFile){

    #store current volume, directory and filename
    my ($volume, $directory, $filename) = File::Spec->splitpath(Cwd::abs_path(__FILE__));

    #move one directory up
    chdir File::Spec->updir;
    my $projectRoot =  Cwd::abs_path();

    #create new directory if it doesn't exist yet
    if(!-d "Generated"){
        my $newDirectory = "$projectRoot/Generated";
        mkdir($newDirectory) or die "Could not create $newDirectory directory, $!";
        print "Created Directory '/Generated'!";
    }else{
        print "Directory '/Generated' already exists!";
    }

    #new filename
    my $newFilename = getOutputFilename();

    #create empty exam file in new 'Generated'-Directory
    open(my $fh, ">", qq{$projectRoot/Generated/$newFilename})
        or die "Cannot open directory $projectRoot/Generated: $!";
    print $fh $examFile;
    close($fh);

}

#subroutine to get the new filename
#returns a string consisting of the formatted datetime and the original filename
sub getOutputFilename(){
    #get datetime now
    my $dateTimeNow = Time::Moment->now;

    #format datetime
    my $formattedDateTime = $dateTimeNow->strftime('%Y%m%d-%H%M%S');

    return $formattedDateTime . '-' . basename($masterfile);
}
