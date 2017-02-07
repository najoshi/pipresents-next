#!/usr/bin/perl

use Tk;
my $mw = MainWindow->new();

my $dirstr="";

sub do_transform {

$mw->destroy;

# open ($fn, ">/tmp/tmp.sh");
# print $fn $dirstr;
# close ($fn);

# system ("/usr/bin/gnome-terminal -x echo /home/joshi/digital_media_frame/transform_media.pl $dirs; /bin/bash");
system ("/usr/bin/xterm -geometry 238x34 -hold -e /home/joshi/digital_media_frame/scripts/transform_media.pl $dirstr");
# system ("gnome-terminal -e \"bash -c /home/joshi/.local/share/nautilus/scripts/transform_wrapper.sh $dirs; bash\"");
# system ("/usr/bin/xterm -hold -e echo /home/joshi/digital_media_frame/transform_media.pl");

}

foreach $dir (@ARGV) {
        # print $fn "\"$dir\" ";
        $dirstr .= "\"$dir\" ";
}

if ($dirstr =~ /\/home\/joshi\/Pictures/) {
	$mwtext = "ERROR: PATH HAS /home/joshi/Pictures";
}

else {$mwtext = "Really transform directories?";}

$mw->optionAdd('*font', 'Helvetica 20');

$mw->Label(-text => $mwtext)->pack (-expand => 1, -fill => 'both');

if ($dirstr !~ /\/home\/joshi\/Pictures/) {
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

