#!/usr/bin/perl -w  
use Tk;
use strict;

my $file_str = "";

foreach my $file (@ARGV) {
	$file_str .= "\"$file\" ";
}

my $du_out;
if (scalar(@ARGV) == 1) {
	$du_out = `du -sh $file_str`;
	chomp $du_out;
} else {
	$du_out = `du -shc $file_str | tail -1`;
	chomp $du_out;
	$du_out = scalar(@ARGV) . " items selected\n" . $du_out;
}

my $num_files = `find $file_str -type f | wc -l`;
chomp $num_files;

my $text_label;
if ($num_files == 1) {$text_label = "$num_files file\n$du_out";}
else {$text_label = "$num_files files\n$du_out";}

my $mw = MainWindow->new(title => 'Disk Usage');
$mw->optionAdd('*font', 'Helvetica 20');

$mw->Label(-text => $text_label)->pack (-expand => 1, -fill => 'both');

$mw->Button (
	-text => 'OK',
	-command => sub {exit();},
)->pack (-expand => 1, -fill => 'both');

MainLoop;
