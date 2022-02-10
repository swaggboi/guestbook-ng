#!/usr/bin/env perl

package GuestbookNg::Model::Counter;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_object) {
    bless {
        $pg       => $pg_object,
        max_posts => 5
    }
}

sub get_visitor_count($self) {
    $self->pg->db->query(<<~'END_SQL')->text()
        SELECT visitor_counter
          FROM counters
         WHERE counter_id = 1;
       END_SQL
}

sub increment_visitor_count($self) {
    $self->pg->db->query(<<~'END_SQL')->text()
        UPDATE counters
           SET visitor_counter = visitor_counter + 1
         WHERE counter_id = 1;
       END_SQL
}

1;
