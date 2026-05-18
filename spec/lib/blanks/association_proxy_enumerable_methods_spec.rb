# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blanks::AssociationProxy do
  let(:form_class) do
    Class.new(Blanks::Base) do
      attribute :name, :string
    end
  end

  before do
    stub_const('AssociationProxyEnumerableItemForm', form_class)
  end

  it 'supports any? with a block' do
    proxy = described_class.new('AssociationProxyEnumerableItemForm')
    proxy.new(name: '')
    proxy.new(name: 'present')

    expect(proxy.any? { |item| item.name.present? }).to be(true)
  end

  it 'supports reverse without calling to_a' do
    proxy = described_class.new('AssociationProxyEnumerableItemForm')
    first = proxy.new(name: 'first')
    second = proxy.new(name: 'second')

    expect(proxy.reverse).to eq([second, first])
  end
end
