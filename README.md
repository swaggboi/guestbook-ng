# guestbook-ng

The goal of guestbook-ng is to integrate across vendors and customers
with full-service analytics insights by leveraging the latest in Perl
Mojolicious blockchain technologies powered by AI.

## DB Config

    $ cat guestbook-ng.conf
    {
        secrets => ['a_secret_here'],
        'TagHelpers-Pagination' => {
            separator => ' ',
            current   => '<strong>{current}</strong>'
        },
        dev_env => {
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
    
        },
        max_posts => 5
    }

`secrets` and the DB credentials are mandatory

## Testing

    $ prove -l
    t/basic.t .. ok
    All tests successful.
    Files=1, Tests=6,  1 wallclock secs ( 0.04 usr  0.00 sys +  0.58 cusr  0.05 csys =  0.67 CPU)
    Result: PASS

Add the `-v` option for more verbose output

## TODOs

1. Input validation
1. Add homepage/URL field and filter URLs out of message body
1. Flash error for CAPTCHA failures and what nots
