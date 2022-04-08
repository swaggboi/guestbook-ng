#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('guestbook-ng.pl');
my $t      = Test::Mojo->new($script);

$t->ua->max_redirects(0);

# This one is not spam
$t->get_ok('/message/8')->status_is(200)
    ->text_is(h2 => 'Messages from the World Wide Web');
# This one _is_ spam
$t->get_ok('/message/19')->status_is(200)
    ->text_is(h2 => 'Messages from the World Wide Web');
# This one is deleted
$t->get_ok('/message/1')->status_is(404)
    ->text_is(h2 => 'Messages from the World Wide Web');

done_testing();
