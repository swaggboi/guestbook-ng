#!/usr/bin/env perl

package GuestbookNg::Model::Message;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $object) {
    bless {$pg => $object}
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

1;
