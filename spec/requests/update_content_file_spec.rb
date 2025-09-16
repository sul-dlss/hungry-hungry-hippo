# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update content file' do
  let(:content_file) { create(:content_file) }
  let(:user) { create(:user) }

  before { sign_in(user) }

  context 'when the user is not authorized' do
    it 'redirects to root' do
      patch "/content_files/#{content_file.id}"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    let(:content_file) { create(:content_file, content: create(:content, user:)) }
    let(:content_file_params) { { label: '', hide: true } }

    context 'when update succeeds' do
      it 'redirects to content file' do
        patch "/content_files/#{content_file.id}", params: { content_file: content_file_params }

        expect(response).to redirect_to(content_file_path(content_file))
      end
    end

    context 'when update fails' do
      let(:content_file_params) { { label: 123, hide: 'nope' } }

      before do
        allow_any_instance_of(ContentFile).to receive(:update).and_return(false) # rubocop:disable RSpec/AnyInstance
      end

      it 'renders the edit form with an HTTP 422' do
        patch "/content_files/#{content_file.id}", params: { content_file: content_file_params }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
