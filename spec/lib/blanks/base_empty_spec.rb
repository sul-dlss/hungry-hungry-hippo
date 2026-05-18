# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blanks::Base do
  describe '#empty?' do
    let(:form_class) do
      Class.new(described_class) do
        attribute :title, :string
        attribute :count, :integer
      end
    end

    it 'returns true when all attributes are blank' do
      form = form_class.new

      expect(form.empty?).to be(true)
    end

    it 'returns false when any attribute is present' do
      form = form_class.new(title: 'present')

      expect(form.empty?).to be(false)
    end
  end
end
