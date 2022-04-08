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
            expiration => 1800,
            counted    => 1
            );
    }

    $c->stash(status => 403) if $c->flash('error');

    $c->stash(
        post_count    => format_number($c->message->get_post_count),
        visitor_count => format_number($c->counter->get_visitor_count)
        );

    1;
};

get '/' => sub ($c) {
    $c->redirect_to('view');
};

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

group {
    under '/message';

    get '/:message_id', [message_id => qr/[0-9]+/] => sub ($c) {
        my $message_id = $c->param('message_id');
        my @view_post  = $c->message->get_post_by_id($message_id);

        $c->stash(status => 404) unless $view_post[0];

        $c->stash(view_post => @view_post);

        $c->render();
    };
};

group {
    under '/spam';

    get '/:number', [number => qr/[0-9]+/], {number => 1} => sub ($c) {
        my $this_page  = $c->param('number');
        my $last_page  = $c->message->get_last_page('spam');
        my $view_posts = $c->message->get_spam($this_page);
        my $base_path  = $c->url_for(number => undef);

        $c->stash(
            view_posts => $view_posts,
            this_page  => $this_page,
            last_page  => $last_page,
            base_path  => $base_path
            );

        $c->render();
    };
};

group {
    under '/view';

    get '/:number', [number => qr/[0-9]+/], {number => 1} => sub ($c) {
            my $this_page  = $c->param('number');
            my $last_page  = $c->message->get_last_page('spam');
            my $view_posts = $c->message->get_spam($this_page);
            my $base_path  = $c->url_for(number => undef);

            $c->stash(
                view_posts => $view_posts,
                this_page  => $this_page,
                last_page  => $last_page,
                base_path  => $base_path
                );

            $c->render();
    };
};

# Send it
app->secrets(app->config->{'secrets'}) || die $@;

app->message->max_posts(app->config->{'max_posts'})
    if app->config->{'max_posts'};

app->pg->migrations->from_dir('migrations')->migrate(8);

app->asset->process('swagg.css', 'css/swagg.css');

app->start();
