package Modules::Exam_Parser;

use v5.32;
use warnings;
use diagnostics;
use experimentals;
use Exporter ('import');
use Regexp::Grammars;
use Data::Show;

our @EXPORT = ('parseExam', 'parseIntro');


#############################################
#   This module parses the entire exam      #
#   using the grammars module               #
#############################################



sub parseExam($content){

    my $exam_parser = qr{

    <exam>

    <nocontext:>

    <rule: exam>
        <[exam_component]>*

    <rule: exam_component>
            <question_and_answers>
            |
            <decoration>

    <rule: question_and_answers>
        <question>
        <[answer]>+
        <.empty_line>

    <token: question>
        \s* <question_number> <text>

    <token: answer>
        \s* <checkbox> <text>

    <token: question_number>
        \d+ \.

    <token: text>
        \N* \n                  # First line of text may be anything
        (?: \N* \S \N* \n )*?   # Extra lines of text must contain a non-space

    <token: checkbox>
        \[\s*.*?\s*\]

    <token: decoration>
        \N* \n

    <token: empty_line>
        \s* \n
    }xms;


    if($content =~ $exam_parser){
        my %parsed = %/;
        return %parsed;
    }else{
        warn 'Not a valid exam file';
    }

}

#parse the intro of the master file
sub parseIntro($content) {
    $content =~ m/([^_]*[\n]*)/;
    return "$1";
}

1; #return true