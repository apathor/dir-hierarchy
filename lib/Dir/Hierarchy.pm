package Dir::Hierarchy;
use strict;
use warnings;
use List::Util qw/first/;
use File::Path qw/make_path/;
use File::Find;
use IO::Dir;

# constructor
sub new {
  my($kind, $root, $to, $from) = @_;
  my %self = (root => $root, to => $to, from => $from);
  die "root" unless (make_path($root));
  die "to" unless (ref $to eq 'CODE');
  die "from" unless (ref $from eq 'CODE');
  bless \%self, $kind;
  return \%self;
}

sub to {
  my($self, $id) = @_;
  my $path = $self->{to}->($id);
  return $path;
}

sub from {
  my ($self, $path) = @_;
  my $id = $self->{from}->(split '/', $path);
  return $id;
}

sub root {
  my ($self) = @_;
  return $self->{root};
}

sub path {
  my($self, $id) = @_;
  my $path = $self->to($id);
  return $path ? join '/', $self->{root}, $path : undef;
}

sub add {
  my ($self, $id) = @_;
  die "ID required" unless($id);
  my $path = $self->path($id);
  return unless (make_path($path));
  return $self->get("$id");
}

sub get {
  my ($self, $id) = @_;
  die "ID required" unless($id);
  my $path = $self->path($id);
  return unless (-d $path);
  tie my %dir, 'IO::Dir', $path;
  return \%dir;
}

sub del {
  my ($self, $id) = @_;
  die "ID required" unless($id);
  # delete the given directory from the tree
}

sub list {
  my ($self) = @_;
  # list all IDs in the tree
  

}

1;
