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

# instances
my $triv = Dir::Hierarchy->new(
  "$dir/basic",
  sub { shift },
  sub { shift }
 );

ok(ref $triv eq "Dir::Hierarchy", "A ::Hierarchy instance can be made.");
ok($triv->root eq "$dir/basic", "$it has a root directory.");
ok($triv->to("foo") eq "foo","$it maps a trivial ID to tokens.");
ok($triv->from("bar") eq "bar", "$it maps path tokens to an ID.");
ok($triv->full("qux") eq "$dir/basic/qux","$it maps an ID to a path.");

my $id = "fizz";
ok($this = $triv->add($id), "String entries can be added to $it instances.");
ok(ref $this eq "Path::Tiny", "$it entries are added as Path::Tiny instances.");
ok(-d $this, "$it added entries exist in the filesystem.");
ok($this = $triv->get($id), "$it entries can be retreived.");
ok(ref $this eq "Path::Tiny", "$it entries are retreived as Path::Tiny instances.");
ok(-d $this, "$it retreived entries exist in the filesystem.");
ok($triv->del($id) && ! -d $this, "$it entries can be deleted.");

$triv->add($_) for (qw/foo bar qux/);
my @those = $triv->all();
ok($triv->all(), "$it entries can be enumerated.");

# tests done
done_testing();

# cleanup
remove_tree($dir);
