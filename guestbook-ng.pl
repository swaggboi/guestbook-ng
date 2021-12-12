#!/usr/bin/env perl

# Dec 2021
# Daniel Bowling <swaggboi@slackware.uk>

use Mojolicious::Lite -signatures;
use Mojo::Pg;
use lib 'lib';
use GuestbookNg::Model::Message;
use Data::Dumper; # Uncomment for debugging

# Plugins
plugin 'Config';

# Helpers
helper pg => sub {
    my $env =
        app->mode eq 'development' ? 'dev_env' : 'prod_env';

    state $pg = Mojo::Pg->new(
        'postgres://'                    .
        app->config->{$env}->{'pg_user'} .
        ':'                              .
        app->config->{$env}->{'pg_pw'}   .
        '@'                              .
        app->config->{$env}->{'pg_host'} .
        '/'                              .
        app->config->{$env}->{'pg_db'}
        );
};

helper message => sub {
    state $message = GuestbookNg::Model::Message->new(pg => shift->pg)
};

# Get the DB ready
app->pg->migrations->from_dir('migrations')->migrate(1);

# Routes
get '/' => sub ($c) {
    my $posts = $c->message->get_posts();

    $c->render(posts => $posts);
} => 'index';

any '/sign' => sub ($c) {
    if ($c->req->method() eq 'POST') {
        my $name    = $c->param('name');
        my $message = $c->param('message');

        $c->message->send_post($name, $message);
        $c->redirect_to('index');
    }
    else {
        $c->render()
    }
};

# Send it
app->secrets(app->config->{'secrets'}) || die $@;
app->start();
