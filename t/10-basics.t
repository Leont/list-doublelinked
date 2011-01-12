#! perl

use strict;
use warnings FATAL => 'all';

use Test::More tests => 19;
use Test::Differences;
use List::DoubleLinked;
use Scalar::Util qw/weaken/;

my $list = List::DoubleLinked->new;

eq_or_diff [$list->flatten], [], 'List is empty';

ok $list->empty;

is $list->size, 0;

$list->push(qw/foo bar baz/);

ok !$list->empty;

is $list->size, 3;

is $list->front, 'foo';

eq_or_diff [$list->flatten], [qw/foo bar baz/], 'List has three members';

is $list->pop, 'baz';

eq_or_diff([$list->flatten], [qw/foo bar/]);

$list->unshift('quz');

eq_or_diff([ $list->flatten ], [ qw/quz foo bar/ ]);

{
	my $iter = $list->begin;

	is $iter->get, 'quz';

	$iter = $iter->next;

	is $iter->get, 'foo';

	$iter->insert_before(qw/FOO BAR/);

	is $iter->get, 'foo';

	eq_or_diff([ $list->flatten ], [ qw/quz FOO BAR foo bar/ ]);

	is $iter->previous->remove(), 'BAR';

	eq_or_diff([ $list->flatten ], [ qw/quz FOO foo bar/ ]);

	$iter->insert_after(qw/BUZ QUZ/);

	eq_or_diff([ $list->flatten ], [ qw/quz FOO foo BUZ QUZ bar/ ]);

	is $list->back, 'bar';

}

my $ref = $list->{head};
weaken $ref;
undef $list;
ok !defined $ref, 'ref should no longer be defined';

