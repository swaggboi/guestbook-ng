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
        my $offset    = ($this_page - 1) * $row_count;

        return $self->pg->db
            ->query(<<~'END_SQL', $row_count, $offset)->arrays();
            SELECT to_char(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message,
                   homepage_url
              FROM messages
             ORDER BY message_date DESC
             LIMIT ? OFFSET ?;
           END_SQL
    }
    else {
        return $self->pg->db->query(<<~'END_SQL')->arrays()
            SELECT to_char(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message,
                   homepage_url
              FROM messages
             ORDER BY message_date DESC;
           END_SQL
    }
}

sub create_post($self, $name, $message, $url = undef) {
    if ($url) {
        $self->pg->db->query(<<~'END_SQL', $name, $message, $url)
            INSERT INTO messages (
                                     message_date,
                                     visitor_name,
                                     message,
                                     homepage_url
                                 )
            VALUES (NOW(), ?, ?, ?);
           END_SQL
    }
    else {
        $self->pg->db->query(<<~'END_SQL', $name, $message)
            INSERT INTO messages (message_date, visitor_name, message)
            VALUES (NOW(), ?, ?);
           END_SQL
    }

    return;
}

sub max_posts($self, $value = undef) {
    return $self->{'max_posts'} = $value // $self->{'max_posts'}
}

sub get_last_page($self) {
    my $post_count = $self->get_post_count();
    my $last_page  = int($post_count / $self->{'max_posts'});

    # Add a page if we have "remainder" posts
    return $post_count % $self->{'max_posts'} ? ++$last_page : $last_page;
}

sub get_post_count($self) {
    return $self->pg->db->query('SELECT count(*) FROM messages;')->text()
}

1;
