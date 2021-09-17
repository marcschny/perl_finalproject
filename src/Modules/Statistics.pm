package Modules::Statistics;

use v5.32;
use warnings;
use diagnostics;
use experimentals;
use Exporter ('import');
use List::Util ('shuffle');
use POSIX;
use Statistics::Basic ('stddev');

#custom modules
use lib 'C:\Users\schny\Desktop\perl\Project\perl_finalproject\src';
use Modules::Useful_Subs('beforeSlash', 'afterSlash', 'remQuotes');

#list of exported subroutines
our @EXPORT = ('statistics', 'belowExpectations');


#############################################
#   This module provides the subroutines    #
#   used for statistics (part 3)            #
#############################################



#init globally used vars
my ($averageAnswered, $averageCorrectAnswered);

#special characters
my $averageSymbol = chr(157);
my $sigmaSymbol = chr(208);


#print out statistics: average, minimum and maximum
# parameters:
# - $answeredQuestionsRef: reference to @answeredQuestions
# - $correctAnsweredQuestionsRef: reference to @scores
# - $numberOfExams: the number of exams
# return:
# - nothing (void)
sub statistics($answeredQuestionsRef, $correctAnsweredQuestionsRef, $numberOfExams){

    #dereference arrays
    my @answeredQuestions = @{$answeredQuestionsRef};
    my @correctAnsweredQuestions = @{$correctAnsweredQuestionsRef};
    
    #sort arrays
    @answeredQuestions = sort @answeredQuestions;
    @correctAnsweredQuestions = sort @correctAnsweredQuestions;


    #average questions answered
    my $answeredTotal = 0;
    for(@answeredQuestions){ $answeredTotal += $_; }
    $averageAnswered = floor($answeredTotal/$numberOfExams);
    
    #minimum and maximum answered questions
    my $minAnswered = $answeredQuestions[0];
    my $maxAnswered = $answeredQuestions[$#answeredQuestions];

    #counters for minimum and maximum number of answered questions
    my ($countMinAnswered, $countMaxAnswered) = 0;
    for(@answeredQuestions){
        if($_ == $minAnswered){ $countMinAnswered++; }   #count number of minimum questions answered
        if($_ == $maxAnswered){ $countMaxAnswered++; }   #count number of maximum questions answered
    }

    #average questions answered correctly
    my $correctAnsweredTotal = 0;
    for(@correctAnsweredQuestions){ $correctAnsweredTotal += $_; }
    $averageCorrectAnswered = floor($correctAnsweredTotal/$numberOfExams);
    
    #minimum and maximum questions answered correctly
    my $minCorrectAnswered = $correctAnsweredQuestions[0];
    my $maxCorrectAnswered = $correctAnsweredQuestions[$#correctAnsweredQuestions];
    
    #counters for minimum and maximum questions answered correctly
    my ($countMinCorrectAnswered, $countMaxCorrectAnswered) = 0;
    for(@correctAnsweredQuestions){ 
        if($_ == $minCorrectAnswered){ $countMinCorrectAnswered++; }    #count number of minimum questions answered correctly
        if($_ == $maxCorrectAnswered){ $countMaxCorrectAnswered++; }    #count number of maximum questions answered correctly
    }



    ## OUTPUTS

    #print statistics title
    say "\nStatistics...\n";

    #print number of exams
    say " Number of exams: $numberOfExams\n";
    
    #print average of questions answered
    say " Average number of questions answered: $averageAnswered";

    #print minimum of questions answered
    print "   Minimum: $answeredQuestions[0] ($countMinAnswered student";
    $countMinAnswered == 1 ? print ")" : print "s)";

    #print maximum of questions answered
    print "\n   Maximum: $answeredQuestions[$#answeredQuestions] ($countMaxAnswered student";
    $countMaxAnswered == 1 ? print ")" : print "s)";

    say "\n";   #just a break-line

    #print average of questions answered correctly
    say " Average number of correct answers: $averageCorrectAnswered";

    #print minimum of questions answered correctly
    print "   Minimum: $correctAnsweredQuestions[0] ($countMinCorrectAnswered student";
    $countMinCorrectAnswered == 1 ? print ")" : print "s)";

    #print maximum of questions answered correctly
    print "\n   Maximum: $correctAnsweredQuestions[$#correctAnsweredQuestions] ($countMaxCorrectAnswered student";
    $countMaxCorrectAnswered == 1 ? print ")" : print "s)";

    say "\n"; #just a break-line
}



#print out 'below expectations'-statistics
# parameters:
# - $studentScores: reference to %studentScores
# - $numberOfQuestions: number of questions
# returns
# - nothing (void)
sub belowExpectations($studentScores, $numberOfQuestions){

    #dereference hash
    my %studentScores = %{$studentScores};

    #expectation 1: score < 50%
    my @scoreBelow50p;
    my ($answered, $answeredCorrectly);

    #expectation 2: answered questions < 25% (25% of 30 =~ 8 => less than 8 questions answered in total)
    my @lessThan8Questions;

    #expectation 3: more than one standard deviation below the average score
    my @standardDeviationBelowAverage;
    my @scores;
    my $standardDeviation;

    #loop through studentScores-hash
    for my $key (keys %studentScores){

        #EXPECTATION 1 (score < 50%)
        #store the score
        $answeredCorrectly = beforeSlash($studentScores{$key});
        #store the number of answered questions
        $answered = afterSlash($studentScores{$key});
        #condition for exp 1 (score < 50%)
        if(($answeredCorrectly/$answered)*100 < 50){
            push @scoreBelow50p, "$key ($studentScores{$key})";
        }

        #EXPECTATION 2 (less than 25% of questions answered)
        if(($answered/$numberOfQuestions)*100 < 25){
            push @lessThan8Questions, "$key ($studentScores{$key})";
        }

        #push each score in an array (EXPECTATION 3)
        push @scores, $answeredCorrectly;

    }

    #EXPECTATION 3 (more than one standard deviation below the average score)
    $standardDeviation = stddev(@scores); #get standard deviation
    for my $key (keys %studentScores){
        my $score = beforeSlash($studentScores{$key});
        if($score < $averageCorrectAnswered-$standardDeviation){
            push @standardDeviationBelowAverage, "$key ($studentScores{$key})";
        }
    }



    ## OUTPUTS

    say "Results below expectations...\n";

    #print out expectation 1
    print " Score < 50%: ". scalar @scoreBelow50p . " student";
    scalar @scoreBelow50p != 1 ? print "s" : "";
    for(@scoreBelow50p){
        print "\n   $_";
    }
    say "\n";

    #print out expectation 2
    print " Answered questions < 25%: ". scalar @lessThan8Questions . " student";
    scalar @lessThan8Questions != 1 ? print "s" : "";
    for(@lessThan8Questions){
        print "\n   $_";
    }
    say "\n";   #just a line-break

    #print out expectation 3
    print " Score < 1$sigmaSymbol below average score [$sigmaSymbol=$standardDeviation, $averageSymbol=$averageCorrectAnswered]: ". scalar @standardDeviationBelowAverage . " student";
    scalar @lessThan8Questions != 1 ? print "s" : "";
    for(@standardDeviationBelowAverage){
        print "\n   $_";
    }

    say "\n"; #just a line-break
}


1; #return true