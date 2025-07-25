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

  MAX_URL_SIZE = ActionDispatch::Cookies::MAX_COOKIE_SIZE / 2
  SHIBBOLETH_LOGOUT_PATH = '/Shibboleth.sso/Logout'

  USER_GROUPS_HEADER = 'X-Groups'
  FIRST_NAME_HEADER =  'X-Person-Name'
  FULL_NAME_HEADER = 'X-Person-Formal-Name'
  REMOTE_USER_HEADER = 'X-Remote-User'
  ORCID_ID_HEADER =  'X-Orcid-Id'

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
    def allow_unauthenticated_access(**)
      skip_before_action :require_authentication, **
    end
  end

  def current_user
    Current.user
  end

  private

  def remote_user
    return Settings.seed_user.email_address if Rails.env.development?

    request.headers[REMOTE_USER_HEADER]
  end

  def authenticated?
    remote_user.present?
  end

  def authentication
    # This adds the cookie in development/test so that action cable can authenticate.
    start_new_session if start_new_session?
    resume_session
  end

  def start_new_session?
    return true if Rails.env.development?

    Rails.env.test? && user_attrs[:email_address].present?
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
    # Always check that we have enough space in the cookie to store the full return URL.
    #
    # This situation typically occurs when we are scanned for vulnerabilities and a
    # CRLF Injection attack is attempted, see https://www.geeksforgeeks.org/crlf-injection-attack/
    session[:return_to_after_authenticating] = request.url if request.url.size < MAX_URL_SIZE
    redirect_to main_app.login_path
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
      email_address: request.headers[REMOTE_USER_HEADER] || request.cookies[:test_shibboleth_remote_user],
      name: request.headers[FULL_NAME_HEADER] || request.cookies[:test_shibboleth_full_name],
      first_name: request.headers[FIRST_NAME_HEADER] || request.cookies[:test_shibboleth_first_name]
    }
  end

  # This looks first in the session for groups, and then to the headers.
  # This allows the application session to outlive the shibboleth session
  def groups_from_session
    set_groups_for_emulate_not_admin
    return ENV.fetch('ROLES', '').split(';') if Rails.env.development?
    return [] unless authenticated?

    session['groups'] ||= begin
      raw_header = request.headers[USER_GROUPS_HEADER] || ''
      raw_header.split(';')
    end
  end

  def set_groups_for_emulate_not_admin
    # This cookie is set from the emulate admin page.
    if cookies[:emulate_not_admin]
      session['groups'] = ['emulating_not_admin']
    # The absence of the cookie but the presence of the "emulating_not_admin" group indicates
    # that should revert to normal groups.
    # The cookie may be deleted by the user or when there is a new session.
    elsif session['groups'] == ['emulating_not_admin']
      session['groups'] = nil
    end
  end

  # This looks first in the session for orcid ID, and then to the headers.
  # This allows the application session to outlive the shibboleth session
  def orcid_from_session
    session['orcid'] ||= if Rails.env.development?
                           Settings.seed_user.orcid_id
                         else
                           orcid = request.headers[ORCID_ID_HEADER]
                           orcid == '(null)' ? nil : orcid
                         end
  end

  def terminate_session
    cookies.delete(:user_id)
  end
end
