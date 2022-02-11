#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <output table> <output dir> <max number of reads> <should trim> <trim read offset> <trim read length> <input fastq R1> <input fastq R2>\n";
	exit 1;
}

my $ofn = $ARGV[0];
my $odir = $ARGV[1];
my $max_reads = $ARGV[2];
my $trim = $ARGV[3] eq "T";
my $offset = $ARGV[4];
my $rlen = $ARGV[5];
my $ifn1 = $ARGV[6];
my $ifn2 = $ARGV[7];

my $oindex = 1;

my $read_count = 0;
open(IN1, $ifn1) or die;
open(IN2, $ifn2) or die;

my %chunks;
my $iindex = 0;
while () {
    my $line1 = <IN1>;
    my $line2 = <IN2>;
    
    last if (!defined($line1) || !defined($line2));
    
    chomp($line1);
    chomp($line2);

    # new read
    if ($iindex % 4 == 0) {
	$read_count++;
	
	# open output files on first read
	if ($read_count == 1) {
	    my $ofn1 = $odir."/".$oindex."_R1.fastq";
	    my $ofn2 = $odir."/".$oindex."_R2.fastq";
	    $oindex++;
	
	    open(OUT1, ">", $ofn1) or die;
	    open(OUT2, ">", $ofn2) or die;
	    print "output file: $ofn1\n";
	    print "output file: $ofn2\n";
	}
    }
    
    
    if ($trim && $iindex % 2 == 1) {
	if (length($line1) > ($offset+$rlen) && length($line2) > ($offset+$rlen)) {
	    $line1 = substr($line1, $offset, $rlen);
	    $line2 = substr($line2, $offset, $rlen);
	}
    }

    print OUT1 $line1, "\n";
    print OUT2 $line2, "\n";

    # close output file at end of read if chunk full
    if ($iindex % 4 == 3 && $read_count >= $max_reads) {
	$chunks{$oindex-1} = $read_count;
	$read_count = 0;
	close(OUT1);
	close(OUT2);
    }
    $iindex++;
}
close(IN1);
close(IN2);

close(OUT1);
close(OUT2);

$chunks{$oindex-1} = $read_count if ($read_count > 0);

# chunk table
print "output chunk table: $ofn\n";
open(OUT, ">", $ofn) or die;
print OUT "chunk\treads\n";
foreach my $oindex (sort { $a <=> $b } keys %chunks) {
    print OUT $oindex, "\t", $chunks{$oindex}, "\n";
}
close(OUT);
