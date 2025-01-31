# frozen_string_literal: true

module Cocina
  # Updates version and lock for the provided Cocina object.
  class VersionAndLockUpdater
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:, version:, lock:)
      @cocina_object = cocina_object
      @version = version
      @lock = lock
    end

    def call
      Cocina::Models.with_metadata(Cocina::Models.build(params), lock)
    end

    private

    attr_reader :cocina_object, :version, :lock

    def params
      Cocina::Models.without_metadata(cocina_object).to_h.tap do |params|
        params['version'] = version
        if params[:structural].present?
          params[:structural][:contains].each do |file_set_params|
            update_file_set_params(file_set_params)
          end
        end
      end
    end

    def update_file_set_params(file_set_params)
      file_set_params[:version] = version
      file_set_params[:structural][:contains].each do |file_params|
        file_params[:version] = version
      end
    end
  end
end
