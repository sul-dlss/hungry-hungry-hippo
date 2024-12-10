# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactEmailForm do
  describe 'validations' do
    let(:form) { described_class.new(email:) }
    let(:email) { '' }

    context 'when nil' do
      it 'is valid' do
        expect(form.valid?).to be true
      end
    end

    context 'when nil and depositing' do
      it 'is not valid' do
        expect(form.valid?(deposit: true)).to be false
      end
    end

    context 'when valid email' do
      let(:email) { 'alfred@stanford.edu' }

      it 'is valid' do
        expect(form.valid?).to be true
      end
    end

    context 'when invalid email' do
      let(:email) { 'alfred' }

      it 'is not valid' do
        expect(form.valid?).to be false
      end
    end
  end
end
