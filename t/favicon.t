#!/usr/bin/env perl

use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('guestbook-ng.pl');
my $t      = Test::Mojo->new($script);

$t->get_ok('/android-chrome-192x192.png')->status_is(200);
$t->get_ok('/android-chrome-512x512.png')->status_is(200);
$t->get_ok('/apple-touch-icon.png'      )->status_is(200);
$t->get_ok('/favicon-16x16.png'         )->status_is(200);
$t->get_ok('/favicon-32x32.png'         )->status_is(200);
$t->get_ok('/favicon.ico'               )->status_is(200);
$t->get_ok('/robots.txt'                )->status_is(200);
$t->get_ok('/site.webmanifest'          )->status_is(200);

done_testing();
