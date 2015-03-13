#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(strftime);
use DBD::Pg;
use PDF::Reuse;
use utf8;

#
# ./generate-tests.pl [variant]
#

$|=1;

sub logger {
	print 'Error: ' . $_[0] ."\n" if defined($_[0]);
}

my $debug = 0;
my $pguser = 'smalusr';
my $pgpass = 'kokoshka';
my $pgdb = 'DBI:Pg:database=smal;host=localhost;port=5432';
my $pgconn = DBI->connect_cached( $pgdb, $pguser, $pgpass, { PrintError => 1, AutoCommit => 1 }) or die("$DBI::errstr\n");
my $schema = 'public';
# define which test we are going to generate, first or second
my $first_test = 0;
my %ques = ();
my $qcount = 0;
my $question_count = 1;
my $max_questions = 50;
my $variant = 1;
$variant = $ARGV[0] if (defined($ARGV[0]) && $ARGV[0] =~ /^[0-9]+$/);
my $filename = "test1-variant$variant";
my $first_qid;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

$year = $year+1900;

my $test = $first_test ? 1 : 2;
print "Generating TEST $test $year variant $variant\n";

$pgconn->{pg_enable_utf8}=1;
# get the total count of questions in the table
my $get_qcount = $pgconn->prepare(sprintf('SELECT count(id) FROM "%s".questions WHERE %s first_test', $schema, $first_test ? '' : 'NOT' ))
	or logger($DBI::errstr);
if (!$get_qcount->execute()) {
	logger($DBI::errstr);
	exit 1;
}
$qcount = $get_qcount->fetchrow_array or logger($DBI::errstr);
if ($first_test) {
	$first_qid = $pgconn->prepare(sprintf('SELECT id FROM "%s".questions WHERE first_test ORDER BY id LIMIT 1', $schema ))
		or logger($DBI::errstr);
} else {
	$first_qid = $pgconn->prepare(sprintf('SELECT id FROM "%s".questions WHERE NOT first_test ORDER BY id LIMIT 1', $schema ))
		or logger($DBI::errstr);
}
my $fqid = $first_qid->execute();
print "First quid: $fqid\n" if $debug;

#my $get_question   = $pgconn->prepare(sprintf('SELECT question FROM "%s".questions WHERE id = ? OFFSET random()*%d LIMIT 1', $schema, $qcount))
my $get_question   = $pgconn->prepare(sprintf('SELECT question FROM "%s".questions WHERE id = ? LIMIT 1', $schema))
	or logger($DBI::errstr);
my $right_asnwares = $pgconn->prepare(sprintf('SELECT answer FROM "%s".right_answers WHERE q_id = ?', $schema))
	or logger($DBI::errstr);
my $wrong_asnwares = $pgconn->prepare(sprintf('SELECT answer FROM "%s".wrong_answers WHERE q_id = ?', $schema))
	or logger($DBI::errstr);

# %ques structure
# key - question id
# [0] - location of the right answare
# [1] - [4] - randomly selected right or wrong answare
# [5] - question text
# [6] - question id
my %questions_check = ();
my %excluded = ();

my $id_compensation = 1;
$id_compensation = $fqid-1 if !$first_test;
my $id = $id_compensation + int(rand($qcount));
# generate random question positions
while ($question_count <= $max_questions) {
	print "Num: $question_count" if $debug;
	my $rcount = 0;
	until (! exists $questions_check{$id} && ! exists $excluded{$id}) {
		$id = $id_compensation + int(rand($qcount));
		if ($rcount == 350) {
			print "Too random\n" if $debug;
			last;
		}
		$rcount++;
	}
	print " q_id: $id\n" if $debug;
	$questions_check{$id} = 1;
	$ques{$question_count} = [ -1, -1, -1, -1, -1, -1 ];
	$ques{$question_count}[6] = $id;
	my $location = 1 + int(rand(4));
	$ques{$question_count}[$location] = 66;
	$ques{$question_count}[0] = $location;
	$question_count++;
}
for (sort keys(%ques)) {print "$_ not defined\n" if (!defined($ques{$_}[0]));}

