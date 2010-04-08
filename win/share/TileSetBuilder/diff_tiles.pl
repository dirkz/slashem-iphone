#!/usr/bin/perl -w
#
# Diffs tilesets between 2 Slash'EM versions.
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

# the filenames that will be diffed
my @KEYS = qw(monsters objects other extras zap);

sub gather_tiles {
  my ($filename) = @_;
  my %tiles;
  my $tiles_ref = \%tiles;
  open TILEFILE, "<$filename" or die "could not read $filename";
  my $index = 0;
  while ($line = <TILEFILE>) {
	my ($num, $name) = ($line =~ /^# tile (\d+) \((.*)\).*/);
	if (defined $num) {
	  push @{$tiles_ref->{tiles}}, $name;
	  $tiles_ref->{names}->{$name} = $index;
	  $index++;
	}
  }
  close TILEFILE;
  return $tiles_ref;
}

sub gather_all_tiles {
  my ($tiles) = @_;
  my %tiles_result;
  foreach $key (@KEYS) {
	my $filename = $tiles->{$key};
	$filename or die "empty filename for $key";
	-e $filename or die "non-existing file for $filename";
	my $tiles_ref = gather_tiles $filename;
	$tiles_result{$key} = $tiles_ref;
  }
  return \%tiles_result;
}

sub usage {
  return <<"END";

Diffs tiles between Slash'EM / NetHack versions.

Usage:
$0 dir1 dir2

Where dir1 and dir2 are the top-level source distribution directories,
order matters because it's basically a transition path from dir1 to dir2.

END
}

#
# main
#

@ARGV == 2 or die usage;

$dirs[0] = $ARGV[0];
$dirs[1] = $ARGV[1];

defined($dirs[0]) or die usage;
defined($dirs[1]) or die usage;

my @tiles = ();

foreach $dir (@dirs) {
  my $hash = {};
  foreach $file (@KEYS) {
	$hash->{$file} = "$dir/win/share/$file.txt";
  }
  push @tiles, $hash;
}

my $tile_info1 = gather_all_tiles $tiles[0];
my $tile_info2 = gather_all_tiles $tiles[1];

foreach $key (@KEYS) {
  my $index = 0;
  foreach $tile_name1 (@{$tile_info1->{$key}->{tiles}}) {
	my $tile_name2 = $tile_info2->{$key}->{tiles}->[$index];
	if ($tile_name1 ne $tile_name2) {
	  my $index2 = $tile_info1->{$key}->{names}->{$tile_name2};
	  if (!defined $index2) {
		$index2 = "UNDEF";
	  }
	  print "$key $index $tile_name1 -> $tile_name2 ($index2)\n";
	}
	$index++;
  }
}

