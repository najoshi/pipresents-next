#!/usr/bin/perl

#use this command to find which directories do not have links
# find media -type d \! -exec test -e '{}/links.txt' \; -print

foreach $path (@ARGV) {
	if ($path =~ /^(.+)\/$/) {$path=$1;}
	print "find \"$path\" -type l -exec ls -L {} \\; > \"$path/links.txt\"\n";
	system ("find \"$path\" -type l -exec ls -L {} \\; > \"$path/links.txt\"");
}
