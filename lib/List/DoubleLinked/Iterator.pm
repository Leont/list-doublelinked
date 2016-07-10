package List::DoubleLinked::Iterator;

use strict;
use warnings FATAL => 'all';

use Carp qw/croak/;
use Scalar::Util 'weaken';
use namespace::clean 0.20;

use overload 
	'==' => sub {
		my ($left, $right, $switch) = @_;
		return $left->[0] == $right->[0];
	},
	'!=' => sub {
		my ($left, $right, $switch) = @_;
		return $left->[0] != $right->[0];
	},
	fallback => 1;

sub new {
	my ($class, $list, $node) = @_;
	my $self = bless [ $node, $list ], $class;
	weaken $self->[0];
	Internals::SvREADONLY(@{$self}, 1);
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
	$list->erase($self);

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

=method get()

Get the value of the iterator

=method next()

Get the next iterator, this does not change the iterator itself.

=method previous()

Get the previous iterator, this does not change the iterator.

=method remove()

Remove the element from the list. This invalidates the iterator.

=method insert_before(@elements)

Insert @elements before the current iterator

=method insert_after

Insert @elements after the current iterator

=for Pod::Coverage new
