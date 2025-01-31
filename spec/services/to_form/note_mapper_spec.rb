# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToForm::NoteMapper do
  describe '#abstract' do
    let(:cocina_object) do
      # NOTE: the :dro factory in the cocina-models gem does not have a seam
      #       for injecting abstract, so we do it manually here
      build(:dro, title: title_fixture).then do |object|
        object.new(
          object
          .to_h
          .tap do |obj|
            obj[:description][:note] =
              [
                {
                  type: 'abstract',
                  value: abstract_fixture
                }
              ]
          end
        )
      end
    end

    it 'returns the abstract' do
      expect(described_class.abstract(cocina_object:)).to eq abstract_fixture
    end
  end
end
