#! perl

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Differences;
use List::DoubleLinked;

my $list = List::DoubleLinked->new;

eq_or_diff [$list->flatten], [], 'List is empty';

$list->push(qw/foo bar baz/);

eq_or_diff [$list->flatten], [qw/foo bar baz/], 'List has three members';

is $list->pop, 'baz';

eq_or_diff([$list->flatten], [qw/foo bar/]);

$list->unshift('quz');

eq_or_diff([ $list->flatten ], [ qw/quz foo bar/ ]);

my $iter = $list->begin;

is $iter->get, 'quz';

$iter = $iter->next;

is $iter->get, 'foo';

is $iter->remove(), 'foo';

eq_or_diff([ $list->flatten ], [ qw/quz bar/ ]);

done_testing;
