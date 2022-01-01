#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('guestbook-ng.pl');
my $t      = Test::Mojo->new($script);
my %form   = (
    name    => 'swagg boi',
    url     => 'http://localhost',
    message => 'Ayy... lmao',
    answer  => 'false'
    );

$t->get_ok('/')->status_is(200)
    ->text_is(h2 => 'Messages from the World Wide Web');
$t->get_ok('/sign')->status_is(200)->text_is(h2 => 'Sign the Guestbook');
$t->post_ok('/sign', form => \%form)->status_is(302);

done_testing();
