# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LinebreakSupport do
  it 'normalizes to CRLF' do
    expect(described_class.normalize("foo\r\nbar")).to eq("foo\r\nbar")
    expect(described_class.normalize("foo\nbar")).to eq("foo\r\nbar")
    expect(described_class.normalize("foo\rbar")).to eq("foo\r\nbar")
    expect(described_class.normalize("foo\n\nbar")).to eq("foo\r\n\r\nbar")
  end

  it 'handles nil' do
    expect(described_class.normalize(nil)).to be_nil
  end

  it 'removes leading and trailing whitespace' do
    expect(described_class.normalize("  foo\r\nbar\n")).to eq("foo\r\nbar")
  end
end
