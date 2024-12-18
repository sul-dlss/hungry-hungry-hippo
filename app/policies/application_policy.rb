# frozen_string_literal: true

class ApplicationPolicy
  # For backwards compatibility with ActionPolicy
  class << self
    def alias_rule(*alias_symbols, to:)
      alias_symbols.each do |alias_symbol|
        define_method(alias_symbol) { public_send(to) }
      end
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def update?
    admin?
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    Current.groups.include?(Settings.authorization_workgroup_names.administrators)
  end

  def collection_creator?
    Current.groups.include?(Settings.authorization_workgroup_names.collection_creators)
  end
end
