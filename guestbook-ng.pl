#!/usr/bin/env perl

# Dec 2021
# Daniel Bowling <swaggboi@slackware.uk>

use Mojolicious::Lite -signatures;
use Mojo::Pg;
use List::Util qw{shuffle};
use Data::Dumper; # Uncomment for debugging

# Load the model
use lib 'lib';
use GuestbookNg::Model::Message;

# Plugins
plugin 'Config';
plugin 'TagHelpers::Pagination';
plugin AssetPack => {pipes => [qw{Css JavaScript Combine}]};

# Helpers
helper pg => sub {
    my $env = app->mode() eq 'development' ? 'dev_env' : 'prod_env';

    state $pg = Mojo::Pg->new(
        'postgres://'                  .
        app->config->{$env}{'pg_user'} .
        ':'                            .
        app->config->{$env}{'pg_pw'}   .
        '@'                            .
        app->config->{$env}{'pg_host'} .
        '/'                            .
        app->config->{$env}{'pg_db'}
        );
};

helper message => sub {
    state $message = GuestbookNg::Model::Message->new(pg => shift->pg)
};

# Routes
under sub ($c) {
    # Opt out of Google FLoC
    # https://paramdeo.com/blog/opting-your-website-out-of-googles-floc-network
    $c->res->headers->header('Permissions-Policy', 'interest-cohort=()');

    1;
};

get '/' => sub ($c) {
    my $this_page  = $c->param('page') || 1;
    my $last_page  = $c->message->get_last_page();
    my $view_posts = $c->message->get_posts($this_page);

    $c->stash(
        view_posts => $view_posts,
        this_page  => $this_page,
        last_page  => $last_page
        );

    $c->render();
} => 'index';

any [qw{GET POST}], '/sign' => sub ($c) {
    if ($c->param('name') && $c->param('message')) {
        my $name    = $c->param('name');
        my $message = $c->param('message');
        my $answer  = $c->param('answer');

        $c->message->create_post($name, $message) if $answer;
        $c->redirect_to('index');
    }
    else {
        my @answers             = shuffle(0, 'false', undef);
        my $right_answer_label  = 'I\'m ready to sign (choose this one)';
        my @wrong_answer_labels = shuffle(
            'I don\'t want to sign (wrong answer)',
            'This is spam/I\'m a bot, do not sign'
            );

        $c->stash(
            answers             => \@answers,
            right_answer_label  => $right_answer_label,
            wrong_answer_labels => \@wrong_answer_labels
            );

        $c->render();
    }
};

# Send it
app->secrets(app->config->{'secrets'}) || die $@;

app->message->max_posts(app->config->{'max_posts'})
    if app->config->{'max_posts'};

app->pg->migrations->from_dir('migrations')->migrate(4);

app->asset->store->paths(['assets']);
app->asset->process('swagg.css', 'css/swagg.css');

app->start();
