#!/usr/bin/env perl

use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('guestbook-ng.pl');
my $t      = Test::Mojo->new($script);
my %form   = (
    name    => 'swagg boi',
    message => 'Ayy... lmao'
    );

$t->ua->max_redirects(10);

$t->get_ok('/')->status_is(200);
$t->get_ok('/sign')->status_is(200);
$t->post_ok('/sign', form => \%form)->status_is(200);

done_testing();
