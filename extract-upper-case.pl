#!/usr/bin/env perl

use strict;

my @variables;
my @commands;
my @properties;
my %keywords; # command => keyword-list


# get all variables
open(CMAKE, "cmake --help-variable-list|") or die "could not run cmake";
while (<CMAKE>) {
	chomp;
	push @variables, $_;
}
close(CMAKE);

# transform all variables in a hash - to be able to use exists later on
my %variables = map { $_ => 1 } @variables;

open(CMAKE, "cmake --help-command-list|");
while (my $cmd = <CMAKE>) {
	chomp $cmd;

	push @commands, $cmd;

	open(KW, "cmake --help-command $cmd|");
	my @word;
	while (<KW>) {

		foreach my $w (m/\b([A-Z_]{2,})\b/g) {
			next
				if (exists $variables{$w}); # skip if it is a variable
			push @word, $w;
		}
	}
	close(KW);

	next if scalar @word == 0;

	$keywords{$cmd} = [ sort keys %{ { map { $_ => 1 } @word } } ];
}
close(CMAKE);

open(CMAKE, "cmake --help-property-list|");
while (<CMAKE>) {
	chomp;
	push @properties, $_;
}
close(CMAKE);

open(IN,  "<cmake.vim.in") or die "could not read cmake.vim.in";
open(OUT, ">syntax/cmake.vim") or die "could not write to syntax/cmake.vim";

my @keyword_hi;

while(<IN>)
{
	if (m/\@(.*?)\@/) { # match for @SOMETHING@
		if ($1 eq "COMMAND_LIST") {
			print OUT " " x 12 , "\\ ", join(" ", @commands), "\n";
		} elsif ($1 eq "VARIABLE_LIST") {
			print OUT " " x 12 , "\\ ", join(" ", @variables), "\n";
		} elsif ($1 eq "KEYWORDS") {
			foreach my $k (sort keys %keywords) {
				print OUT "syn keyword cmakeKW$k\n";
				print OUT " " x 12, "\\ ", join(" ", @{$keywords{$k}}), "\n";
				print OUT " " x 12, "\\ contained\n";
				print OUT "\n";
				push @keyword_hi, "hi def link cmakeKW$k ModeMsg";
			}
		} elsif ($1 eq "KEYWORDS_HIGHLIGHT") {
			print OUT join("\n", @keyword_hi), "\n";
		} else {
			print "ERROR do not know how to replace $1\n";
		}
	} else {
		print OUT $_;
	}
}
close(IN);
close(OUT);


