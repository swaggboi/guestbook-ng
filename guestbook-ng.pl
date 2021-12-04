#!/usr/bin/env perl

# Dec 2021
# Daniel Bowling <swaggboi@slackware.uk>

use Mojolicious::Lite -signatures;

get '/' => sub ($c) {
    $c->render(template => 'index');
};

app->start();
