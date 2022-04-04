#!/usr/bin/env perl

# Dec 2021
# Daniel Bowling <swaggboi@slackware.uk>

use Mojolicious::Lite -signatures;
use Mojo::Pg;
use List::Util qw{shuffle};
use Regexp::Common qw{URI};
use Number::Format qw{format_number};
#use Data::Dumper; # Uncomment for debugging

# Load the model
use lib 'lib';
use GuestbookNg::Model::Message;
use GuestbookNg::Model::Counter;

# Plugins
plugin 'Config';
plugin 'TagHelpers::Pagination';
plugin AssetPack => {pipes => [qw{Css JavaScript Combine}]};

# Helpers
helper pg => sub {
    my    $env = app->mode() eq 'development' ? 'dev_env' : 'prod_env';
    state $pg  = Mojo::Pg->new(app->config->{$env}{'pg_string'});
};

helper message => sub {
    state $message = GuestbookNg::Model::Message->new(pg => shift->pg)
};

helper counter => sub {
    state $counter = GuestbookNg::Model::Counter->new(pg => shift->pg)
};

# Routes
under sub ($c) {
    # Opt out of Google FLoC
    # https://paramdeo.com/blog/opting-your-website-out-of-googles-floc-network
    $c->res->headers->header('Permissions-Policy', 'interest-cohort=()');

    unless ($c->session('counted')) {
        $c->counter->increment_visitor_count();
        $c->session(
            expires => time() + 3600,
            counted => 1
            );
    }
    # Delete this since I was supposed to be using 'expires' instead
    # of 'expiration'; the difference is outlined here:
    # https://docs.mojolicious.org/Mojolicious/Controller#session
    delete $c->session->{'expiration'} if $c->session('expiration');

    $c->stash(status => 403) if $c->flash('error');

    $c->stash(
        post_count    => format_number($c->message->get_post_count),
        visitor_count => format_number($c->counter->get_visitor_count)
        );

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

get '/spam' => sub ($c) {
    my $this_page  = $c->param('page') || 1;
    my $last_page  = $c->message->get_last_page('spam');
    my $view_posts = $c->message->get_spam($this_page);

    $c->stash(
        view_posts => $view_posts,
        this_page  => $this_page,
        last_page  => $last_page
        );

    $c->render();
} => 'index';

any [qw{GET POST}], '/sign' => sub ($c) {
    my $v = $c->validation();

    if ($c->req->method eq 'POST' && $v->has_data) {
        my $name    = $c->param('name') || 'Anonymous';
        my $url     = $c->param('url');
        my $message = $c->param('message');
        my $spam    =
            !$c->param('answer')                                ? 1 :
            $message =~ /$RE{URI}{HTTP}{-scheme => qr<https?>}/ ? 1 :
            0;

        $v->required('name'   )->size(1,   63);
        $v->required('message')->size(2, 2000);
        $v->optional('url', 'not_empty')->size(1, 255)
            ->like(qr/$RE{URI}{HTTP}{-scheme => qr<https?>}/);

        unless ($v->has_error) {
            $c->message->create_post($name, $message, $url, $spam);

            $c->flash(error => 'This message was flagged as spam') if $spam;

            return $c->redirect_to('index');
        }
    }

    # Try to randomize things for the CAPTCHA challenge. The
    # string 'false' actually evaluates to true so this is an
    # attempt to confuse a (hypothetical) bot that would try to
    # select what it thinks is the right answer
    my @answers             = shuffle(0, 'false', undef);
    my $right_answer_label  = "I'm ready to sign (choose this one)";
    my @wrong_answer_labels = shuffle(
        "I don't want to sign (wrong answer)",
        "This is spam/I'm a bot, do not sign"
        );

    $c->stash(
        answers             => \@answers,
        right_answer_label  => $right_answer_label,
        wrong_answer_labels => \@wrong_answer_labels
        );

    $c->render();
};

# Send it
app->secrets(app->config->{'secrets'}) || die $@;

app->message->max_posts(app->config->{'max_posts'})
    if app->config->{'max_posts'};

app->pg->migrations->from_dir('migrations')->migrate(8);

app->asset->process('swagg.css', 'css/swagg.css');

app->start();
