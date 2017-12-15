#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

use Test::More;
use File::Temp qw/tempdir/;
use File::Path qw/remove_tree/;

use lib qw(./lib ../lib); # FIXME

use Dir::Hierarchy;

# setup a temporary directory
my $dir = tempdir();

# instances
my $hier = Dir::Hierarchy->new(
  "$dir/fqdn",
  sub { join '/', reverse split /\./, shift; },
  sub { join '.', reverse splice @_, 0, 4; }
 );

ok($hier, "Dir::Hierarchy instance");
ok($hier->root eq "$dir/fqdn", "Instantiate a Directory::Hierarchy");
ok($hier->to("that") eq "that", "Get path from single element ID.");
ok($hier->to("www.this.net") eq "net/this/www", "Get path from to path.");
ok($hier->from("that") eq "that", "Get ID from single element path.");
ok($hier->from("net/this/www") eq "www.this.net", "Get ID from path tokens.");
ok($hier->path("www.this.net") eq "$dir/fqdn/net/this/www", "Get path from ID.");

# entries
my $new = $hier->add("bookmarks.thecompy.net");
ok($new, "Make an entry.");
say keys %$new;
ok(ref $new eq 'HASH', "Entry is a hash.");
ok(ref tied %$new eq 'IO::Dir', "Entry is a tied IO::Dir.");
done_testing();

remove_tree($dir);
