#!/usr/bin/perl -w
#
# Builds tileset from 2 Slash'EM versions, interweaving new tiles from version 2 into
# an existing tileset.
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
			  tile_size => {width => 32, height => 32},
			  columns => 38,
			 );

my @KEYS = qw(monsters objects other);

GetOptions(
		   'tileset=s' => \$CONFIG{tileset_path},
		   'base=s' => \$CONFIG{base_dir},
		   'patch=s' => \$CONFIG{patch_dir},
		   'output=s' => \$CONFIG{output_filename},
		   'replacement-png=s' => \$CONFIG{replacement_png},
		  );

sub usage {
  return <<"END";

Builds tiles from existing tileset and distribution,
interweaving tiles from a patch.

Usage:
$0
  --tileset <tileset>
  --base <distribution>
  --patch <distribution>
  --output <filename.png>
  [--replacement-png <filename.png>]

tileset Complete path to the original tileset (.png)
base Distribution base directory
patch Patched distribution base directory
output Output filename
replacement-png Optional filename of png file to replace unmatched tiles
                (must match tilesize)

END
}

# gathers all tilenames from a given .txt file and returns them as array
sub gather_tilenames {
  my ($filename) = @_;
  my @tiles = ();
  open TILEFILE, "<$filename" or die "could not read $filename";
  while ($line = <TILEFILE>) {
	my ($num, $name) = ($line =~ /^# tile (\d+) \((.*)\).*/);
	if (defined $num) {
	  push @tiles, $name;
	}
  }
  close TILEFILE;
  return @tiles;
}

# creates pngs from a given filename and returns them as array
sub create_tiles {
  my (@tilenames) = @_;
  my @pngs;
  my ($tile_width, $tile_height) = ($CONFIG{tile_size}->{width}, $CONFIG{tile_size}->{height});
  my $tileset = GD::Image->new($CONFIG{tileset_path});
  my ($width,$height) = $tileset->getBounds();
  my ($x, $y) = (0,0);
  my $index = 0;
  for $filename (@tilenames) {
	#print "tile #$index $x,$y\n";
	my $tile = new GD::Image($tile_width, $tile_height);
	$tile->copy($tileset, 0, 0, $x, $y, $tile_width, $tile_height);
	my $png = {
			   index => $index,
			   name => $filename,
			   tile => $tile,
			  };
	push @pngs, $png;
	$index++;
	$x += $tile_width;
	if ($x >= $width) {
	  $x = 0;
	  $y += $tile_height;
	}
  }
  return @pngs;
}

# gathers pngs (hashes with additional info) from all tiles and returns them as array
sub gather_all_pngs {
  my ($tiles) = @_;
  -e $CONFIG{tileset_path} or die "$CONFIG{tileset_path} does not exist";
  my @all_tiles;
  foreach $key (@KEYS) {
	my $filename = $tiles->{$key};
	$filename or die "empty filename for $key";
	-e $filename or die "non-existing file for $filename";
	my @tiles = gather_tilenames $filename;
	push @all_tiles, @tiles;
  }
  my $num_tiles = @all_tiles;
  print "$num_tiles tiles\n";
  my @tiles = create_tiles @all_tiles;
  return @tiles;
}

sub build_tiles {
  my ($pngs, $dirs) = @_;
  my @all_tiles;
  foreach $key (@KEYS) {
	my $filename = $dirs->{$key};
	$filename or die "empty filename for $key";
	-e $filename or die "non-existing file for $filename";
	my @tiles = gather_tilenames $filename;
	push @all_tiles, @tiles;
  }
  my $num_tiles = @all_tiles;
  print "$num_tiles new tiles\n";

  # create replacement png if desired
  my $replacement_filename = $CONFIG{replacement_png};
  my $replacement_tile = undef;
  if ($replacement_filename) {
	$replacement_tile = GD::Image->new($replacement_filename);
	if (!$replacement_tile) {
	  die "Could not load $replacement_filename";
	}
  }

  # build tile lookup
  my %tile_lookup;
  for $png_info (@$pngs) {
	$tile_lookup{$png_info->{name}} = $png_info->{tile};
  }

  my $tile_count = @all_tiles;
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
  for $tilename (@all_tiles) {
	$tile_image = $tile_lookup{$tilename};
	if (!defined $tile_image) {
	  print "no match for $tilename\n";
	  if ($replacement_tile) {
		$image->copy($replacement_tile, $x, $y, 0, 0, $tile_width, $tile_height);
	  }
	} else {
	  $image->copy($tile_image, $x, $y, 0, 0, $tile_width, $tile_height);
	}
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

defined $CONFIG{tileset_path} or die usage;
defined $CONFIG{base_dir} or die usage;
defined $CONFIG{patch_dir} or die usage;
defined $CONFIG{output_filename} or die usage;

my @dist_dirs;

for $key ('base_dir', 'patch_dir') {
  my %dirs;
  for $file (@KEYS) {
	$dirs{$file} = "$CONFIG{$key}/win/share/$file.txt";
  }
  push @dist_dirs, \%dirs;
}

my @pngs = gather_all_pngs $dist_dirs[0];
# for $png (@pngs) {
#   print "png $png->{index} $png->{name} $png->{tile}\n";
# }

build_tiles \@pngs, $dist_dirs[1];
