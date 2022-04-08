#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('guestbook-ng.pl');
my $t      = Test::Mojo->new($script);

$t->ua->max_redirects(0);

$t->get_ok('/spam')->status_is(200)
    ->text_is(h2 => 'Messages from the World Wide Web');
$t->get_ok('/spam/1')->status_is(200)
    ->text_is(h2 => 'Messages from the World Wide Web');

done_testing();
