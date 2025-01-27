# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is optimized for running in development. That means it trades
# build speed for size. If we were using this for production, we might instead
# optimize for a smaller size at the cost of a slower build.

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git node-gyp pkg-config python-is-python3 curl libjemalloc2 libvips postgresql-client postgresql-contrib libpq-dev

# Install JavaScript dependencies
ARG NODE_VERSION=20.12.2
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION

# Rails app lives here
WORKDIR /app

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle config set without 'production' && \
    bundle install

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompiling assets
RUN ./bin/rails assets:precompile

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/puma", "-C", "config/puma.rb", "config.ru"]
