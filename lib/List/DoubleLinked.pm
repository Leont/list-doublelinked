package List::DoubleLinked;

use strict;
use warnings FATAL => 'all';

use Carp qw/carp/;
use Scalar::Util 'weaken';
use namespace::clean 0.20;
#no autovivication;

sub new {
	my ($class, @items) = @_;
	my $self = bless {
		head => undef,
		tail => undef,
		size => 0,
	}, $class;
	$self->push(@items);
	return $self;
}

## no critic (Subroutines::ProhibitBuiltinHomonyms, ControlStructures::ProhibitCStyleForLoops)

sub push {
	my ($self, @items) = @_;
	for my $item (@items) {
		my $new_tail = {
			item => $item,
			prev => $self->{tail},
			next => undef,
		};
		$self->{tail}{next} = $new_tail if defined $self->{tail};
		$self->{tail}       = $new_tail;
		$self->{head}       = $new_tail if not defined $self->{head};
		$self->{size}++;
	}
	return;
}

sub pop {
	my $self = shift;
	my $ret  = $self->{tail};
	return if not defined $ret;
	$self->{tail} = $ret->{prev};
	$self->{tail}{next} = undef if defined $self->{tail};
	$self->{size}--;
	return $ret->{item};
}

sub unshift {
	my ($self, @items) = @_;
	for my $item (reverse @items) {
		my $new_head = {
			item => $item,
			prev => undef,
			next => $self->{head},
		};
		$self->{head}{prev} = $new_head if defined $self->{head};
		$self->{head}       = $new_head;
		$self->{tail}       = $new_head if not defined $self->{tail};
		$self->{size}++;
	}
	return;
}

sub shift {
	my $self = CORE::shift;
	my $ret  = $self->{head};
	return if not defined $ret;
	$self->{head} = $ret->{next};
	$self->{head}{prev} = undef if defined $self->{tail};
	$self->{size}--;
	return $ret->{item};
}

sub flatten {
	my $self = CORE::shift;
	my @ret;
	for (my $current = $self->{head} ; defined $current ; $current = $current->{next}) {
		CORE::push @ret, $current->{item};
	}
	return @ret;
}

sub front {
	my $self = CORE::shift;
	return defined $self->{head} ? $self->{head}{item} : undef;
}

sub back {
	my $self = CORE::shift;
	return defined $self->{tail} ? $self->{tail}{item} : undef;
}

sub empty {
	my $self = CORE::shift;
	return not $self->{size};
}

sub size {
	my $self = CORE::shift;
	return $self->{size};
}

sub insert_before {
	my ($self, $iter, @items) = @_;
	my $node = $iter->[0];
	for my $item (@items) {
		my $new_node = {
			item => $item,
			prev => $node->{prev},
			next => $node,
		};
		$node->{prev}{next} = $new_node if defined $node->{prev};
		$node->{prev} = $new_node;

		$self->{head} = $node->{next} if defined $self->{head} and $self->{head} == $node;
		$self->{size}++;
	}
	return;
}

sub insert_after {
	my ($self, $iter, @items) = @_;
	my $node = $iter->[0];
	for my $item (@items) {
		my $new_node = {
			item => $item,
			prev => $node,
			next => $node->{next},
		};
		$node->{next}{prev} = $new_node if defined $node->{next};
		$node->{next} = $new_node;

		$self->{tail} = $new_node if defined $self->{tail} and $self->{tail} == $node;
		$node = $new_node;
		$self->{size}++;
	}
	return;
}

sub erase {
	my ($self, $node) = @_;

	$node->{prev}{next} = $node->{next} if defined $node->{prev};
	$node->{next}{prev} = $node->{prev} if defined $node->{next};

	$self->{head} = $node->{next}     if defined $self->{head} and $self->{head} == $node;
	$self->{tail} = $node->{previous} if defined $self->{tail} and $self->{tail} == $node;

	$self->{size}--;
	weaken $node;
	carp 'Node may be leaking' if $node;

	return;
}

sub begin {
	my $self = CORE::shift;
	require List::DoubleLinked::Iterator;

	return List::DoubleLinked::Iterator->new($self, $self->{head});
}

sub end {
	my $self = CORE::shift;
	require List::DoubleLinked::Iterator;

	return List::DoubleLinked::Iterator->new($self->{tail});
}

sub DESTROY {
	my $self    = CORE::shift;
	my $current = $self->{head};
	while ($current) {
		delete $current->{prev};
		$current = delete $current->{next};
		$self->{size}--;
	}
	warn "Size of Linked List is $self->{size}, should be 0 after DESTROY" if $self->{size} != 0;
	return;
}

# ABSTRACT: Double Linked Lists for Perl

1;

=head1 SYNOPSIS

 use List::DoubleLinked;
 my $list = List::DoubleLinked->new(qw/foo bar baz/);
 $list->begin->insert_after(qw/quz/);
 $list->end->previous->erase;

=head1 DESCRIPTION

This module provides a double linked list for Perl. You should ordinarily use arrays instead of this, they are faster for almost any usage. However there is a small set of use-cases where linked lists are necessary. This module was written in particular to offer stable iterators (iterators that will remain valid even if other elements are added or removed anywhere in the list).

=method new(@elements)

Create a new double linked list. @elements is pushed to the list.

=method flatten()

Return an array containing the same values as the list does. This runs in linear time.

=method push(@elements)

Add @elements to the end of the list.

=method pop()

Remove an element from the end of the list and return it

=method unshift(@elements)

Add @elements to the start of the list.

=method shift()

Remove an element from the end of the list and return it

=method front()

Return the first element in the list

=method back()

Return the last element in the list.

=method empty()

Returns true if the list has no elements in it, returns false otherwise.

=method size()

Return the length of the list. This runs in linear time.

=method begin()

Return an iterator to the first element of the list.

=method end()

Return an iterator to the last element of the list.

=method erase($iterator)

Remove the element under $iterator.

=method insert_before($iterator, @elements)

Insert @elements before $iterator.

=method insert_after($iterator, @elements)

Insert @elements after $iterator.

