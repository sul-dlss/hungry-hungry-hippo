# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IgnoreFileService do
  describe '.ignore?' do
    context 'when a file is ignored' do
      it 'returns true' do
        expect(described_class.call(filepath: '__MACOSXfoo.txt')).to be true
        expect(described_class.call(filepath: '._foo.txt')).to be true
        expect(described_class.call(filepath: '~$foo.txt')).to be true
        expect(described_class.call(filepath: 'bar/__MACOSXfoo.txt')).to be true
        expect(described_class.call(filepath: 'bar/._foo.txt')).to be true
        expect(described_class.call(filepath: 'bar/~$foo.txt')).to be true
        expect(described_class.call(filepath: '__MACOSXbar/foo.txt')).to be true
        expect(described_class.call(filepath: '._bar/foo.txt')).to be true
        expect(described_class.call(filepath: 'foo.txt.DS_Store')).to be true
        expect(described_class.call(filepath: "foo.txtIcon\r")).to be true
      end
    end

    context 'when a file is not ignored' do
      it 'returns false' do
        expect(described_class.call(filepath: 'foo.txt')).to be false
        expect(described_class.call(filepath: 'bar/foo.txt')).to be false
      end
    end
  end
end
