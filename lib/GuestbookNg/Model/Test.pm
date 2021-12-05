#!/usr/bin/env perl

package GuestbookNg::Model::Test;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $object) {
    bless {$pg => $object}
}

sub test_model($self, $string) {
    "you've supplied: $string"
}

sub create_table($self) {
    $self->pg->migrations->from_dir('migrations')->migrate(1);
}

sub now($self) {
    $self->pg->db->query('SELECT NOW() AS now')->text()
}

1;
