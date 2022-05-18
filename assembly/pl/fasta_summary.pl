#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

print "contig\tlength\n";

my $seq = "";
my $contig = "";
my $count = 0;
while (my $line = <STDIN>) {
    chomp($line);
    if (substr($line, 0, 1) ne ">") {
	$seq .= $line;
    } else {
	$count++;
	print $contig, "\t", length($seq), "\n" if ($contig ne "");
	my @f = split(" ", substr($line,1));
	$contig = $f[0];
	$seq = "";
    }
    }
print $contig, "\t", length($seq), "\n" if ($contig ne "");
($count > 0) or die "no contigs found";



