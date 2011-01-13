package List::DoubleLinked;

use strict;
use warnings FATAL => 'all';

use Carp qw/carp/;
use Scalar::Util 'weaken';
use namespace::clean;

sub new {
	my ($class, @items) = @_;
	my $self = bless {
		head => undef,
		tail => undef,
	}, $class;
	$self->unshift(@items);
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
		$self->{tail}{next} = $new_tail if $self->{tail};
		$self->{tail}       = $new_tail;
		$self->{head}       = $new_tail if not defined $self->{head};
	}
	return;
}

sub pop {
	my $self = shift;
	my $ret  = $self->{tail};
	return if not defined $ret;
	$self->{tail} = $ret->{prev};
	$self->{tail}{next} = undef if $self->{tail};
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
		$self->{head}{prev} = $new_head if $self->{head};
		$self->{head}       = $new_head;
		$self->{tail}       = $new_head if not defined $self->{tail};
	}
	return;
}

sub shift {
	my $self = CORE::shift;
	my $ret  = $self->{head};
	return if not defined $ret;
	$self->{head} = $ret->{next};
	$self->{head}{prev} = undef if $self->{tail};
	return $ret->{item};
}

sub flatten {
	my $self = CORE::shift;
	my @ret;
	for (my $current = $self->{head} ; $current ; $current = $current->{next}) {
		CORE::push @ret, $current->{item};
	}
	return @ret;
}

sub front {
	my $self = CORE::shift;
	return $self->{head} ? $self->{head}{item} : undef;
}

sub back {
	my $self = CORE::shift;
	return $self->{tail} ? $self->{tail}{item} : undef;
}

sub empty {
	my $self = CORE::shift;
	return not defined $self->{head};
}

sub size {
	my $self = CORE::shift;
	my $ret  = 0;
	for (my $current = $self->{head} ; $current ; $current = $current->{next}) {
		$ret++;
	}
	return $ret;
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
		$node->{prev}{next} = $new_node if $node->{prev};
		$node->{prev} = $new_node;

		$self->{head} = $node->{next} if $self->{head} and $self->{head} == $node;
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
		$node->{next}{prev} = $new_node if $node->{next};
		$node->{next} = $new_node;

		$self->{tail} = $new_node if $self->{tail} and $self->{tail} == $node;
		$node = $new_node;
	}
	return;
}

sub erase {
	my ($self, $node) = @_;

	$node->{prev}{next} = $node->{next} if $node->{prev};
	$node->{next}{prev} = $node->{prev} if $node->{next};

	$self->{head} = $node->{next}     if $self->{head} and $self->{head} == $node;
	$self->{tail} = $node->{previous} if $self->{tail} and $self->{tail} == $node;

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
	}
	return;
}

# ABSTRACT: Double Linked Lists for Perl

1;
