#!/usr/bin/env perl

package GuestbookNg::Model::Message;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_object) {
    bless {
        $pg       => $pg_object,
        max_posts => 5
    }
}

sub get_posts($self) {
    $self->pg->db->query('SELECT date, name, msg FROM messages;')->arrays()
}

sub send_post($self, $name, $msg) {
    $self->pg->db->query(
        'INSERT INTO messages (date, name, msg)
         VALUES (NOW(), ?, ?);', $name, $msg
        )
}

sub view_posts($self, $this_page, $last_page, @posts) {
    my $last_post  = $this_page * $self->{'max_posts'} - 1;
    my $first_post = $last_post - $self->{'max_posts'} + 1;

    grep defined, @posts[$first_post..$last_post];
}

sub max_posts($self, $value = undef) {
    $self->{'max_posts'} = $value ? $value : $self->{'max_posts'}
}

sub get_last_page($self, @posts) {
    # Add a page if we have "remainder" posts
    if (scalar(@posts) % $self->{'max_posts'}) {
        sprintf('%d', scalar(@posts) / $self->{'max_posts'}) + 1
    }
    else {
        sprintf('%d', scalar(@posts) / $self->{'max_posts'})
    }
}

1;
