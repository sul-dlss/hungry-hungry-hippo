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
