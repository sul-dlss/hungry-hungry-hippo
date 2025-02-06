[![CircleCI](https://dl.circleci.com/status-badge/img/gh/sul-dlss/hungry-hungry-hippo/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sul-dlss/hungry-hungry-hippo/tree/main)
[![Test Coverage](https://codecov.io/github/sul-dlss/hungry-hungry-hippo/graph/badge.svg?token=A90V28UV39)](https://codecov.io/github/sul-dlss/hungry-hungry-hippo)

# Hungry Hungry Hippo (H3)

## Development

### Requirements

* docker & docker compose
* tmux ([installation instructions](https://github.com/tmux/tmux#installation))
* overmind ([installed automatically via bundler](https://github.com/DarthSim/overmind/tree/master/packaging/rubygems#installation-with-rails))

### Running locally

Spin up containers and the app, and then set up the application and solid-* databases:

```shell
docker compose up -d
bin/rails db:prepare db:seed spec:prepare
bin/dev
```

Then browse to http://localhost:3000 to see the running application.

#### Change default user role

You can change your abilities within the app by setting the `ROLES` environment
variable. By default you will be granted administrative abilities.

Note that you may need to clear your browser session cookies to pick up the new
roles set here, as they may be cached from a previous session. If you want to
avoid clearing _all_ your cookies, e.g. to prevent logging out of various
services, you may be able to clear cookies for specific top-level domains (e.g.
stanford.edu) by using your browser's settings (e.g. `Privacy and Security >
Cookies and Site Data > Manage Data` in Firefox). You may be able to clear
specific cookies for specific subdomains (e.g. sdr.stanford.edu) by visiting a
page at that subdomain, and using the storage inspector tool in dev tools (e.g.
`Web Developer Tools > Storage > Cookies` in Firefox).

To remove administrative capabilities and view the site as a collection creator:

```shell
ROLES=dlss:hydrus-app-collection-creators bin/dev
```

To view the site as a first-time user:

```shell
ROLES=foo:bar:whatever bin/dev
```

### Mission Control

A dashboard for Solid Queue background jobs is available at `http://localhost:3000/jobs`.

### Debugging locally

1. Add a `debugger` statement in the code.
2. Connect to the process (for example, `bin/overmind connect web` or `bin/overmind connect jobs`).

See [overmind documentation](https://github.com/DarthSim/overmind) for more about how to control processes.

### Completing accessioning workflow

accessionWF steps can be completed with:

```
bin/rake "development:accession[druid:dh414dd1590]"
```

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
CYPERFUL=1 bin/rspec spec/system/create_work_draft_spec.rb
```

In cases in which Cyperful doesn't work, temporarily using a headed test might be useful for development. For example:
```
RSpec.describe 'Manage files for a work', :headed_test do
```

### Code Linters

To run all configured linters, run `bin/rake lint`.

To run linters individually, run which ones you need:

* Ruby code: `bin/rubocop` (add `-a` flag to autocorrect violations)
* ERB templates: `bin/erb_lint --lint-all --format compact` (add `-a` flag to autocorrect violations)
* JavaScript code: `yarn run lint` (add `--fix` flag to autocorrect violations)
* SCSS stylesheets: `yarn run stylelint` (add `--fix` flag to autocorrect violations)

### Adding a new simple, non-repeatable field

A "simple" field is a single, non-repeatable value, such as a title (string) or a version
number (integer). If the field you're adding is repeatable or more complex, such as one that
has structure (e.g., a related link or work), see the following section.

1. Add the field to the appropriate form object (e.g., `app/forms/work_form.rb`), including validation.
1. Add the field to the form view (e.g., `app/views/works/form.html.erb`), including adding strings to `config/locales/en.yml`.
1. Permit the parameters in `app/controllers/works_controller`.
1. Map the field from cocina to work form in `app/services/to_work_form/mapper.rb`.
1. Map the field from work form to cocina in `app/services/to_cocina/work/mapper.rb` (or sub-mapper).
1. Add the field to the work form and cocina fixtures in `spec/support/work_mapping_fixtures.rb`.
1. Test serialization of the field in `spec/serializers/work_form_serializer_spec.rb`.
1. Test adding the field in `spec/system/create_work_deposit_spec.rb`.
1. Test editing the field in `spec/system/edit_work_spec.rb`.
1. Add the field to the work show (`app/views/works/show.html.erb`).
1. Test display of the field in `spec/system/show_work_spec.rb`.

### Adding a new nested (structured or repeatable) field

A "nested" field is one that is not "simple" (see prior section).

1. Create a new form object for the nested field (e.g., `app/forms/related_link_form.rb`), defining attributes and validations.
    * NOTE: Make sure the name of your field is in the name of your form, e.g., for a field name of `creation_date`, name the form `CreationDateForm`.
1. Add the new form to the `accepts_nested_attributes_for` list for the appropriate form object (e.g., `app/forms/work_form.rb`).
1. Create a new view component for editing the nested field (e.g., `app/components/related_links/edit_component.rb` & `app/components/related_links/edit_component.html.erb`), including adding strings to `config/locales/en.yml`.
1. Add the nested field to the form view (e.g., `app/views/works/form.html.erb`)
1. (OPTIONAL) Add a new Stimulus controller if any special interactions are needed for the new field
1. Map the field from cocina to the work and/or collection form (e.g., `app/services/to_work_form/mapper.rb`).
1. Map the field from the work and/or collection form to cocina in `app/services/to_cocina/work/mapper.rb` (or sub-mapper).
1. Add the field to the work form and cocina fixtures in `spec/support/work_mapping_fixtures.rb`.
1. Test serialization of the field in `spec/serializers/work_form_serializer_spec.rb`.
1. Test adding the field in `spec/system/create_work_deposit_spec.rb`.
1. Test editing the field in `spec/system/edit_work_spec.rb`.
1. Add the field to the work show (`app/views/works/show.html.erb`).
1. Test display of the field in `spec/system/show_work_spec.rb`.

### Adding an email
1. Publish a notification that would trigger the email. For example: `after_create -> { Notifier.publish(Notifier::DEPOSITOR_ADDED, user:, collection:) }`.
1. Add an email to a mailer controller (for example, `app/mailers/collections_mailer.rb`) and a view (for example, `app/views/collections_mailer/invitation_to_deposit_email.html.erb`).
1. Add a subscription to `config/initializers/subscriptions.rb`. For example:
    ```
    Notifier.subscribe_mailer(event_name: Notifier::DEPOSITOR_ADDED, mailer_class: CollectionsMailer, mailer_method: :invitation_to_deposit_email)
    ```
1. Test the triggering of the notification.
1. Test the email.
