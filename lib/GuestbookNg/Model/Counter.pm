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
        SELECT counter_value
          FROM counters
         WHERE counter_name = 'visitor';
       END_SQL
}

sub increment_visitor_count($self) {
    $self->pg->db->query(<<~'END_SQL')->text()
        UPDATE counters
           SET counter_value = counter_value + 1
         WHERE counter_name = 'visitor';
       END_SQL
}

1;
