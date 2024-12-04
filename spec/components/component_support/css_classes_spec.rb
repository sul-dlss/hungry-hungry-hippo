# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComponentSupport::CssClasses do
  it 'merges classes' do
    expect(described_class.merge(nil)).to be_nil
    expect(described_class.merge('class1')).to eq('class1')
    expect(described_class.merge(['class1'])).to eq('class1')
    expect(described_class.merge('class1', 'class2')).to eq('class1 class2')
    expect(described_class.merge(%w[class1 class2])).to eq('class1 class2')
    expect(described_class.merge('class1 class2')).to eq('class1 class2')
    expect(described_class.merge('class1', 'class1')).to eq('class1')
    expect(described_class.merge('class1', 'class2 class3',
                                 %w[class4 class5])).to eq('class1 class2 class3 class4 class5')
  end
end
