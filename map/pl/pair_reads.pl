#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <read1 ifn> <read2 ifn> <select single mapped read with maximal field value> <ofn> <ofn stats>\n";
	exit 1;
}

my $ifn1 = $ARGV[0];
my $ifn2 = $ARGV[1];
my $max_field = $ARGV[2];
my $ofn_pair = $ARGV[3];
my $ofn_R1 = $ARGV[4];
my $ofn_R2 = $ARGV[5];
my $ofn_stats = $ARGV[6];

# stats
my $count = 0;
my %reads;

# we discard the sequence field at this time
my @fields = ("contig", "coord", "back_coord", "strand", "edit_dist", "score", "match_length", "cigar", "substitute", "insert", "delete", "clip", "unique");

######################################################################################################
# load read1
######################################################################################################

my %stats;
$stats{ok} = 0;
$stats{no_pair} = 0;

foreach my $side ("R1", "R2") {
    my $ifn = $side eq "R1" ? $ifn1 : $ifn2;
    print "traversing read file: $ifn\n";
    open(IN, $ifn) || die $ifn;
    my $header = <IN>;
    my %h = parse_header($header);

    while (my $line = <IN>) {
	chomp($line);

	$count++;
	print $count, "\n" if ($count % 1000000 == 0);
	my @f = split("\t", $line);

	my $id = $f[$h{id}];
	my $value = $f[$h{$max_field}];

	if (!defined($reads{$id})) {
	    $reads{$id} = {};
	    $reads{$id}->{R1} = {};
	    $reads{$id}->{R1}->{max_value} = 0;
	    $reads{$id}->{R2} = {};
	    $reads{$id}->{R2}->{max_value} = 0;
	}

	next if ($value < $reads{$id}->{$side}->{max_value});
	$reads{$id}->{$side}->{max_value} = $value;

	$reads{$id}->{$side}->{fields} = {};
	foreach my $field (@fields) {
	    $reads{$id}->{$side}->{fields}->{$field} = $f[$h{$field}];
	}
    }
    close(IN);
}

######################################################################################################
# output
######################################################################################################

my $paired = 0;

# paired
print "generating file: $ofn_pair\n";
open(OUT_PAIR, ">", $ofn_pair) || die $ofn_pair;
print OUT_PAIR "id\t";
foreach my $side (1,2) {
    foreach my $field (@fields) {
	print OUT_PAIR $field.$side."\t";
    }
}
print OUT_PAIR "\n";

# R1
print "generating file: $ofn_R1\n";
open(OUT_R1, ">", $ofn_R1) || die $ofn_R1;
print OUT_R1 "id\t";
foreach my $field (@fields) {
    print OUT_R1 $field."\t";
}
print OUT_R1 "\n";

# R2
print "generating file: $ofn_R2\n";
open(OUT_R2, ">", $ofn_R2) || die $ofn_R2;
print OUT_R2 "id\t";
foreach my $field (@fields) {
    print OUT_R2 $field."\t";
}
print OUT_R2 "\n";


foreach my $id (keys %reads) {
    if ($reads{$id}->{R1}->{max_value} == 0 || $reads{$id}->{R2}->{max_value} == 0) {
	($reads{$id}->{R1}->{max_value} != 0 || $reads{$id}->{R2}->{max_value} != 0) or die "internal error";

	if ($reads{$id}->{R1}->{max_value} != 0) {
	    print OUT_R1 $id;
	    foreach my $field (@fields) {
		print OUT_R1 "\t".$reads{$id}->{R1}->{fields}->{$field};
	    }
	    print OUT_R1 "\n";
	} else {
	    print OUT_R2 $id;
	    foreach my $field (@fields) {
		print OUT_R2 "\t".$reads{$id}->{R2}->{fields}->{$field};
	    }
	    print OUT_R2 "\n";
	}
		    
	$stats{no_pair}++;
	next;
    }
    $stats{ok}++;

    print OUT_PAIR $id;
    foreach my $side (1,2) {
	foreach my $field (@fields) {
	    my $side_str = "R".$side;
	    print OUT_PAIR "\t".$reads{$id}->{$side_str}->{fields}->{$field};
	}
    }
    print OUT_PAIR "\n";
    $paired++;
}
close(OUT_PAIR);
close(OUT_R1);
close(OUT_R2);

print sprintf("total number of reads: %d\n", $count);
print sprintf("paired reads: 2x%d=%d\n", $paired, $paired*2);

print_hash($ofn_stats, %stats);

######################################################################################################
# Subroutines
######################################################################################################

sub parse_header
{
	my ($header) = @_;
	chomp($header);
	my @f = split("\t", $header);
	my %result;
	for (my $i = 0; $i <= $#f; $i++) {
		$result{$f[$i]} = $i;
	}
	return %result;
}

sub print_hash
{
    my ($ofn, %h) = @_;

    print "generating file: $ofn\n";
    open (OUT, ">", $ofn) || die $ofn;

    my $first = 1;
    foreach my $key (keys %h) {
	if ($first) {
	    print OUT $key;
	    $first = 0;
	} else {
	    print OUT "\t", $key;
	}
    }
    print OUT "\n";
    $first = 1;
    foreach my $key (keys %h) {
	if ($first) {
	    print OUT $h{$key};
	    $first = 0;
	} else {
	    print OUT "\t", $h{$key};
	}
    }
    print OUT "\n";
    close(OUT);
}

