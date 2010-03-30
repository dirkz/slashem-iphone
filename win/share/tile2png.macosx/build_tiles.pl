#!/usr/bin/perl -w
#
# Builds a tileset from monsters.txt, objects.txt and other.txt
# using single tile images.
#
# (c) 2010 Dirk Zimmermann.
#
# TODO
# Make it customizable through command line options.
#

use Data::Dumper;

my $BASE_DIR = "/Users/dirk/Documents/xcode/slashem-0.0.7E7F3";

my %CONFIG = (
			  tileset_path => "/Users/dirk/Documents/roguelikes/absurd",
			  monsters => "$BASE_DIR/win/share/monsters.txt",
			  objects => "$BASE_DIR/win/share/objects.txt",
			  other => "$BASE_DIR/win/share/other.txt",
			  tile_size => {width => 128, height => 128},
			 );

my @KEYS = qw(monsters objects other extras zap);

my @PNGs;

my %EXCEPTIONS = (
				  'wall' => [
							 "cmap.wall.vertical.png", "cmap.wall.horizontal.png", "cmap.wall.top left corner.png",
							 "cmap.wall.top right corner.png", "cmap.wall.bottom right corner.png", "cmap.wall.bottom left corner.png",
							 "cmap.wall.tee down.png", "cmap.wall.tee left.png", "cmap.wall.tee right.png", "cmap.wall.tee up.png"
							]
				 );

sub filename_for_tile {
  my ($key, $name) = @_;
  $name = lc $name;
  $name =~ s/.* \/ //;
  $name =~ s/'//;

  # check for exceptions
  foreach $exc (keys %EXCEPTIONS) {
	if ($name eq $exc) {
	  my @files = @{$EXCEPTIONS{$exc}};
	  if (scalar @files > 0) {
		my $result = shift @files;
		$EXCEPTIONS{$exc} = \@files;
		print "exception $result for $name\n";
		return $result;
	  }
	}
  }

  foreach $filename (@PNGs) {
	my ($ident) = ($filename =~ /([^.]+)\.png$/);
	#print "trying $ident for $name\n";
	if ($ident eq $name) {
	  return $filename;
	}
  }
  return undef;
}

sub process_all_tiles {
  my ($key, $filename) = @_;
  open TILEFILE, "<$filename" or die "could not read $filename";
  my $index = 0;
  while ($line = <TILEFILE>) {
	my ($num, $name) = ($line =~ /^# tile (\d+) \((.*)\).*/);
	if (defined $num) {
	  my $png_filename = filename_for_tile $key, $name;
	  if (!$png_filename) {
		print "no file for $name\n";
	  }
	  #print "$index $key $png_filename\n";
	  $index++;
	}
  }
  close TILEFILE;
}

sub process_all_files {
  foreach $key (@KEYS) {
	my $filename = $CONFIG{$key};
	$filename or die "empty filename for $key";
	-e $filename or die "non-existing file for $filename";
	process_all_tiles $key, $filename
  }
}

my $tileset_path = $CONFIG{tileset_path};
opendir(my $dh, $tileset_path) || die "can't opendir $tileset_path: $!";
@PNGs = grep { /\.png$/ } readdir($dh);
closedir $dh;
print "$#PNGs png files\n";
process_all_files
