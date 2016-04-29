#!/usr/bin/perl

use Tk;

sub do_copy {

my @dirs = split("\n", $ENV{NAUTILUS_SCRIPT_SELECTED_FILE_PATHS});

foreach $dir (@dirs) {

if ($dir =~ /^(.+)\/$/) {$dir = $1;}
($basedir) = $dir =~ /^.+\/(.+)$/;

$destdir = "/home/joshi/digital_media_frame/media/$basedir";

system ("mkdir \"$destdir\"");
system ("cp --preserve \"$dir/\"*.jpg \"$dir/\"*.JPG \"$dir/\"*.jpeg \"$dir/\"*.JPEG \"$dir/\"*.png \"$dir/\"*.PNG \"$destdir\"");

$lncom = "ln -t \"$destdir\" -s ";
@exts = ("wmv","WMV","mpg","MPG","avi","AVI","mp4","MP4","mov","MOV","mpeg","MPEG");
foreach $ext (@exts) {
	$lsout = `ls \"$dir\"/*.$ext`;
	if ($lsout ne "") {
		$lncom .= "\"$dir/\"*.$ext ";
	}
}

system ($lncom);

}

}


my $mw = MainWindow->new();
$mw->optionAdd('*font', 'Helvetica 20');

$mw->Label(-text => "Really copy directories?")->pack (-expand => 1, -fill => 'both');

$mw->Button (
        -text => 'OK',
        -command => sub {do_copy(); exit();},
)->pack (-expand => 1, -fill => 'both');

$mw->Button (
        -text => 'Cancel',
        -command => sub {exit();},
)->pack (-expand => 1, -fill => 'both');

MainLoop;

