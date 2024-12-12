# frozen_string_literal: true

# Concern for handling authentication.
# Note that this concern is based on the generated code.
module Authentication
  extend ActiveSupport::Concern

  # Apache is configured so that:
  # - /webauth/login requires a shibboleth authenticated user. Thus, redirecting a user to it triggers login.
  # - /Shibboleth.sso/Logout logs the user out of shibboleth.
  # - /queues is limited to members of the sdr:developer group.
  # - Other pages do not require authentication.
  # - It provides the following request headers:
  #  - X-Remote-User
  #  - X-Groups
  #  - X-Person-Name (first name)
  #  - X-Person-Formal-Name (full name)

  SHIBBOLETH_LOGOUT_PATH = '/Shibboleth.sso/Logout'

  included do
    # authentication will be called before require_authentication.
    # It will authenticate the user if there is a user.
    # This will be called for all controller actions.
    # require_authentication will also be called for all controller actions,
    # unless skipped with allow_unauthenticated_access.
    before_action :authentication, :require_authentication, :set_current_groups, :set_current_orcid
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  def current_user
    Current.user
  end

  private

  def remote_user
    return Settings.seed_user.email_address if Rails.env.development?

    request.headers[Settings.http_headers.remote_user]
  end

  def authenticated?
    remote_user.present?
  end

  def authentication
    # This adds the cookie in development/test so that action cable can authenticate.
    start_new_session if Rails.env.local?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.user ||= User.find_by(email_address: remote_user)
  end

  def set_current_groups
    Current.groups ||= groups_from_session
  end

  def set_current_orcid
    Current.orcid ||= orcid_from_session
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to login_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session
    # Create or update a user based on the headers provided by Apache.
    results = User.upsert(user_attrs, unique_by: :email_address) # rubocop:disable Rails/SkipsModelValidations
    # This cookie will be used to authenticate Action Cable connections.
    cookies.signed.permanent[:user_id] = { value: results.rows[0][0], httponly: true, same_site: :lax }
  end

  def user_attrs # rubocop:disable Metrics/AbcSize
    return Settings.seed_user.to_h.except(:orcid_id) if Rails.env.development?

    {
      email_address: request.headers[Settings.http_headers.remote_user],
      name: request.headers[Settings.http_headers.full_name],
      first_name: request.headers[Settings.http_headers.first_name]
    }
  end

  # This looks first in the session for groups, and then to the headers.
  # This allows the application session to outlive the shibboleth session
  def groups_from_session
    session['groups'] ||= begin
      raw_header = request.headers[Settings.http_headers.user_groups]
      roles = ENV.fetch('ROLES', nil)
      raw_header = roles if Rails.env.development?
      raw_header&.split(';') || []
    end
  end

  # This looks first in the session for orcid ID, and then to the headers.
  # This allows the application session to outlive the shibboleth session
  def orcid_from_session
    session['orcid'] ||= if Rails.env.development?
                           Settings.seed_user.orcid_id
                         else
                           request.headers[Settings.http_headers.orcid_id]
                         end
  end

  def terminate_session
    cookies.delete(:user_id)
  end
end
