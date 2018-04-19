package Dir::Hierarchy;
use strict;
use warnings;
use List::Util qw/first/;
use File::Path qw/make_path/;
use File::Find;
use File::Spec;

sub new {
  my($kind, $root, $to, $from) = @_;
  $root = File::Spec->rel2abs($root);
  die "ID to directory function must be a code reference.\n"
    unless (ref $to eq 'CODE');
  die "Directory to ID function must be a code reference.\n"
    unless (ref $from eq 'CODE');
  die "Could not make root directory!\n"
    unless (make_path($root));
  die "Root must be a directory.\n"
    unless (-d $root);
  my %self = (root => $root, to => $to, from => $from);
  bless \%self, $kind;
  return \%self;
}

sub to {
  my($self, $id) = @_;
  my @toks = $self->{to}->($id);
  return join '/', @toks;
}

sub from {
  my ($self, $path) = @_;
  my $root = $self->root;
  $path =~ s/^$root\///;
  my @toks = split '/', $path;
  return $self->{from}->(@toks);
}

sub root {
  my ($self) = @_;
  return $self->{root};
}

sub path {
  my($self, $id) = @_;
  my $path = $self->to($id);
  return unless $path;
  return join '/', $self->root, $path;
}

sub get {
  my ($self, $id) = @_;
  return unless($id);
  my $path = $self->path($id);
  return unless (-d $path);
  return $path;
}

sub add {
  my ($self, $id) = @_;
  return unless($id);
  my $path = $self->path($id);
  return unless $path;
  die sprintf "Could not make path %s.\n", $path
    unless (-d $path or make_path($path));
  return $path;
}

sub del {
  my ($self, $id) = @_;
  die "ID required" unless($id);
  my $path = $self->path($id);
  return unless (-d $path);
  die sprintf "Could not remove path %s.\n", $path
    unless remove_tree($path);
  return $path;
}

sub all {
  my ($self) = @_;
  my %seen;
  my $grab = sub {
    my $name = $File::Find::name;
    return unless -d $name;
    my $id = $self->from("$name");
    return unless $id;
    $seen{$id}++;
  };
  find($grab, $self->root);
  return keys %seen;
}

1;
