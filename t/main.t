#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use File::Temp qw/tempdir/;
use File::Path qw/make_path remove_tree/;

use Dir::Hierarchy;

my $it = "Dir::Hierarchy";
my $this;

# setup a temporary directory
my $dir = tempdir();

# instance
my $hier = Dir::Hierarchy->new(
  $dir,
  sub { shift },
  sub { shift }
 );

my $id = "fizz";
ok(ref $hier eq "Dir::Hierarchy", "A ::Hierarchy instance can be made.");
ok($hier->root eq $dir, "$it has a root directory.");
ok($hier->to("foo") eq "$dir/foo", "$it maps an ID to a path.");
ok($hier->from("$dir/bar") eq "bar", "$it maps a path tokens to an ID.");
ok($this = $hier->add($id), "String entries can be added to $it instances.");
ok(ref $this eq "Path::Tiny", "$it entries are added as Path::Tiny instances.");
ok(-d $this, "$it added entries exist in the filesystem.");
ok($this = $hier->get($id), "$it entries can be retreived.");
ok(ref $this eq "Path::Tiny", "$it entries are retreived as Path::Tiny instances.");
ok(-d $this, "$it retreived entries exist in the filesystem.");
ok($hier->del($id) && ! -d $this, "$it entries can be deleted.");
ok($hier->add($_)) for (qw/foo bar qux/);
ok(scalar $hier->all == 3, "$it entries can be enumerated.");

# tests done
done_testing();

# cleanup
remove_tree($dir);
