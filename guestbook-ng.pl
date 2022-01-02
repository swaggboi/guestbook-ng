#!/usr/bin/env perl

# Dec 2021
# Daniel Bowling <swaggboi@slackware.uk>

use Mojolicious::Lite -signatures;
use Mojo::Pg;
use List::Util qw{shuffle};
use Regexp::Common qw{URI};
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

    $c->session();

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
    if ($c->req->method() eq 'POST') {
        my $name    = $c->param('name') || 'Anonymous';
        my $url     = $c->param('url');
        my $message = $c->param('message');
        my $spam    = $c->param('answer') ? 0 : 1;

        # No URLs in message body since they have their own field
        $spam =
            $message =~ /$RE{URI}{HTTP}{-scheme => qr<https?>}/ ? 1 : 0;

        if ($message) {
            $c->message->create_post($name, $message, $url, $spam);
            $c->redirect_to('index');
        }
        else {
            $c->flash(error => 'Message cannot be blank');
            $c->redirect_to('sign');
        }
    }
    else {
        # Try to randomize things for the CAPTCHA challenge. The
        # string 'false' actually evaluates to true so this is an
        # attempt to confuse a (hypothetical) bot that would try to
        # select what it thinks is the right answer
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

app->pg->migrations->from_dir('migrations')->migrate(5);

app->asset->store->paths(['assets']);
app->asset->process('swagg.css', 'css/swagg.css');

app->start();
