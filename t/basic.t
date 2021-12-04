#!/usr/bin/env perl

use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('guestbook-ng.pl');
my $t      = Test::Mojo->new($script);

# Just make sure we get a 200 OK for now
$t->get_ok('/')->status_is(200);
$t->get_ok('/test')->status_is(200);
$t->post_ok('/test', form => {string => 'a'})->status_is(200);

done_testing();
