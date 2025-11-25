# frozen_string_literal: true

Rails.application.config.active_job.custom_serializers << WorkFormSerializer
Rails.application.config.active_job.custom_serializers << CollectionFormSerializer
Rails.application.config.active_job.custom_serializers << WorkReportFormSerializer
Rails.application.config.active_job.custom_serializers << CollectionReportFormSerializer
Rails.application.config.active_job.custom_serializers << ContributorFormSerializer
