#!/usr/bin/env perl

package GuestbookNg::Model::Test;

use strict;
use warnings;
use experimental qw{signatures};

sub new($class) {
    bless {}, $class
}

sub test_model($self, $string) {
    "you've supplied: $string"
}

1;
