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

sub get_posts($self, $this_page = undef) {
    if ($this_page) {
        my $row_count = $self->{'max_posts'};
        my $offset = ($this_page - 1) * $row_count;

        $self->pg->db->query(<<~'END_SQL', $row_count, $offset)->arrays();
            SELECT to_char(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message
              FROM messages
             ORDER BY message_date DESC
             LIMIT ? OFFSET ?;
           END_SQL
    }
    else {
        $self->pg->db->query(<<~'END_SQL')->arrays()
            SELECT to_char(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message
              FROM messages
             ORDER BY message_date DESC;
           END_SQL
    }
}

sub create_post($self, $name, $message) {
    $self->pg->db->query(<<~'END_SQL', $name, $message)
        INSERT INTO messages (message_date, visitor_name, message)
        VALUES (NOW(), ?, ?);
       END_SQL
}

sub max_posts($self, $value = undef) {
    $self->{'max_posts'} = $value // $self->{'max_posts'}
}

sub get_last_page($self) {
    my $post_count = get_post_count($self);

    # Add a page if we have "remainder" posts
    if ($post_count % $self->{'max_posts'}) {
        sprintf('%d', $post_count / $self->{'max_posts'}) + 1
    }
    else {
        sprintf('%d', $post_count / $self->{'max_posts'})
    }
}

sub get_post_count($self) {
    $self->pg->db->query('SELECT count(*) FROM messages;')->text()
}

1;
