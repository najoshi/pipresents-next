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

	@tags = $exif->GetTagList();
	#print join("\n",@tags)."\n";

	foreach $tag (@tags) {
		my $value = $exif->GetValue($tag, 'PrintConv');
		print "$tag\t$value\n";
	}

# @thefiles = sort {$times{$a} cmp $times{$b}} @thefiles;

# foreach $file (@thefiles) {
	# my $bn = fileparse($file);
	# $fstr = sprintf ("%04d", $filenum);
	# # print "mv \"$file\" \"$dir/$fstr.$bn\"\n";
	# move ($file, "$dir/$fstr.$bn");
	# $filenum++;
# }

}