my $page_count = 1;
# Starting position on the page(after the answer boxes)
my $last_line = 666;

sub page_check {
	my $last_pos = $_[0];
	my $page_count = $_[1];
 	print 'Page: '.${$page_count}.' Line: '.${$last_pos}."\n" if $debug;
	${$last_pos} -= 16;
	if (${$last_pos} < 40) {
		if (${$page_count} == 1) {
			prAdd("0.0 0.0 0.0 RG\n");
			prAdd("9.0 9.0 9.0 rg\n");
			for my $l (1..25) {
				my $pos = ($l * 18) + 20;
				prAdd("$pos 711 18 20 re\n");
				prAdd("$pos 676 18 20 re\n");
			}
			prAdd("B\n");
		}

		${$last_pos} = 780;
		prPage();
		${$page_count}++;
		prText(520,800,'Page '.${$page_count});
	}
}

prFile("$filename.pdf");
prTTFont('/usr/share/fonts/arial.ttf');
prText(35,800,"Linux System & Network Administration");
prText(340,800,"TEST $test   $year");
prText(532,800,"Page $page_count");
prText(35,780,"Name: ______________________________________________________________________");
prText(35,760,"SoftUni username: ______________________________");
prText(510,760,"  Variant: $variant");
for my $l (1..25) {
	my $pos = ($l * 18) + 24;
	if ($l > 9) {
		$pos = ($l * 18) + 22;
	}
	prText($pos,734,$l);
	prText($pos-1,699,$l+25);
}

prFontSize('10');

