#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script       = curfile->dirname->sibling('guestbook-ng.pl');
my $t            = Test::Mojo->new($script);
my %invalid_form = (
    name    => 'swagg boi',
    url     => 'INVALID://',
    message => '',
    answer  => 'false'
    );
my %spam_form    = (
    name    => 'swagg boi',
    url     => 'http://localhost/',
    message => 'hi',
    answer  => 0
    );

$t->ua->max_redirects(1);

# Invalid input
$t->post_ok('/sign', form => \%invalid_form)->status_is(200)
    ->content_like(qr/cannot be blank/);
$t->post_ok('/sign', form => \%invalid_form)->status_is(200)
    ->content_like(qr/URL does not appear to be/);

# Spam test
$t->post_ok('/sign', form => \%spam_form)->status_is(403);

done_testing();
