package List::DoubleLinked::Iterator;

use strict;
use warnings FATAL => 'all';

use Carp qw/croak/;
use Scalar::Util 'weaken';
use namespace::clean;

sub new {
	my ($class, $list, $node) = @_;
	my $self = bless [ $node, $list ], $class;
	weaken $self->[0];
	return $self;
}

sub get {
	my $self = shift;
	return if not defined $self->[0];
	return $self->[0]{item};
}

## no critic (Subroutines::ProhibitBuiltinHomonyms)

sub next {
	my $self = shift;
	my ($node, $list) = @{$self};
	croak 'Node no longer exists' if not defined $node;
	return __PACKAGE__->new($list, $node->{next});
}

sub previous {
	my $self = shift;
	my ($node, $list) = @{$self};
	croak 'Node no longer exists' if not defined $node;
	return __PACKAGE__->new($list, $node->{prev});
}

sub remove {
	my $self = shift;
	my ($node, $list) = @{$self};
	croak 'Node already removed' if not defined $node;

	my $item = $node->{item};
	weaken $node;
	$list->erase($node);

	return $item;
}

sub insert_before {
	my ($self, @items) = @_;
	my ($node, $list)  = @{$self};
	return $list->insert_before($self, @items);
}

sub insert_after {
	my ($self, @items) = @_;
	my ($node, $list)  = @{$self};
	return $list->insert_after($self, @items);
}

# ABSTRACT: Double Linked List Iterators

1;
