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

  REMOTE_USER_HEADER = 'X-Remote-User'
  GROUPS_HEADER = 'X-Groups'
  FIRST_NAME_HEADER = 'X-Person-Name'
  NAME_HEADER = 'X-Person-Formal-Name'

  # The development environment does not have Shibboleth authentication.
  # Instead, it will use this hardcoded user.
  DEV_REMOTE_USER = 'a.user@stanford.edu'
  DEV_FIRST_NAME = 'A.'
  DEV_NAME = 'A. User'

  SHIBBOLETH_LOGOUT_PATH = '/Shibboleth.sso/Logout'

  included do
    # authentication will be called before require_authentication.
    # It will authenticate the user if there is a user.
    # This will be called for all controller actions.
    # require_authentication will also be called for all controller actions,
    # unless skipped with allow_unauthenticated_access.
    before_action :authentication, :require_authentication
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
    return DEV_REMOTE_USER if Rails.env.development?

    request.headers[REMOTE_USER_HEADER]
  end

  def authenticated?
    remote_user.present?
  end

  def authentication
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.user ||= User.find_by(email_address: remote_user)
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

  def user_attrs
    return dev_user_attrs if Rails.env.development?

    {
      email_address: request.headers[REMOTE_USER_HEADER],
      name: request.headers[NAME_HEADER],
      first_name: request.headers[FIRST_NAME_HEADER]
    }
  end

  def dev_user_attrs
    {
      email_address: DEV_REMOTE_USER,
      name: DEV_NAME,
      first_name: DEV_FIRST_NAME
    }
  end

  def terminate_session
    cookies.delete(:user_id)
  end
end