# populate the questions
my $tcount = 1;
for (1..$max_questions) {
	my $qid = $_;
	next if ($ques{$qid}[6] !~ /^[0-9]+$/);
# get the question
	$get_question->execute($ques{$qid}[6]) or logger($DBI::errstr);
	my $question = $get_question->fetchrow_array or logger($DBI::errstr);
	print 'Get question: (' . $ques{$qid}[6] . ') ' . $question . "\n" if $debug;
# get all right answares
	$right_asnwares->execute($ques{$qid}[6]) or logger($DBI::errstr);
	my @answares = ();
	my $entry_count=0;
	while(my $data = $right_asnwares->fetchrow_array) {
		$answares[$entry_count] = $data;
		$entry_count++;
	}

# get all wrong answares
	$wrong_asnwares->execute($ques{$qid}[6]) or logger($DBI::errstr);
	my @mistakes = ();
	$entry_count = 0;
# copy them into an array
	while (my @data = $wrong_asnwares->fetchrow_array) {
		$mistakes[$entry_count] = $data[0];
		$entry_count++;
	}

# get 3 random answares
	my @mis = ();
	if ($#mistakes <=2)	{
		for (my $m=0; $m <=2 ; $m++) {
			$mis[$m] = $mistakes[$m] if defined($mistakes[$m]);
		}
	} else {
	 	my %inuse = ();
	 	for (my $m = 0; $m < 3; $m++) {
 			my $num = 0 + int(rand($#mistakes));
 			until (! exists $inuse{$num}) {
	 			$num = 0 + int(rand($#mistakes));
 			}
 			$inuse{$num} = 0;
 			$mis[$m] = $mistakes[$num];
 		}
	}

# save the random chosen wrong answares into the hash
	$entry_count = 0;
	for (my $m = 1; $m <= 4; $m++) {
		# skip the right answare place
		next if ($m == $ques{$qid}[0]);
		$ques{$qid}[$m] = $mis[$entry_count] if defined($mis[$entry_count]);
		$entry_count++;
	}

# save the question into the hash
	$ques{$qid}[5] = $question;
# save the answare into the hash
	$ques{$qid}[$ques{$qid}[0]] = $answares[0 + int(rand($#answares))];
# add ? to all questions that don't have one at the end
	print "Id: $qid Qid: $ques{$qid}[5]\n" if $debug;
	$ques{$qid}[5] =~ s/:\s*$// if ($ques{$qid}[5] =~ /:\s*$/);
	$ques{$qid}[5] = $ques{$qid}[5].' ?' if ($ques{$qid}[5] !~ /\?$/);

	page_check(\$last_line,\$page_count);

	my $q_len = length($ques{$qid}[5]);
	if ($q_len > 92) {
		my @lines = split /\n/, $ques{$qid}[5];
		for (my $l=0;$l<=$#lines;$l++) {
			$lines[$l] =~ s/\n/ /g;
			if ($l==0) {
				prText(35,$last_line,sprintf('%d. %s', $qid, $lines[$l]));
			} else {
				prText(35,$last_line,$lines[$l]) if ($lines[$l] !~ /^[\s|\n]*$/);
			}
			page_check(\$last_line,\$page_count);
		}
	} else {
		prText(35,$last_line,sprintf('%d. %s', $qid, $ques{$qid}[5]));
	}

	my %a_names = ( 1 => 'a', 2 => 'b', 3 => 'c', 4 => 'd' );
	$entry_count = 1;
	for (my $c=1;$c<5;$c++) {
		if (defined($ques{$qid}[$c]) && $ques{$qid}[$c] ne '-1') {
 			printf("  %s) %s\n", $a_names{$entry_count}, $ques{$qid}[$c]) if $debug;
			page_check(\$last_line,\$page_count);
			prText(35,$last_line,sprintf("  %s) %s", $a_names{$entry_count}, $ques{$qid}[$c]));
			$entry_count++;
		}
	}
	$tcount++;
}

prEnd();
prFile("$filename-asnwares.pdf");
prTTFont('/usr/share/fonts/arial.ttf');
prText(510,760,"Вариянт: $variant");
for my $l (1..25) {
	my $pos = ($l * 18) + 24;
	prText($pos,724,$l);
	prText($pos,684,$l+25);
}

# print the right answares :)
$tcount = 1;
print "\nNum: \n" if $debug;
# prAdd("0.0 0.0 0.0 RG\n");
#for (sort keys(%ques)) {
for (1..$max_questions) {
	print "$_ not defined\n" if (!defined($ques{$_}[0]) && $debug);
	my $right = 'a';
	$right = 'b' if ($ques{$_}[0] == 2);
	$right = 'c' if ($ques{$_}[0] == 3);
	$right = 'd' if ($ques{$_}[0] == 4);
	printf("%2d: %s \n",$tcount, $right) if $debug;
	prAdd("q 38 717 m 490 717 l S Q");
	prAdd("q 38 698 m 490 698 l S Q");
	prAdd("q 38 677 m 490 677 l S Q");
	prAdd("q 38 658 m 490 658 l S Q");
	prAdd("q 490 698 m 490 717 l S Q");
	prAdd("q 490 658 m 490 677 l S Q");
 	if ($tcount <= 25) {
		my $pos = ($tcount * 18) + 24;
		my $pos2 =  $pos - 4;
		prAdd("q $pos2 698 m $pos2 717 l S Q");

# 		prAdd("9.0 9.0 9.0 rg\n");
#  		prAdd("$pos2 700 18 20 re\n");
#  		prAdd("t\n");
		prText($pos,704,$right);
	} else {
		my $pos = (($tcount - 25) * 18) + 24;
		my $pos2 = $pos - 4;
		prAdd("q $pos2 658 m $pos2 677 l S Q");
		prText($pos,663,$right);
	}

	$tcount++;
}

for my $l (1..25) {
 	my $pos = ($l * 18) + 20;
# 	prAdd("$pos 698 18 20 re\n");
# 	prAdd("$pos 660 18 20 re\n");
 }
 prAdd("B\n");
prEnd();
