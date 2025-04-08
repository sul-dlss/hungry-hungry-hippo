[![CircleCI](https://dl.circleci.com/status-badge/img/gh/sul-dlss/hungry-hungry-hippo/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sul-dlss/hungry-hungry-hippo/tree/main)
[![Test Coverage](https://codecov.io/github/sul-dlss/hungry-hungry-hippo/graph/badge.svg?token=A90V28UV39)](https://codecov.io/github/sul-dlss/hungry-hungry-hippo)

# Hungry Hungry Hippo (H3)

## Development

### Requirements

* docker & docker compose
* tmux ([installation instructions](https://github.com/tmux/tmux#installation))
* overmind ([installed automatically via bundler](https://github.com/DarthSim/overmind/tree/master/packaging/rubygems#installation-with-rails))

### Software architecture

H3 is a Rails application and at its core is a [Model-View-Controller (MVC) framework](https://guides.rubyonrails.org/getting_started.html#model-view-controller-basics)
with concerns that come from Rails, such as [helpers](https://guides.rubyonrails.org/action_view_helpers.html),[jobs](https://guides.rubyonrails.org/active_job_basics.html), and [mailers](https://guides.rubyonrails.org/action_mailer_basics.html).
We extend H3 to include the concerns listed below, some of which we tend to use across our
portfolio of services and some of which are unique to H3.

Unlike typical Rails applications, the source of truth for some of H3's models, particularly
the work and collection models, is not the application itself but Cocina objects hosted in
SDR. H3's software architecture reflects this by defining concerns that allow for robust and
reliable transformation between various abstractions including database-backed models, form
instances, and JSON-based Cocina objects.

<dl>
  <dt>Components</dt>
  <dd>Provide views for reusable UI elements and easier testing (from <a href="https://viewcomponent.org/">ViewComponent</a> gem)</dd>
  <dt>Forms</dt>
  <dd>Define form attributes and validation behaviors (from Rails' <a href="https://guides.rubyonrails.org/active_model_basics.html">ActiveModel</a>)</dd>
  <dt>Importers</dt>
  <dd>Import a domain object in JSON/hash format into a database-backed model (plain old Ruby objects)</dd>
  <dt>Model Synchronizers</dt>
  <dd>Synchronize changes from Cocina objects into database-backed models (plain old Ruby objects)</dd>
  <dt>Policies</dt>
  <dd>Make authorization decisions (from <a href="https://actionpolicy.evilmartians.io/">ActionPolicy</a> gem)</dd>
  <dt>Presenters</dt>
  <dd>Present objects to views, holding complex business logic (plain old Ruby objects)</dd>
  <dt>Roundtrippers</dt>
  <dd>Verify that a Cocina object can be converted to a domain model and back without loss (plain old Ruby objects)</dd>
  <dt>Serializers</dt>
  <dd>Handle de-/serialization of form objects in jobs (from Rails' <a href="https://guides.rubyonrails.org/active_job_basics.html#serializers">ActiveJob</a>)</dd>
  <dt>Services</dt>
  <dd>Execute business logic that spans various concerns, ideally with a single responsibility (plain old Ruby objects)</dd>
  <dt>SubscriptionMailers</dt>
  <dd>Deliver email notifications in response to subscriptions (plain old Ruby objects)</dd>
  <dt>Validators</dt>
  <dd>Validate forms, particularly for more complex rule sets (from Rails' <a href="https://guides.rubyonrails.org/active_model_basics.html#validations">ActiveModel validations</a>)</dd>
  <dt>Values</dt>
  <dd>Encapsulate a domain object defined by its attributes (plain old Ruby objects)</dd>
</dl>

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
variable. By default you will be granted administrative abilities. (NOTE: you
may need to clear your browser session cookies to pick up the new roles, as they
may be cached from a previous session.)

To remove administrative capabilities and view the site as a collection creator:

```shell
ROLES=dlss:hydrus-app-collection-creators bin/dev
```

To view the site as a first-time user, use a bogus role:

```shell
ROLES=foobar bin/dev
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

### Tests

#### Speeding up system tests

By default, system tests will use the headless Chrome browser driver, which supports JavaScript.

If your test doesn't use JavaScript, consider using the Rack driver, as it is much faster:
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

#### Viewing test coverage

Whenever the test suite is run, RSpec uses SimpleCov to generate test coverage reports. To view the most recent test coverage report in your browser, open `coverage/index.html`. NOTE: if the latest test run did not run against the entire test suite---e.g., if you tested a single file or directory---you should expect the coverage to appear very low.

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
