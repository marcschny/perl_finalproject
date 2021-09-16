package Modules::Statistics;

use v5.32;
use warnings;
use diagnostics;
use experimentals;
use Exporter ('import');
use List::Util ('shuffle');
use POSIX;

our @EXPORT = ('statistics');

#############################################
#   This module provides the subroutine     #
#   used for statistics (part 3)            #
#############################################



#print out statistics: average, minimum and maximum
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
    my $averageAnswered = floor($answeredTotal/$numberOfExams);
    
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
    my $averageCorrectAnswered = floor($correctAnsweredTotal/$numberOfExams);
    
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
    say "Statistics...\n";

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

1; #return true