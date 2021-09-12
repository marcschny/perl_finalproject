package Modules::Create_Exam;

use v5.32;
use warnings;
use diagnostics;
use experimentals;
use Exporter ('import');
use List::Util ('shuffle');

our @EXPORT = ('createExam');

#############################################
#   This module creates a new exam file     #
#   with randomized answers                 #
#############################################


sub createExam($intro, %parsedExam){

    #decoration line
    my $decorationLine = qq{\n________________________________________________________________________________\n\n};

    #var to star the new file content:
    my $newFile;

    #add the intro to the new file
    $newFile .= $intro;

    #add decoration line below the intro
    $newFile .= $decorationLine;

    #array with hashes (exam_component)
    my @examComponent = @{$parsedExam{'exam'}->{'exam_component'}};

    #boolean to check if 'question_and_answers'-block was found
    my $check = 0;

    #int to store the number of questions found
    my $checkQuestions = 0;

    #add the questions and the randomized answers
    foreach my $elem (@examComponent){
        if($elem->{'question_and_answers'}){
            $check = 1;
            $checkQuestions++;

            #add question_number and question
            my %question = %{$elem->{'question_and_answers'}->{'question'}};
            $newFile .= $question{'question_number'} . ' ' . $question{'text'};

            #add shuffled (empty) answers
            my @answers = @{$elem->{'question_and_answers'}->{'answer'}};
            for my $answer (shuffle @answers){
                $newFile .= '    [ ] ' . $answer->{'text'};
            }

            #add decoration line at the end of a 'question_and_answers'-block
            $newFile .= $decorationLine;
        }
    }


    #only return new file when the checks succeed
    if($check && $checkQuestions==30){
        return $newFile;
    }elsif($check){
        warn 'Number of questions in method "Create_Exam" does not match';
    }else{
        warn 'Method "Create_Exam" failed!';
    }


}

1; #return true