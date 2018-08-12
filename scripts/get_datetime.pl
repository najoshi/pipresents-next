#!/usr/bin/perl

use Image::ExifTool qw(:Public);
use File::Basename;
use File::Copy;
use DateTime;

my %times;

my $exif = Image::ExifTool->new;
foreach $file (@ARGV) {
	$exif->ExtractInfo($file);

	print "THEFILE: $file\n";

	#print join("\n",@tags)."\n";

	my $value = $exif->GetValue('DateTimeOriginal', 'PrintConv');
	if ($value eq "") {$value = $exif->GetValue('CreateDate', 'PrintConv');}
	print "$value\n" if $value ne "";
	print "NOT FOUND!!!\n" if $value eq "";

# @thefiles = sort {$times{$a} cmp $times{$b}} @thefiles;

# foreach $file (@thefiles) {
	# my $bn = fileparse($file);
	# $fstr = sprintf ("%04d", $filenum);
	# # print "mv \"$file\" \"$dir/$fstr.$bn\"\n";
	# move ($file, "$dir/$fstr.$bn");
	# $filenum++;
# }

}
