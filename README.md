# Final Project (Perl)

### Team
- Marc Schnydrig

### Solved Parts
- Part 1
- Part 2
- Part 3

---

### Architecture
- There are two main files
    - [src/randomize.pl](src/randomized.pl) creates the empty exam file from a master file (Part 1a)
    - [src/score.pl](src/score.pl) 
      - compares student exams with the master exam and scores the student exams (Part 1b)
      - reports missing questions and missing or misspelled answers (Part 2)
      - prints out the statistics from [src/Modules/Statistics](src/Modules/Statistics.pm) (Part 3)
- And there are several modules with many subroutines:
  - [src/Modules/Create_Exam](src/Modules/Create_Exam.pm) creates a new exam file with randomized answers 
  - [src/Modules/Exam_Parser](src/Modules/Exam_Parser.pm) parses the entire exam using the grammars module
  - [src/Modules/Statistics](src/Modules/Statistics.pm) provides subroutines used for statistics (part 3)
  - [src/Modules/Useful_Subs](src/Modules/Useful_Subs.pm) provides useful subroutines used in the entire project

---

### Used CPAN-Modules
- Data::Show - to show content of variables such as hashes
- Cwd - get pathname of current working directory
- File::Spec - portably perform operations on file names
- Time::Moment - represents a date and time of day with an offset from UTC
- File::Basename - parse file paths into directory, filename and suffix
- Lingua::StopWords - stop words for several languages
- Text::Levenshtein::Damerau - Damerau Levenshtein edit distance
- Color::Output - to give color to the output
- POSIX - several mathematical functions
- Regexp::Grammars - grammatical parsing features
- Statistics::Basic::Stddev - calculate standard deviation
- List::Util - to shuffle a list

---

### Criteria for significant expectations
- Criteria 1: only show students with a score less than 50% (score < 50%)
- Criteria 2: only show students who answered less than 25% of the entire exam (answered questions < 25%)
- Criteria 3: only show students who are more than one standard deviation below the average score

---

### Get Started
- To run the scripts, perl v5.3.2 must be installed
- Also the above-mentioned CPAN-modules must be installed
- Then the line `use lib '...';` has to be replaced with your current lib-directory (probably just `use lib 'lib';` should work) in both files [src/randomize.pl](src/randomize.pl) and [src/score.pl](src/score.pl) !
- And now you can run either:
  - `perl src/randomize.pl <path_of_master_file>` to create a new empty exam file with randomized answers
  - or:
  - `perl src/score.pl <path_of_master_file> <paths_of_student_files>` to score the student files, print out missing questions and answers, and see the statistics

---
### Remark
The file [src/score.pl](src/score.pl) is not working correctly (part 1b/2). More specifically, the checking of missing or incorrect answers does not work quite precisely.
The problem lies in sorting the answers: in the case of incorrect answers, the wrong answers are sometimes compared with each other after sorting them alphabetically.
By the time I realized this it was too late to adjust anything, so I left it as is and tried to improve it a little more.