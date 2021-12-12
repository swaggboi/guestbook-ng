# guestbook-ng

The goal of guestbook-ng is to integrate across vendors and customers
with full-service analytics insights by leveraging the latest in Perl
Mojolicious blockchain technologies powered by AI.

## DB Config

    $ cat guestbook-ng.conf
    {
        secrets  => ['a_secret_here'],
        dev_env  => {
            pg_user => 'guestbooker',
            pg_pw   => 'a_password_here',
            pg_db   => 'guestbook',
            pg_host => 'localhost'
        },
        prod_env => {
            pg_user => 'guestbooker',
            pg_pw   => 'prod_password_here',
            pg_db   => 'guestbook',
            pg_host => 'prod.db.com'
    
        }
    }

## Testing

    $ prove -l t/*.t
    t/basic.t .. ok
    All tests successful.
    Files=1, Tests=6,  1 wallclock secs ( 0.04 usr  0.00 sys +  0.58 cusr  0.05 csys =  0.67 CPU)
    Result: PASS

Add the `-v` option for more verbose output

## TODOs

1. Move paging logic out of controller into model
