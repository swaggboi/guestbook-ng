#!/usr/bin/env perl

package GuestbookNg::Model::Message;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_object) {
    bless {
        $pg       => $pg_object,
        max_posts => 5
    }, $class
}

sub get_posts($self, $this_page = undef) {
    if ($this_page) {
        my $row_count = $self->{'max_posts'};
        my $offset    = ($this_page - 1) * $row_count;

        $self->pg->db->query(<<~'END_SQL', $row_count, $offset)->arrays();
            SELECT TO_CHAR(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message,
                   homepage_url,
                   message_id
              FROM messages
             WHERE NOT is_spam
             ORDER BY message_date DESC
             LIMIT ? OFFSET ?;
           END_SQL
    }
    else {
        $self->pg->db->query(<<~'END_SQL')->arrays()
            SELECT TO_CHAR(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message,
                   homepage_url,
                   message_id
              FROM messages
             WHERE NOT is_spam
             ORDER BY message_date DESC;
           END_SQL
    }
}

sub get_spam($self, $this_page = undef) {
    if ($this_page) {
        my $row_count = $self->{'max_posts'};
        my $offset    = ($this_page - 1) * $row_count;

        $self->pg->db->query(<<~'END_SQL', $row_count, $offset)->arrays();
            SELECT TO_CHAR(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message,
                   homepage_url,
                   message_id
              FROM messages
             WHERE is_spam
             ORDER BY message_date DESC
             LIMIT ? OFFSET ?;
           END_SQL
    }
    else {
        $self->pg->db->query(<<~'END_SQL')->arrays()
            SELECT TO_CHAR(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
                   visitor_name,
                   message,
                   homepage_url,
                   message_id
              FROM messages
             WHERE is_spam
             ORDER BY message_date DESC;
           END_SQL
    }
}

sub create_post($self, $name, $message, $url = undef, $spam = 1) {
    my $message_id = $self->get_last_message_id();

    if ($url) {
        $self->pg->db->query(<<~'END_SQL', $name, $message, $url, $spam)
            INSERT INTO messages (visitor_name, message, homepage_url, is_spam)
            VALUES (?, ?, ?, ?);
           END_SQL
    }
    else {
        $self->pg->db->query(<<~'END_SQL', $name, $message, $spam)
            INSERT INTO messages (visitor_name, message, is_spam)
            VALUES (?, ?, ?);
           END_SQL
    }

    ++$message_id;
}

sub max_posts($self, $value = undef) {
    $self->{'max_posts'} = $value // $self->{'max_posts'}
}

sub get_last_page($self, $want_spam = undef) {
    my $post_count = $want_spam ? $self->get_spam_count() : $self->get_post_count();
    my $last_page  = int($post_count / $self->{'max_posts'});

    # Add a page if we have "remainder" posts
    $post_count % $self->{'max_posts'} ? ++$last_page : $last_page;
}

sub get_post_count($self) {
    $self->pg->db->query(<<~'END_SQL')->text()
        SELECT COUNT(*)
          FROM messages
         WHERE NOT is_spam;
       END_SQL
}

sub get_spam_count($self) {
    $self->pg->db->query(<<~'END_SQL')->text()
        SELECT COUNT(*)
          FROM messages
         WHERE is_spam;
       END_SQL
}

sub get_post_by_id($self, $message_id) {
    $self->pg->db->query(<<~'END_SQL', $message_id)->array()
        SELECT TO_CHAR(message_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY'),
               visitor_name,
               message,
               homepage_url,
               message_id
          FROM messages
         WHERE message_id = ?;
       END_SQL
}

sub get_last_message_id($self) {
    $self->pg->db->query(<<~'END_SQL')->text()
        SELECT MAX(message_id)
          FROM messages;
       END_SQL
}

1;
