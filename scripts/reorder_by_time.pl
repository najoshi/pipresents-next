#!/usr/bin/perl

use Tk;
use Image::ExifTool qw(:Public);
use File::Basename;
use File::Copy;

my %times;

sub do_reorder {
	foreach $dir (@ARGV) {

		$filenum=1;

		if ($dir =~ /^(.+)\/$/) {$dir = $1;}

		opendir (DIR, $dir);
		@thefiles = grep {-f} map {"$dir/$_"} readdir (DIR);
		closedir (DIR);

		my $exif = Image::ExifTool->new;
		foreach $file (@thefiles) {
			$exif->ExtractInfo($file);
			my $time = $exif->GetValue('DateTimeOriginal', 'PrintConv');
			if ($time eq "") {$time = $exif->GetValue('CreateDate', 'PrintConv');}
			$times{$file} = $time;
		}

		@thefiles = sort {$times{$a} cmp $times{$b}} @thefiles;

		foreach $file (@thefiles) {
			my $bn = fileparse($file);
			$fstr = sprintf ("%04d", $filenum);
			# print "mv \"$file\" \"$dir/$fstr.$bn\"\n";
			move ($file, "$dir/$fstr.$bn");
			$filenum++;
		}

		%times = ();
	}
}


my $mw = MainWindow->new();
$mw->optionAdd('*font', 'Helvetica 20');

$mw->Label(-text => "Really reorder directories?")->pack (-expand => 1, -fill => 'both');

$mw->Button (
        -text => 'OK',
        -command => sub {do_reorder(); exit();},
)->pack (-expand => 1, -fill => 'both');

$mw->Button (
        -text => 'Cancel',
        -command => sub {exit();},
)->pack (-expand => 1, -fill => 'both');

MainLoop;

