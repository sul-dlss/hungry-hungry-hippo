# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sdr::Workflow do
  let(:workflow_client) { instance_double(Dor::Workflow::Client, create_workflow_by_name: true) }

  let(:druid) { 'druid:bc123df4567' }

  before do
    allow(Dor::Workflow::Client).to receive(:new).and_return(workflow_client)
  end

  describe '#create_unless_exists' do
    before do
      allow(workflow_client).to receive(:workflow).and_return(instance_double(Dor::Workflow::Response::Workflow,
                                                                              empty?: !workflow_exists))
    end

    context 'when the workflow exists' do
      let(:workflow_exists) { true }

      it 'does not create a new workflow' do
        described_class.create_unless_exists(druid, 'accessionWF')

        expect(workflow_client).to have_received(:workflow).with(pid: druid, workflow_name: 'accessionWF')
        expect(workflow_client).not_to have_received(:create_workflow_by_name)
      end
    end

    context 'when the workflow does not exist' do
      let(:workflow_exists) { false }

      it 'creates a new workflow' do
        described_class.create_unless_exists(druid, 'accessionWF', version: 2, priority: 'low')

        expect(workflow_client).to have_received(:workflow).with(pid: druid, workflow_name: 'accessionWF')
        expect(workflow_client).to have_received(:create_workflow_by_name).with(druid, 'accessionWF', version: 2,
                                                                                                      lane_id: 'low')
      end
    end

    context 'when creating the workflow fails' do
      let(:workflow_exists) { false }

      before do
        allow(workflow_client).to receive(:create_workflow_by_name).and_raise(Dor::WorkflowException,
                                                                              'Failed to create')
      end

      it 'raises' do
        expect { described_class.create_unless_exists(druid, 'accessionWF') }.to raise_error(Sdr::Workflow::Error)
      end
    end
  end
end
