#!/usr/bin/env perl

# Dec 2021
# Daniel Bowling <swaggboi@slackware.uk>

use Mojolicious::Lite -signatures;
use Mojo::Pg;
use lib 'lib';
use GuestbookNg::Model::Test;

# Plugins
plugin 'Config';

# Helpers
helper pg => sub {
    state $pg = Mojo::Pg->new(
        'postgres://'            .
        app->config->{'pg_user'} .
        ':'                      .
        app->config->{'pg_pw'}   .
        '@'                      .
        app->config->{'pg_host'} .
        '/'                      .
        app->config->{'pg_db'}
        );
};

helper test => sub {
    state $test = GuestbookNg::Model::Test->new(pg => shift->pg)
};

helper message => sub {
    state $test = GuestbookNg::Model::Message->new(pg => shift->pg)
};

# Routes
under sub ($c) {
    $c->pg->migrations->from_dir('migrations')->migrate(1);
};

get '/' => sub ($c) {
    $c->render()
} => 'index';

any '/test' => sub ($c) {
    my $method = $c->req->method();
    my $time   = $c->test->now();
    my $string =
        $method eq 'POST' ? $c->test->test_model($c->param('string')) : undef;

    $c->render(
        method => $method,
        string => $string,
        time   => $time
        );
};

# Send it
app->start();
