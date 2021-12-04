#!/usr/bin/env perl

package GuestbookNg::Model::Test;

use strict;
use warnings;
use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $object) {
    bless {$pg => $object}
}

sub test_model($self, $string) {
    "you've supplied: $string"
}

sub create_table($self) {
    $self->pg->migrations->from_string(
        "-- 1 up
        CREATE TABLE IF NOT EXISTS messages (
        id int,
        date timestamp with time zone,
        name varchar(255),
        msg varchar(255)
        );
        -- 1 down
        DROP TABLE messages;"
        )->migrate();
}

sub now($self) {
    $self->pg->db->query('SELECT NOW() AS now')->text()
}

1;
