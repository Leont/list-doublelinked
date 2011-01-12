package List::DoubleLinked;
use strict;
use warnings;

sub new {
	my ($class, @items) = @_;
	my $self = bless {
		head => undef,
		tail => undef,
	}, $class;
	$self->unshift(@items);
	return $self;
}

sub push {
	my ($self, @items) = @_;
	for my $item (@items) {
		my $new_tail = {
			item => $item,
			prev => $self->{tail},
			next => undef,
		};
		$self->{tail}{next} = $new_tail if $self->{tail};
		$self->{tail} = $new_tail;
		$self->{head} = $new_tail if not defined $self->{head};
	}
	return;
}

sub pop {
	my $self = shift;
	my $ret = $self->{tail};
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
		$self->{head} = $new_head;
		$self->{tail} = $new_head if not defined $self->{tail};
	}
	return;
}

sub shift {
	my $self = CORE::shift;
	my $ret = $self->{head};
	return if not defined $ret;
	$self->{head} = $ret->{next};
	$self->{head}{prev} = undef if $self->{tail};
	return $ret->{item};
}

sub flatten {
	my $self = CORE::shift;
	my @ret;
	my $current = $self->{head};
	while (defined $current) {
		CORE::push @ret, $current->{item};
		$current = $current->{next};
	}
	return @ret;
}

sub begin {
	my $self = CORE::shift;
	return List::DoubleLinked::Iterator->new($self, $self->{head});
}

sub end {
	my $self = CORE::shift;
	return List::DoubleLinked::Iterator->new($self->{tail});
}

package List::DoubleLinked::Iterator;

use Carp qw/croak carp/;
use Scalar::Util 'weaken';

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
	return __PACKAGE__->new($list, $node->{previous});
}

sub remove {
	my $self = shift;
	my ($node, $list) = @{$self};
	return if not defined $node;

	$node->{prev}{next} = $node->{next} if $node->{prev};
	$node->{next}{prev} = $node->{prev} if $node->{next};

	$list->{head} = $node->{next} if $list->{head} and $list->{head} == $node;
	$list->{tail} = $node->{previous} if $list->{tail} and $list->{tail} == $node;

	my $item = $node->{item};
	weaken $node;
	carp 'Node may be leaking' if $node;

	return $item;
}

# ABSTRACT: Double Linked Lists for Perl

1;
