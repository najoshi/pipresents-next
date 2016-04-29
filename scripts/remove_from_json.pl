#!/usr/bin/perl

use Cpanel::JSON::XS;

foreach $item (@ARGV[1 .. $#ARGV]) {

$base = "+/" . $item;

if (-d $item) {

open ($et, "ls \"$item\" |");
while ($fn=<$et>) {
	chomp $fn;
#print "Adding loc: $base$fn\n";
	$locs{"$base$fn"}=1;
}
close($et);

} else {
	$locs{$base}=1;
}

}

my $json;
{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "$ARGV[0]";
  $json = <$fh>;
  close $fh;
}

$coder = Cpanel::JSON::XS->new->ascii->pretty->allow_nonref;
my $data = $coder->decode($json);

$numtracks = scalar(@{ $data->{"tracks"} });

print STDERR "Numtracks: $numtracks\n";

print <<EOT;
{
 "issue": "1.2",
 "tracks": [
EOT

$cnt=0;
$no_printed_entries=1;
for ($i=0; $i<$numtracks; $i++) {
	if (!exists $locs{$data->{"tracks"}->[$i]->{"location"}}) {
		if ($i != 0 && $no_printed_entries == 0) {print ",\n";}
		print $coder->encode($data->{"tracks"}->[$i]);
		$no_printed_entries = 0;
	} else {
		$cnt++;
	}
}

print <<EOT2;
 ]
}
EOT2

print STDERR "Number of entries removed: $cnt\n";
