#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <table> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $max_reads = $ARGV[1];
my $min_length = $ARGV[2];
my $ofn1 = $ARGV[3];
my $ofn2 = $ARGV[4];

open(O1, ">", $ofn1) or die;
open(O2, ">", $ofn2) or die;
open(IN, $ifn) or die;

my $header = "";
my $seq = "";
my $score = "";
my $iindex = 0;
my $rcount = 0;

while (my $line = <IN>) {
    chomp($line);
    $header = $line if ($iindex % 4 == 0);
    $seq = $line if ($iindex % 4 == 1);
    $score = $line if ($iindex % 4 == 3);
    $iindex++;

    my $len = length($seq);
    if ($iindex % 4 == 0 && $len > $min_length)
    {
	$rcount++;
	last if ($rcount > $max_reads);
	my $middle = int($len / 2);

	# first half
	my $seq1 = substr($seq, 0, $middle);
	my $score1 = substr($score, 0, $middle);

	# second half
	my $seq2 = substr($seq, $middle, $len);
	my $score2 = substr($score, $middle, $len);

	print O1 $header, "\n", $seq1, "\n", "+", "\n", $score1, "\n";
	print O2 $header, "\n", $seq2, "\n", "+", "\n", $score2, "\n";
    }
}

close(O1);
close(O2);
close(IN);
