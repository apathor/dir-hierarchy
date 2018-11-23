#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use Test::More; # tests => 13;
use File::Temp qw/tempdir/;
use File::Path qw/make_path remove_tree/;

use lib qw(./lib ../lib); # FIXME

use Dir::Hierarchy;

# semantics
my $it;

# setup a temporary directory
my $dir = tempdir();

# instances
my $hier = Dir::Hierarchy->new(
  "$dir/fqdn",
  sub { reverse split /\./, shift; },
  sub { join '.', reverse splice @_, 0, 4; }
 );

$it = ref $hier;

ok($it eq "Dir::Hierarchy",
   "A Dir::Hierarchy instance can be made.");

ok($hier->root eq "$dir/fqdn",
   "$it has a root directory.");

ok($hier->check("dirhier.test.thecompy.net"));

ok($hier->to("that") eq "that",
   "$it maps a trivial ID to a path.");

ok($hier->to("www.this.net") eq "net/this/www",
   "$it maps a typical ID to a path.");

ok($hier->from("that") eq "that",
   "$it maps a trivial path to an ID.");

ok($hier->from("net/this/www") eq "www.this.net",
   "$it maps a typical path to an ID.");

ok($hier->path("www.this.net") eq "$dir/fqdn/net/this/www",
   "$it generates a full path from an ID.");

my @all = $hier->all();
ok(@all);

# entries
my $new = $hier->add("bookmarks.thecompy.net");

ok($new,
   "Make an entry.");

ok(! ref $new,
   "Entries are a string.");

ok(-d $new,
   "Entries are directories.");

ok(! defined $hier->add(undef),
   "Some IDs are untranslatable.");

# tests done
done_testing();

# cleanup
remove_tree($dir);
