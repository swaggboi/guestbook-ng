FROM perl:5.34.1-slim

# Move it
WORKDIR /opt
COPY assets/ ./assets/
COPY lib/ ./lib/
COPY migrations/ ./migrations/
COPY public/ ./public/
COPY t/ ./t/
COPY templates/ ./templates/
COPY cpanfile .
COPY guestbook-ng.conf .
COPY guestbook-ng.pl .

# Dependency time
RUN apt-get update
RUN apt-get -y upgrade
RUN cpanm --installdeps .

# Test it
RUN prove -l -v

# Finish setting up the environment
ENV MOJO_REVERSE_PROXY=1
EXPOSE 3000

# Send it
CMD ["perl", "guestbook-ng.pl", "prefork", "-m", "production"]
