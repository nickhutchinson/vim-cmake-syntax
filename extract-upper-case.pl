#!/usr/bin/env perl

use strict;

my %h;
while (<STDIN>) {
	while ($_ =~ m/[^A-Za-z0-9_]([A-Z_]{2,})[^A-Za-z0-9_]/g) {
#		print $1,"\n";
		$h{$1} = 1;
	}
}
print join(" ", sort keys %h), "\n";
