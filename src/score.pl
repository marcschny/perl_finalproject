use v5.32;
use strict;
use warnings;
use experimental ('signatures');
use File::Spec;
use Time::Moment;
use File::Basename;
use Lingua::StopWords ('getStopWords');
use Text::Levenshtein ('distance');
use Color::Output ('cprint');

use lib 'C:\Users\schny\Desktop\perl\Project\perl_finalproject\src';
use Modules::Exam_Parser('parseExam', 'parseIntro');
use Modules::Create_Exam('createExam');
use Modules::Useful_Subs('readFile', 'remLinebreak', 'remLeadAndTrailWs');

#init color output module
Color::Output::Init;


#############################################
#   MAIN TASK: PART 1B                      #
#                                           #
#   This file compares student exams with   #
#   the master exam and scores the          #
#   student exams                           #
#############################################


#input vars
my $masterfile;
my @studentfiles;

#first check input (at least 2 args must been provided)
if(@ARGV < 2){
    die "You need to provide at least 2 arguments: a masterfile and x student files!";
}else{
    $masterfile = $ARGV[0];
    for my $file (@ARGV[1..$#ARGV]){
        push @studentfiles, $file;
    }
    print "\nComparing student files [";
    for(@studentfiles){print basename($_).", "}
    print "]\nwith masterfile [" . basename $masterfile . "]...\n\n";
}

#get master content
my $masterContent = readFile($masterfile);  #store raw content from masterfile
my %masterParsedExam = parseExam($masterContent); #store entire parsed master exam
my @masterExamComponent = @{$masterParsedExam{'exam'}->{'exam_component'}};  #array with hashes (exam_component) from master
my @masterQuestionAnswerBlocks = getQuestionAnswerBlocks(@masterExamComponent);  #get question_and_answers-blocks from master


#calculate score and print errors for each student file
for my $file (@studentfiles){
    my $studentContent = readFile($file);
    my %studentParsedExam = parseExam($studentContent);
    my @studentExamComponent = @{$studentParsedExam{"exam"}->{"exam_component"}};
    my @studentQuestionAnswerBlocks = getQuestionAnswerBlocks(@studentExamComponent);

    calcScore($file, @studentQuestionAnswerBlocks);
}


#get question_and_answers-blocks from exam_components
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
# -remove leading and trailing whitespaces
sub normalize($string){
    my $allStopWords = getStopWords('en');

    #unicode case-folded lower case
    $string = fc $string;
    #store each word from string in array
    my @stringWords = split / /, $string;
    #remove stopwords
    $string = join ' ', grep { !$allStopWords->{$_} } @stringWords;
    #remove leading and trailing whitespaces
    $string = remLeadAndTrailWs $string;

    return $string;
}


#compare two normalized string
sub compare($string1, $string2){
    return distance(normalize($string1), normalize($string2));
}


#calculate the score of the student exam file
#compared to the master exam file
#print outputs
sub calcScore($studentfile, @studentQuestionAnswerBlocks){

    my @errors;
    my $answeredQuestions = 0;
    my $missingQuestions = 0;
    my $missingAnswers = 0;
    my $score = 0;

    #offset used for missing questions
    my $offset = 0;

    #loop through master questions
    foreach my $question (0..$#masterQuestionAnswerBlocks){

        #if a missing question has been found: skip this loop
        if(!exists($masterQuestionAnswerBlocks[$question + $offset])){next;}

        #init master and student q&a-blocks as hashes
        my %masterHash = %{$masterQuestionAnswerBlocks[$question + $offset]};
        my %studentHash = %{$studentQuestionAnswerBlocks[$question]};



        ### MISSING QUESTIONS

        #check for missing questions
        if(compare( @{$masterHash{"question"}}{"text"}, @{$studentHash{"question"}}{"text"} ) > 0){
            $offset++; #increase offset for master
            $missingQuestions++; #increase number of missing questions
            push @errors, "Missing question found: " . remLinebreak $masterHash{'question'}{'text'};
        }



        ### MISSING/MISSPELLED ANSWERS

        #init arrays for master and student answers
        my @masterAnswers;
        my @studentAnswers;

        #push all four master answers in the array (for each question)
        for my $masterAnswer (@{$masterHash{"answer"}}){
            push @masterAnswers, $masterAnswer->{"text"};
        }

        #push all four student answers in the array (for each question)
        for my $studentAnswer (@{$studentHash{"answer"}}){
            push @studentAnswers, $studentAnswer->{"text"};
        }

        #sort arrays alphabetically (since answers in student exams are randomized)
        @masterAnswers = sort @masterAnswers;
        @studentAnswers = sort @studentAnswers;

        #offset used for missing answers
        my $answerOffset = 0;

        #store current question_number
        my $questionNumber = @{$masterHash{"question"}}{"question_number"};

        #compare answers - check for missing or misspelled answers
        for(my $i=0; $i<@masterAnswers; $i++){
            #compare answers
            my $cmp = compare($masterAnswers[$i], $studentAnswers[$i-$answerOffset]);
            #if the comparison results in a distance bigger than zero
             if($cmp > 0){
                 $missingAnswers++; #increase missing/misspelled answers
                 #if the distance is equal or bigger than the master answer, then the student answer is missing
                 if($cmp >= length(normalize($masterAnswers[$i]))){
                     push @errors, "Missing answer '" .remLinebreak remLeadAndTrailWs $masterAnswers[$i]. "' found in question $questionNumber"; #push error to array
                     $answerOffset++; #increase answer offset
                 }
                 #if the distance is not equal or bigger than the master answer, then the student answer is misspelled
                 else{
                     push @errors, "Misspelled answer '" .remLinebreak remLeadAndTrailWs $masterAnswers[$i]. "' found in question $questionNumber"; #push error to array
                 }
             }
        }



        ### SCORING

        my $correctAnswer = ""; #correct answer
        my $countX = 0; #number of Xs

        #get correct answer from master
        for my $answer (@{$masterHash{"answer"}}){
            if($answer->{"checkbox"} eq "[X]"){
                $correctAnswer = $answer->{"text"};
            }
        }

        #bool to check if questions was already answered (to avoid multiple answeredQuestions)
        # 0 = not answered
        # 1 = answered
        my $questionAnswered = 0;

        #check answer from student and calculate scoring
        for my $answer (@{$studentHash{"answer"}}){
            #check for marked checkboxes in different variations
            if($answer->{"checkbox"} =~ /\[\s*[xX]\s*\]/){
                $countX++; #increase counter for amount of checked boxes

                #compare students checked answer to masters correct answer
                my $cmp = compare($answer->{"text"}, $correctAnswer);

                #increase correctAnswers
                # only if one answer is checked and the comparison results in zero
                if($countX == 1 && $cmp == 0){
                    $score++;
                }

                #increase answeredQuestions
                # if a question is answered but not correctly (or multiple answers)
                # and if the questions hasn't been answered yet
                if($countX >= 1 && $questionAnswered == 0){
                    $answeredQuestions++;
                    $questionAnswered = 1;
                }
            }

        }

    }



    ##OUTPUT

    #pint student file name with scoring
    print basename($studentfile);
    for(0..(90-length(basename($studentfile)))){
        print ".";
    }
    print "$score/$answeredQuestions\n";


    #say "\n\tTotal questions not found: $missingQuestions";
    #say "\tTotal missing or misspelled answers found: $missingAnswers";

    #print out errors in red
    foreach my $error (@errors){
        cprint ("\0035   $error\n");
    }

    cprint ("\x030\n"); #switch back to white color


}
