#!/usr/bin/env perl

use strict;

my @m;
while (<STDIN>) {
	push @m, m/\b([A-Z_]{2,})\b/g;
}
print join(" ", sort keys %{ { map { $_ => 1 } @m } }), "\n";

