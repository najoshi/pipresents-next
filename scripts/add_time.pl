#!/usr/bin/perl

use Image::ExifTool qw(:Public);
use File::Basename;
use File::Copy;
use DateTime;

my %times;

$dir = $ARGV[0];
$filenum=1;

if ($dir =~ /^(.+)\/$/) {$dir = $1;}

opendir (DIR, $dir);
@thefiles = grep {-f} map {"$dir/$_"} readdir (DIR);
closedir (DIR);

my $exif = Image::ExifTool->new;
foreach $file (sort @thefiles) {
	$exif->ExtractInfo($file);
	my $time = $exif->GetValue('DateTimeOriginal', 'PrintConv');
	$times{$file} = $time;
	my $time2 = $exif->GetValue('DateTimeOriginal', 'ValueConv');
	print "$time2\n";
	($yr,$mn,$day,$hr,$min,$sec)=$time2=~/^(.+?):(.+?):(.+?) (.+?):(.+?):(.+?)$/;
my $dt = DateTime->new(
    year   => $yr,
    month  => $mn,
    day    => $day,
    hour   => $hr, 
    minute => $min,
    second => $sec
);

#$dt->add(hours => 13, minutes => 30);
$dt->add(hours => 3);
#$dt->subtract(hours => 1);
$newdate = sprintf "%04d:%02d:%02d %02d:%02d:%02d", $dt->year, $dt->month, $dt->day, $dt->hour, $dt->minute, $dt->second;
print "$newdate\n";

$exif->SetNewValue('DateTimeOriginal', $newdate);
$exif->WriteInfo($file);
}

# @tags = $exif->GetTagList();
# print join("\n",@tags)."\n";

# @thefiles = sort {$times{$a} cmp $times{$b}} @thefiles;

# foreach $file (@thefiles) {
	# my $bn = fileparse($file);
	# $fstr = sprintf ("%04d", $filenum);
	# # print "mv \"$file\" \"$dir/$fstr.$bn\"\n";
	# move ($file, "$dir/$fstr.$bn");
	# $filenum++;
# }
