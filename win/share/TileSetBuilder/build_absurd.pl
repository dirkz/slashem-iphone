#!/usr/bin/perl -w
#
# Maps monsters.txt, objects.txt and other.txt from vanilla Slash'EM 0.0.7E7F3
# to the absurd tileset single images (128x128) version and builds a tileset.png.
#
# Copyright 2010 Dirk Zimmermann.
#

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, version 2
# of the License.
 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use Data::Dumper;
use GD;
use POSIX qw(ceil);
use Getopt::Long;

my %CONFIG = (
			  tile_size => {width => 128, height => 128},
			  columns => 38,
			 );

GetOptions(
		   'tileset=s' => \$CONFIG{tileset_path},
		   'base=s' => \$CONFIG{base_dir},
		   'output=s' => \$CONFIG{output_filename},
		  );

sub usage {
  return <<"END";

Builds Absurd Tileset from given distribution and single tiles. Supports Jedi tiles.
Note that ALL single tile filenames have to be lowercase.

Usage:
$0
  --tileset <tileset>      # Complete path to the Absurd single tiles
  --base <distribution>    # Distribution base directory
  --output <filename.png>  # Output filename

END
}

defined $CONFIG{tileset_path} or die usage;
defined $CONFIG{base_dir} or die usage;
defined $CONFIG{output_filename} or die usage;

$CONFIG{tileset_path} = "/Users/dirk/Documents/roguelikes/absurd single tiles";
$CONFIG{monsters} = "$CONFIG{base_dir}/win/share/monsters.txt";
$CONFIG{objects} = "$CONFIG{base_dir}/win/share/objects.txt";
$CONFIG{other} = "$CONFIG{base_dir}/win/share/other.txt";

my @KEYS = qw(monsters objects other);

my %EXCEPTIONS = (
				  'wall' => [
							 "cmap.wall.vertical.png", "cmap.wall.horizontal.png", "cmap.wall.top left corner.png",
							 "cmap.wall.top right corner.png", "cmap.wall.bottom left corner.png", "cmap.wall.bottom right corner.png",
							 "cmap.wall.crosswall.png",
							 "cmap.wall.tee up.png", "cmap.wall.tee down.png", "cmap.wall.tee left.png", "cmap.wall.tee right.png",
							 "cmap.effect.vertical beam.png", "cmap.effect.horizontal beam.png", "cmap.effect.left slant beam.png",
							 "cmap.effect.right slant beam.png"
							],
				  'open door' => ["cmap.door.vertical open door.png", "cmap.door.horizontal open door.png"],
				  'closed door' => ["cmap.door.vertical closed door.png", "cmap.door.horizontal closed door.png"],
				  'lowered drawbridge' => ["cmap.lowered drawbridge.vertical.png", "cmap.lowered drawbridge.horizontal.png"],
				  'raised drawbridge' => ["cmap.raised drawbridge.vertical.png", "cmap.raised drawbridge.horizontal.png"],
				  'thrown boomerang, open left' => ["cmap.effect.thrown boomerang.open left.png"],
				  'thrown boomerang, open right' => ["cmap.effect.thrown boomerang.open right.png"],
				 );

my @DIRECTIONS = (
				  "top left",
				  "top center",
				  "top right",
				  "middle left",
				  "middle center",
				  "middle right",
				  "bottom left",
				  "bottom center",
				  "bottom right",
				 );

my @ZAP_TYPES = (
				 "magic missile",
				 "fire",
				 "cold",
				 "sleep",
				 "death",
				 "lightning",
				 "poison gas",
				 "acid"
				);

my @ZAP_DIRECTIONS = (
					  "vertical",
					  "horizontal",
					  "left slant",
					  "right slant"
					 );

my @WALLS = (
			 "vertical",
			 "horizontal",
			 "top left corner",
			 "top right corner",
			 "bottom left corner",
			 "bottom right corner",
			 "crosswall",
			 "tee up",
			 "tee down",
			 "tee left",
			 "tee right"
			);

