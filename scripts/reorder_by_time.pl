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

		my $exif;
        my $time;
		foreach $file (@thefiles) {
            $exif = Image::ExifTool->new;
            $exif->ExtractInfo($file);
            if (($year,$month,$day,$hour,$min,$sec) = $file =~ /(\d\d\d\d)(\d\d)(\d\d)_(\d\d)(\d\d)(\d\d)\.mp4$/) {
                $time = "$year:$month:$day $hour:$min:$sec";
            } else {
			    $time = $exif->GetValue('DateTimeOriginal', 'PrintConv');
			    if ($time eq "") {$time = $exif->GetValue('CreateDate', 'PrintConv');}
			    if ($time eq "") {print STDERR "Time Not Found for file $file.\n";}
            }

            #print STDERR "$file:'$time'\n";

			if ($time !~ /^\d{4}:\d{2}:\d{2} \d{2}:\d{2}:\d{2}$/ && $time !~ /^\d{2}\/\d{2}\/\d{4} \d{1,2}:\d{2}$/) {
				print STDERR "Time $time is in an unrecognized format for file $file.\n";
			}

			if ($time =~ /^(\d{2})\/(\d{2})\/(\d{4}) (\d{1,2}):(\d{2})$/) {
				$hours = sprintf("%02d",$4);
				$time = "$3:$2:$1 $hours:$5:00";
			}
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

