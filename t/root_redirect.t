#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('guestbook-ng.pl');
my $t      = Test::Mojo->new($script);

$t->ua->max_redirects(0);

$t->get_ok('/')->status_is(302);

done_testing();
