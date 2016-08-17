package List::DoubleLinked::Iterator;

use strict;
use warnings FATAL => 'all';

use Carp qw//;
use Scalar::Util qw//;

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
	my ($class, $node) = @_;
	my $self = bless [ $node ], $class;
	Scalar::Util::weaken($self->[0]);
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
	my $node  = $self->[0];
	Carp::croak('Node no longer exists') if not defined $node;
	return __PACKAGE__->new($node->{next});
}

sub previous {
	my $self = shift;
	my $node  = $self->[0];
	Carp::croak('Node no longer exists') if not defined $node;
	return __PACKAGE__->new($node->{prev});
}

sub insert_before {
	my ($self, @items) = @_;
	my $node  = $self->[0];
	for my $item (reverse @items) {
		my $new_node = {
			item => $item,
			prev => $node->{prev},
			next => $node,
		};
		$node->{prev}{next} = $new_node;
		$node->{prev} = $new_node;

		$node = $new_node;
	}
	return;
}

sub insert_after {
	my ($self, @items) = @_;
	my $node  = $self->[0];
	for my $item (@items) {
		my $new_node = {
			item => $item,
			prev => $node,
			next => $node->{next},
		};
		$node->{next}{prev} = $new_node;
		$node->{next} = $new_node;

		$node = $new_node;
	}
	return;
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
