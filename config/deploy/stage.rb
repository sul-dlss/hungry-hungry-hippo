# frozen_string_literal: true

server 'sul-h3-stage.stanford.edu', user: 'h3', roles: %w[web app db]

Capistrano::OneTimeKey.generate_one_time_key!