#!/usr/bin/perl
use warnings;
use strict;
use Tk;
use Tk::JPEG;

my $GEOM = "1920x1080";

if (scalar(@ARGV) != 1) {
	print STDERR "Needs one argument.\n";
	exit();
}

my $dir = $ARGV[0];
if ($dir =~ /^(.+)\/$/) {$dir = $1;}

my $mw = new MainWindow;
$mw->geometry ("1920x1080");
my @files = <"$dir/*">;
@files = sort grep {$_ =~ /jpe{0,1}g$/i || $_ =~ /png$/i || $_ =~ /mpe{0,1}g$/i || $_ =~ /avi$/i || $_ =~ /mp4$/i || $_ =~ /mov$/i} @files;

my $filenum=0;
my $shot;
my $button;
my $entry;
my $next;
my $extra_text="";
my $filename="";
my $kept=0;
my $fr1;
my $fr2;
my $l1;
my $l2;
my $l3;
my $skipped=0;
my $basename;
my %ethash;

sub next_image {
	my ($todo) = @_;
	my ($bn) = $files[$filenum] =~ /.+\/(.+)$/;
	my $et;

	if ($todo eq "keep") {
		if ($extra_text ne "") {
			$extra_text =~ s/[\\\`]//g;
			$extra_text =~ s/\"/\'/g;
			open ($et, ">>$dir/extra_text.txt");
			print $et "$bn\n$extra_text\n";
			close ($et);
		}

		$kept++;
	}

	elsif ($todo eq "skip") {
		system ("rm \"$files[$filenum]\"");
		$skipped++;
	}

	$filenum++;
	if ($filenum == scalar(@files)) {
		if ($kept == 0) {system ("rmdir \"$dir\"");}
		exit();
	}

	($basename) = $files[$filenum] =~ /^.+\/(.+?)$/;

	$shot->blank;
	$extra_text="";
	$entry->delete(0,"end");
	if (exists $ethash{$basename}) {$entry->insert (0, $ethash{$basename});}
	$entry->focus;

	if ($files[$filenum] =~ /jpg$/i) {$filename = $files[$filenum];}
	else {$filename = "web-video-icon.jpg";}

	$l1->configure (-text => "File ".($filenum+1)."/".scalar(@files));
	$l2->configure (-text => "Kept: $kept   Skipped: $skipped");
	$l3->configure (-text => $basename);
	$shot->read($filename);
	$mw->update;

	if ($files[$filenum] =~ /mpe{0,1}g$/i || $files[$filenum] =~ /avi$/i || $files[$filenum] =~ /mp4$/i || $files[$filenum] =~ /mov$/i) {
		system ("totem \"$files[$filenum]\" 2> /dev/null");
	}
}


sub redo_image {
	if ($files[$filenum] !~ /jpg$/i && $files[$filenum] !~ /png$/i) {return;}

	my ($deg) = @_;

	my $origfile = $files[$filenum];
	$origfile =~ s/^media/\/data\/Pictures/;
	$origfile =~ s/\.resized//;

	if (!-e $origfile) {
		print STDERR "Error: Cannot find original file: $origfile\n";
		return;
	}

	system ("cp \"$origfile\" \"$files[$filenum]\"");

	#system ("eog \"$files[$filenum]\"");
	system ("exifautotran \"$files[$filenum]\"");
	system ("convert -rotate $deg -resize $GEOM \"$files[$filenum]\" \"$files[$filenum]\"");
	$shot->blank;
	$shot->read($files[$filenum]);
        $mw->update;
}



my $trf1 = `ls "$dir" | grep -E "resized|rotated"`;
chomp $trf1;
my $trf2 = `find "$dir" -type l`;
chomp $trf2;
if ($trf1 eq "" && $trf2 eq "") {
	print STDERR "No resized images or video files found. Need to transform perhaps. Exiting.\n";
	exit(1);
}

my ($etf, $etext, $fn);
if (-e "$dir/extra_text.txt") {
	open ($etf, "<$dir/extra_text.txt");
	while ($fn=<$etf>) {
		chomp $fn;
		$etext = <$etf>;
		chomp $etext;

		$ethash{$fn} = $etext;
	}
	close ($etf);

	system ("rm \"$dir/extra_text.txt\"");
}

if ($files[$filenum] =~ /jpg$/i) {$filename = $files[$filenum];}
else {$filename = "web-video-icon.jpg";}

($basename) = $files[$filenum] =~ /^.+\/(.+?)$/;

# make one Photo object and one Button and reuse them.
$fr1 = $mw->Frame()->pack(-side=>"left");
$shot = $fr1->Photo(-file => "$filename", -format => "jpeg", width=>1440); #get first one
$button = $fr1->Button(-image => $shot)->pack(-anchor=>"sw", -side=>"left", -expand=>1, -fill=>"both");
# $button = $fr1->Scrolled("Button", -scrollbars=>"s", -image => $shot)->pack();

$fr2 = $mw->Frame()->pack(-side=>"right");
$entry = $fr2->Entry(-width => 35, -textvariable=>\$extra_text, -font => "helvetica 20")->pack();
$entry->bind("<Return>" => sub {next_image ("keep");});
if (exists $ethash{$basename}) {$entry->insert (0, $ethash{$basename});}

$l1 = $fr2->Label(-text=>"File ".($filenum+1)."/".scalar(@files), -font => "helvetica 20")->pack();
$l2 = $fr2->Label(-text=>"Kept: $kept   Skipped: $skipped", -font => "helvetica 20")->pack();
$l3 = $fr2->Label(-text=>$basename, -font => "helvetica 20")->pack();

$next = $fr2->Button(-text => "Skip", -command=> sub {next_image ("skip");})->pack(-expand=>1, -fill=>"both");
$mw->bind('<Control-Key-z>', sub {next_image ("skip");});

my $redo1 = $fr2->Button(-text => "Rotate image 90 degrees clockwise", -command=> sub {redo_image(90);})->pack(-expand=>1, -fill=>"both");
my $redo2 = $fr2->Button(-text => "Rotate image 90 degrees counter-clockwise", -command=> sub {redo_image(270);})->pack(-expand=>1, -fill=>"both");
$mw->bind('<Control-Key-x>', sub {redo_image(90);});
$mw->bind('<Control-Key-b>', sub {redo_image(270);});

$entry->focus;
$mw->update;

if ($files[$filenum] !~ /jpg$/i && $files[$filenum] !~ /png$/i) {system ("totem \"$files[$filenum]\" 2> /dev/null");}

$mw->MainLoop;
