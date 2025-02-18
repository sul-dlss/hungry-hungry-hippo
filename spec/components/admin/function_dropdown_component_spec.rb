# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::FunctionDropdownComponent, type: :component do
  let(:user) { build(:user) }
  let(:groups) { [] }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
    allow(Current).to receive(:groups).and_return(groups)
  end

  context 'when there are functions and user is an admin' do
    let(:groups) { ['dlss:hydrus-app-administrators'] }

    it 'renders' do
      render_inline(described_class.new(classes: 'my-2')) do |component|
        component.with_function(label: 'Function', link: 'admin/my_function', data: { turbo_frame: 'my_frame' })
      end

      expect(page).to have_css('.dropdown.my-2 ul.dropdown-menu li a.dropdown-item[data-turbo-frame="my_frame"]',
                               count: 1)
      expect(page).to have_link('Function', href: 'admin/my_function')
    end
  end

  context 'when there are no functions and user is an admin' do
    let(:groups) { ['dlss:hydrus-app-administrators'] }

    it 'does not render' do
      render_inline(described_class.new)

      expect(page).to have_no_css('.dropdown')
    end
  end

  context 'when there are functions and user is not an admin' do
    it 'does not render' do
      render_inline(described_class.new) do |component|
        component.with_function(label: 'Function', link: 'admin/my_function')
      end

      expect(page).to have_no_css('.dropdown')
    end
  end
end
