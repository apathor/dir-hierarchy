package Dir::Hierarchy;
# ABSTRACT: Make directory trees with a mapping function.
use strict;
use warnings;

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
  return File::Spec->catdir($self->root, @toks);
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

sub get {
  my ($self, $id) = @_;
  return unless($id);
  my $path = $self->to($id);
  return unless (-d $path);
  return path($path);
}

sub add {
  my ($self, $id) = @_;
  return unless($id);
  die unless($self->check($id));
  my $path = $self->to($id);
  return unless($path);
  die sprintf "Could not make path %s.\n", $path
    unless(-d $path or make_path($path));
  return path($path);
}

sub del {
  my ($self, $id) = @_;
  die "ID required" unless($id);
  my $path = $self->to($id);
  return unless (-d $path);
  die sprintf "Could not remove path %s.\n", $path
    unless(remove_tree($path));
  return 1;
}

sub all {
  my ($self) = @_;
  my %seen;
  my $grab = sub {
    return unless(-d && $_ ne $self->root);
    my $id = $self->from($_);
    return unless $id;
    $seen{$id}++;
  };
  find({ wanted => $grab, no_chdir => 1}, $self->root);
  return keys %seen;
}

1;

=pod

=head1 NAME

Dir::Hierarchy

=head1 SYNOPSIS



=head1 DESCRIPTION

Dir::Hierarchy is a tool for maintaining functionally defined directory trees.

=cut
