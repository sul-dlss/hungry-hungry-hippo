[![CircleCI](https://dl.circleci.com/status-badge/img/gh/sul-dlss/hungry-hungry-hippo/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sul-dlss/hungry-hungry-hippo/tree/main)
[![Maintainability](https://api.codeclimate.com/v1/badges/31c5ec4d948fc6e97d12/maintainability)](https://codeclimate.com/github/sul-dlss/hungry-hungry-hippo/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/31c5ec4d948fc6e97d12/test_coverage)](https://codeclimate.com/github/sul-dlss/hungry-hungry-hippo/test_coverage)

# Hungry Hungry Hippo (H3)

## Development

### Requirements

* docker & docker compose
* tmux ([installation instructions](https://github.com/tmux/tmux#installation))
* overmind ([installed automatically via bundler](https://github.com/DarthSim/overmind/tree/master/packaging/rubygems#installation-with-rails))

### Running locally

Spin up the web server, CSS asset builder, and DB container, and then set up the application and solid-* databases:

```shell
bin/dev
bin/rails db:prepare
```

Then browse to http://localhost:3000 to see the running application.

### Debugging locally

1. Add a `debugger` statement in the code.
2. Connect to the process (for example, `bin/overmind connect web`).

See [overmind documentation](https://github.com/DarthSim/overmind) for more about how to control processes.

### System tests

#### Javascript
By default, system tests will use headless Chrome, which supports javascript.

If your test doesn't use javascript, consider using Rack, as it is much faster:
```
RSpec.describe 'Create a work draft', :rack_test do
```

#### Cyperful
[Cyperful](https://github.com/stepful/cyperful) is a visual debugger for system tests. To run a system test, prepend `CYPERFUL=1`. For example:
```
CYPERFUL=1 bundle exec rspec spec/system/create_work_draft_spec.rb
```
