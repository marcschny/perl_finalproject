use v5.32;
use strict;
use warnings;
use experimental ('signatures');
use File::Spec;
use Time::Moment;
use File::Basename;
use Lingua::StopWords ('getStopWords');
use Text::Levenshtein ('distance');

use lib 'C:\Users\schny\Desktop\perl\Project\perl_finalproject\src';
use Modules::Exam_Parser('parseExam', 'parseIntro');
use Modules::Create_Exam('createExam');
use Modules::Useful_Subs('readFile');


#############################################
#   MAIN TASK: PART 1B                      #
#                                           #
#   This file compares student exams with   #
#   the master exam and scores the          #
#   student exams                           #
#############################################



my $masterfile;
my @studentfiles;

#check for input
if(@ARGV < 2){
    die "You need to provide at least 2 arguments: a masterfile and x student files!";
}else{
    $masterfile = $ARGV[0];
    for my $file (@ARGV[1..$#ARGV]){
        push @studentfiles, $file;
    }
    print "Comparing student files [";
    for(@studentfiles){print basename($_).", "}
    print "]\nwith masterfile [" . basename $masterfile . "]...";
}


#store raw content
my $masterContent = readFile($masterfile);

#store entire parsed exam
my %masterParsedExam = parseExam($masterContent);

#array with hashes (exam_component)
my @masterExamComponent = @{$masterParsedExam{'exam'}->{'exam_component'}};

#get question_and_answers blocks
my @masterQuestionAnswerBlocks = getQuestionAnswerBlocks(@masterExamComponent);

sub getQuestionAnswerBlocks(@examComponent){
    my @questionAnswerBlocks;
    foreach my $elem(@examComponent){
        if($elem->{'question_and_answers'}){
            push @questionAnswerBlocks, $elem->{'question_and_answers'};
        }
    }
    return @questionAnswerBlocks;
}


#normalize a string:
# -unicode case-folded lower case
# -remove stopwords
# -remove leading and traling whitespaces
sub normalize($string){
    my $allStopWords = getStopWords('en');

    #unicode case-folded lower case
    $string = fc $string;
    #store each word from string in array
    my @stringWords = split / /, $string;
    #remove stopwords
    $string = join ' ', grep { !$allStopWords->{$_} } @stringWords;
    #remove leading and trailing whitespaces
    $string =~ s/^\s+|\s+$//g;

    return $string;
}


#compare two normalized string
sub compare($string1, $string2){
    return distance(normalize($string1), normalize($string2));
}

##################

my $studentContent = readFile($studentfiles[0]);

my %studentParsedExam = parseExam($studentContent);

my @studentExamComponent = @{$studentParsedExam{'exam'}->{'exam_component'}};

my @studentQuestionAnswerBlocks = getQuestionAnswerBlocks(@studentExamComponent);

##################

calcScore($studentfiles[0], @studentQuestionAnswerBlocks);

#calculate the score of the student exam file
#compared to the master exam file
sub calcScore($studentfile, @parsedExam){

    my @errors;
    my @missingQuestions;
    my @missingAnswers;
    my $score = 0;
    my $answeredQuestions = 0;
    my $correctAnswers = 0;
    my $missingQuestions = 0;
    my $questions = 0;

    #offset used for missing questions
    my $offset = 0;

    foreach my $question(0..$#masterQuestionAnswerBlocks){

        #if a missing question has been found: skip this loop
        if(!exists($masterQuestionAnswerBlocks[$question + $offset])){next;}

        #init master and student q&a-blocks as hashes
        my %masterHash = %{$masterQuestionAnswerBlocks[$question + $offset]};
        my %studentHash = %{$studentQuestionAnswerBlocks[$question]};

        #check for missing questions
        if(compare( @{$masterHash{"question"}}{"question_number"}, @{$studentHash{"question"}}{"question_number"} ) > 0){
            say "Missing Question found: ". @{$masterHash{"question"}}{"question_number"} . $masterHash{'question'}{'text'};
            $offset++; #increase offset for master
            $missingQuestions++; #increase number of missing questions
            push @missingQuestions, $masterHash{'question'}{'text'};
        }

    }

    #print out each missing question
    foreach my $missingQuestion(@missingQuestions){
        say "Missing question: $missingQuestion";
    }

    say "Total questions not found: $missingQuestions";

}
