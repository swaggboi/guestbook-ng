# guestbook-ng

The goal of guestbook-ng is to integrate across vendors and customers
with full-service analytics insights by leveraging the latest in Perl
Mojolicious blockchain technologies powered by AI.

## DB Config

    $ cat guestbook-ng.conf
    {
        secrets => ['secret_goes_here'],
        'TagHelpers-Pagination' => {
            separator => '',
            current   => '<strong><u>{current}</u></strong>',
            next      => 'Next',
            prev      => 'Prev',
            ellipsis  => '..'
        },
        dev_env => {
            pg_string => 'postgresql://user:PASSWORD@example.com/db'
        },
        prod_env => {
            pg_string => 'postgresql://user:PASSWORD@example.com/db'
        },
        max_posts => 5
    }

`secrets` and the Postgres connection string are mandatory

## Discord Webhook

If you provide a file in the same directory called `.tom.url`
containing a Discord Webhook URL then a notification will go out when
someone signs the Guestbook. If you're using Docker but don't want the
Webhook behavior, just create an empty file to make the Docker build
work:

    $ touch .tom.url

## Testing

    $ prove -l
    t/basic.t .. ok
    All tests successful.
    Files=1, Tests=6,  1 wallclock secs ( 0.04 usr  0.00 sys +  0.58 cusr  0.05 csys =  0.67 CPU)
    Result: PASS

Add the `-v` option for more verbose output

## Docker

### Build

    docker build -t guestbook-ng .

### Tag

    podman tag guestbook-ng git.minimally.online/swaggboi/guestbook-ng

### Push

    docker push git.minimally.online/swaggboi/guestbook-ng

### Pull

    podman pull git.minimally.online/swaggboi/guestbook-ng

### Run

    podman run -dt --rm --name guestbook-ng -p 3001:3000 guestbook-ng:latest

### Generate unit file

    podman generate systemd --files --new --name guestbook-ng

## TODOs

1. Do something about the hardcoded URL in Webhook stuff
