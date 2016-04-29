#!/usr/bin/perl

use Tk;
my $mw = MainWindow->new();

sub do_transform {

$mw->destroy;

my @dirs = split("\n", $ENV{NAUTILUS_SCRIPT_SELECTED_FILE_PATHS});

$dirstr = "";
# open ($fn, ">/tmp/tmp.sh");
foreach $dir (@dirs) {
	# print $fn "\"$dir\" ";
	$dirstr .= "\"$dir\" ";
}
# print $fn $dirstr;
# close ($fn);

# system ("/usr/bin/gnome-terminal -x echo /home/joshi/digital_media_frame/transform_media.pl $dirs; /bin/bash");
system ("/usr/bin/xterm -geometry 238x34 -hold -e /home/joshi/digital_media_frame/transform_media.pl $dirstr");
# system ("gnome-terminal -e \"bash -c /home/joshi/.local/share/nautilus/scripts/transform_wrapper.sh $dirs; bash\"");
# system ("/usr/bin/xterm -hold -e echo /home/joshi/digital_media_frame/transform_media.pl");

}

if ($ENV{NAUTILUS_SCRIPT_SELECTED_FILE_PATHS} =~ /\/data\/Pictures/) {
	$mwtext = "ERROR: PATH HAS /data/Pictures";
}

else {$mwtext = "Really transform directories?";}

$mw->optionAdd('*font', 'Helvetica 20');

$mw->Label(-text => $mwtext)->pack (-expand => 1, -fill => 'both');

if ($ENV{NAUTILUS_SCRIPT_SELECTED_FILE_PATHS} !~ /\/data\/Pictures/) {
$mw->Button (
        -text => 'OK',
        -command => sub {do_transform(); exit();},
)->pack (-expand => 1, -fill => 'both');
}

$mw->Button (
        -text => 'Cancel',
        -command => sub {exit();},
)->pack (-expand => 1, -fill => 'both');

MainLoop;