sub filename_for_tile {
  my ($key, $name, $index) = @_;
  $name = lc $name;
  $name =~ s/.* \/ //; # only look at last part of components separated by slashes
  $name =~ s/'//; # remove all '

  #print "looking for $name\n";

  # zaps
  my ($type, $direction) = ($name =~ /zap (\d) (\d)/);
  if (defined($type) && defined($direction)) {
	return "zap.$ZAP_TYPES[$type].$ZAP_DIRECTIONS[$direction].png";
  }

  # explosions
  ($type, $direction) = ($name =~ /explosion ([a-z]+) (\d)/);
  if (defined($type) && defined($direction)) {
	return "explosion.$type.$DIRECTIONS[$direction].png";
  }

  # swallow
  ($direction) = ($name =~ /swallow (.+)/);
  if (defined($direction)) {
	return "cmap.swallow.$direction.png";
  }

  # warnings
  ($type) = ($name =~ /warning (\d)/);
  if (defined($type)) {
	return "warning.$type.png";
  }

  # walls
  my ($dungeon, $wall) = ($name =~ /sub (mine|gehennom|knox|sokoban) walls (\d)/);
  if (defined($dungeon) && defined($wall)) {
	return "cmap.wall.$WALLS[$wall].$dungeon.png";
  }

  # check for other exceptions
  if ($EXCEPTIONS{$name}) {
	my @files = @{$EXCEPTIONS{$name}};
	if (scalar @files > 0) {
	  my $result = shift @files;
	  $EXCEPTIONS{$name} = \@files;
	  #print "$index exception $result for $name\n";
	  return $result;
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
  my $error = undef;
  my @png_files;
  open TILEFILE, "<$filename" or die "could not read $filename";
  my $index = 0;
  while ($line = <TILEFILE>) {
	my ($num, $name) = ($line =~ /^# tile (\d+) \((.*)\).*/);
	if (defined $num) {
	  my $png_filename = filename_for_tile $key, $name, $index;
	  #print "$png_filename\n";
	  if ($png_filename && -e "$CONFIG{tileset_path}/$png_filename") {
		push @png_files, $png_filename;
		$index++;
	  } else {
		$error = 1;
		print STDERR "no file for $index $name\n";
	  }
	}
  }
  close TILEFILE;
  if ($error) {
	die "Aborting due to missing tiles";
  }
  @png_files;
}

sub process_all_files {
  my @png_files;
  foreach $key (@KEYS) {
	my $filename = $CONFIG{$key};
	$filename or die "empty filename for $key";
	-e $filename or die "non-existing file for $filename";
	my @pngs = process_all_tiles $key, $filename;
	push @png_files, @pngs;
  }
  @png_files;
}

sub create_tileset_image {
  my ($pngs) = @_;

  # init
  my @pngs = @$pngs;
  my $tile_count = @pngs;
  my ($tile_width, $tile_height) = ($CONFIG{tile_size}->{width}, $CONFIG{tile_size}->{height});
  my $columns = $CONFIG{columns};
  my $rows = ceil($tile_count / $columns);
  my $tileset_count = $columns * $rows;
  my ($width, $height) = ($columns * $tile_width, $rows * $tile_height);

  # create empty image
  print "creating ${columns}x$rows ($tile_count of $tileset_count max) ${tile_width}x$tile_height tiles in ${width}x$height image\n";
  my $image = new GD::Image($width, $height, 1) or die "Could not create image tileset";
  my ($x, $y) = (0,0);

  # transparent background
  my $transp = $image->colorAllocateAlpha(255,255,255, 0x7f);
  $image->alphaBlending(0);
  $image->filledRectangle(0, 0, $width, $height, $transp);
  $image->alphaBlending(1);
  $image->saveAlpha(1);

  # generate
  foreach $filename (@pngs) {
	my $img = GD::Image->newFromPng($filename, 1);
	$image->copy($img, $x, $y, 0, 0, $tile_width, $tile_height);
	$x += $tile_width;
	if ($x >= $width) {
	  $x = 0;
	  $y += $tile_height;
	}
  }

  # write file
  my $png_blob = $image->png();
  my $image_filename = $CONFIG{output_filename};
  print "writing $image_filename ...\n";
  open PNGFILE, ">$image_filename" or die "could not save to $image_filename: $!";
  binmode PNGFILE;
  print PNGFILE $png_blob;
  close PNGFILE;
  undef $png_blob;
  undef $image;
}

my $tileset_path = $CONFIG{tileset_path};
opendir(my $dh, $tileset_path) || die "can't opendir $tileset_path: $!";
@PNGs = grep { /\.png$/ } readdir($dh);
closedir $dh;
my @pngs = process_all_files;

my @png_files = map { "$CONFIG{tileset_path}/$_" } @pngs;

create_tileset_image \@png_files;

exit;

foreach $png_file (@png_files) {
  print "$png_file\n";
}
