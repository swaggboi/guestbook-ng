#!/usr/bin/env perl

# Dec 2021
# Daniel Bowling <swaggboi@slackware.uk>

use Mojolicious::Lite -signatures;
use lib 'lib';
use GuestbookNg::Model::Test;

my $tm = GuestbookNg::Model::Test->new();

get '/' => sub ($c) {
    $c->render()
} => 'index';

any '/test' => sub ($c) {
    my $method = $c->req->method;
    my $string = $tm->test_model($c->param('string'));

    $c->render(method => $method, string => $string);
};

app->start();
