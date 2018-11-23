package Dir::Hierarchy;
# ABSTRACT: Hoodles doops
use strict;
use warnings;

use List::Util qw/first/;
use File::Path qw/make_path remove_tree/;
use File::Find;
use File::Spec;
use Path::Tiny;

sub new {
  my($kind, $root, $to, $from) = @_;
  $root = path($root)->absolute->stringify;
  die "ID to directory function must be a code reference.\n"
    unless (ref $to eq 'CODE');
  die "Directory to ID function must be a code reference.\n"
    unless (ref $from eq 'CODE');
  die "Could not make root directory!\n"
    unless (-d $root || make_path($root));
  die "Root must be a directory.\n"
    unless (-d $root);
  my %self = (root => $root, to => $to, from => $from);
  bless \%self, $kind;
  return \%self;
}

sub root {
  my ($self) = @_;
  return $self->{root};
}

sub to {
  my($self, $id) = @_;
  return unless($id);
  my @toks = $self->{to}->($id);
  return unless(@toks);
  return File::Spec->catdir(@toks);
}

sub from {
  my ($self, $path) = @_;
  return unless($path);
  my $rel = path($path)->is_relative ? $path : path($path)->relative($self->root);
  my @toks = File::Spec->splitdir($rel);
  return $self->{from}->(@toks);
}

sub check {
  my($self, $id) = @_;
  return $id eq $self->from($self->to($id));
}

sub full {
  my($self, $id) = @_;
  my $path = $self->to($id);
  return unless $path;
  return path($self->root, $path);
}

sub get {
  my ($self, $id) = @_;
  return unless($id);
  my $path = $self->full($id);
  return unless (-d $path);
  return path($path);
}

sub add {
  my ($self, $id) = @_;
  return unless($id);
  die unless $self->check($id);
  my $path = $self->full($id);
  return unless $path;
  die sprintf "Could not make path %s.\n", $path
    unless (-d $path or make_path($path));
  return $path;
}

sub del {
  my ($self, $id) = @_;
  die "ID required" unless($id);
  my $path = $self->full($id);
  return unless (-d $path);
  die sprintf "Could not remove path %s.\n", $path
    unless(remove_tree($path));
  return $path;
}

sub all {
  my ($self) = @_;
  my %seen;
  my $grab = sub {
    my $name = $File::Find::name;
    return unless(-d $name);
    my $id = $self->from($name);
    return unless $id;
    $seen{$id}++;
  };
  find($grab, $self->root);
  return keys %seen;
}

1;
