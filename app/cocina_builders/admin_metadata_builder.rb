# frozen_string_literal: true

# Generates the Cocina parameters for admin metadata.
class AdminMetadataBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(creation_date:)
    @creation_date = creation_date
  end

  def call
    {
      note: [
        {
          type: 'record origin',
          value: 'Metadata created by user via Stanford self-deposit application'
        }
      ]
    }.tap do |params|
      if creation_date
        params[:event] = [
          {
            date: [
              {
                encoding: {
                  code: 'edtf'
                },
                value: creation_date.strftime('%Y-%m-%d')
              }
            ],
            type: 'creation'
          }
        ]
      end
    end
  end

  private

  attr_reader :creation_date
end
