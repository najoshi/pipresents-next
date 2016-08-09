#!/usr/bin/perl

my $GEOM = "1920x1080";

sub recurse_dir {
	my ($thedir) = @_;
	my $i;
	my @thefiles;


	if (-d $thedir) {
		opendir (DIR, $thedir);
		@thefiles = sort readdir (DIR);
		closedir (DIR);


		for ($i=0; $i<=$#thefiles; $i++) {
			if ($thefiles[$i] !~ /^\.+/) {
				recurse_dir ($thedir . "/" . $thefiles[$i]);
			}
		}
	}


	else {
		process_file ($thedir, 0);
	}
}


sub process_jpg {
        my ($thefile, $isincurrdir) = @_;
        my $picname;

        if ($isincurrdir == 0) {
                ($picname) = $thefile =~ /^.+\/(.+)\.jpe{0,1}g/i;
        }

        else {
                ($picname) = $thefile =~ /^(.+)\.jpe{0,1}g/i;
        }

	my $newfile = $thefile;
	$newfile =~ s/\.(jpe{0,1}g)$/.resized.$1/i;

	#system ("exifautotran \"$thefile\"");
	#system ("jhead -autorot \"$thefile\"");
	system ("convert -resize $GEOM -auto-orient \"$thefile\" \"$newfile\"");
	if (-s $newfile > 1100000) {
		system ("convert -resize $GEOM -quality 90 -auto-orient \"$thefile\" \"$newfile\"");
	}
	#system ("mv \"$thefile\" \"$newfile\"");
	system ("rm \"$thefile\"");
}

sub process_png {
        my ($thefile, $isincurrdir) = @_;
        my $picname;

        if ($isincurrdir == 0) {
                ($picname) = $thefile =~ /^.+\/(.+)\.png/i;
        }

        else {
                ($picname) = $thefile =~ /^(.+)\.png/i;
        }

        my $newfile = $thefile;
        $newfile =~ s/\.(png)$/.resized.$1/i;

        #system ("exifautotran \"$thefile\"");
	#system ("jhead -autorot \"$thefile\"");
        system ("convert -resize $GEOM -auto-orient \"$thefile\" \"$newfile\"");
	if (-s $newfile > 1100000) {
		system ("convert -resize $GEOM -quality 90 -auto-orient \"$thefile\" \"$newfile\"");
	}
        #system ("mv \"$thefile\" \"$newfile\"");
	system ("rm \"$thefile\"");
}


sub process_video {
        my ($thefile, $isincurrdir, $ext) = @_;
        my $vidname;

        if ($isincurrdir == 0) {
                ($vidname) = $thefile =~ /^.+\/(.+)\.$ext/i;
        }

        else {
                ($vidname) = $thefile =~ /^(.+)\.$ext/i;
        }

	if ($ext =~ /wmv/i) {
		my $newmp4 = $thefile;
		$newmp4 =~ s/wmv$/mp4/i;
		system ("avconv -i \"$thefile\" \"$newmp4\"");
		system ("rm \"$thefile\"");
	}

	my $rot = `mediainfo --Inform="Video;%Rotation%" "$thefile"`;
	chomp $rot;

	if ($rot == 180 || $rot == 90) {
		my $newvid = $thefile;
		$newvid =~ s/$ext$/rotated.$ext/;
		print STDERR "Rotating $rot degrees...\n";
		if ($rot == 180) {system ("avconv -i \"$thefile\" -vf \"transpose=1,transpose=1\" \"$newvid\"");}
		elsif ($rot == 90) {system ("avconv -i \"$thefile\" -vf \"transpose=1\" \"$newvid\"");}
		system ("rm \"$thefile\"");
	}
}

sub process_file {
	my ($thefile, $isincurrdir) = @_;

	print STDERR "Processing: $thefile\n";

	if ($thefile =~ /^.+\.jpe{0,1}g/i) {process_jpg ($thefile, $isincurrdir);}
	elsif ($thefile =~ /^.+\.(wmv)$/i || $thefile =~ /^.+\.(mpe{0,1}g)$/i || $thefile =~ /^.+\.(avi)$/i || $thefile =~ /^.+\.(mp4)$/i || $thefile =~ /^.+\.(mov)$/i) {process_video ($thefile, $isincurrdir, $1);}
	else {print STDERR "Error: Unknown file type for file: $thefile\n";}
}





if ($#ARGV < 0) {
	print STDERR "Usage: perl $0 [file or dir] [file or dir] ...\n\n";
	exit(1);
}



foreach $fileordir (@ARGV) {
	if ($fileordir =~ /^(.+)\/$/) {$fileordir=$1;}

	if (-d $fileordir) {
		$lsout = `ls "$fileordir" | grep -E "resized|rotated"`;
		if ($lsout eq "") {
			recurse_dir ($fileordir);
		}
		else {print STDERR "Error: Directory $fileordir seems to have already been transformed. Skipping.\n";}
	}

	else {
		process_file ($fileordir, 1);
	}
}

print "DONE!\n";
