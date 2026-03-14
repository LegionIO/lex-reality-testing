# frozen_string_literal: true

require 'legion/extensions/reality_testing/client'

RSpec.describe Legion::Extensions::RealityTesting::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    expect(client).to respond_to(:create_belief)
    expect(client).to respond_to(:test_belief)
    expect(client).to respond_to(:get_belief)
    expect(client).to respond_to(:beliefs_needing_testing)
    expect(client).to respond_to(:strongest_beliefs)
    expect(client).to respond_to(:weakest_beliefs)
    expect(client).to respond_to(:beliefs_by_domain)
    expect(client).to respond_to(:overall_coherence)
    expect(client).to respond_to(:decay_beliefs)
    expect(client).to respond_to(:prune_rejected_beliefs)
    expect(client).to respond_to(:reality_report)
    expect(client).to respond_to(:reality_status)
  end

  it 'maintains isolated state per instance' do
    client_a = described_class.new
    client_b = described_class.new
    client_a.create_belief(claim: 'only in A')
    expect(client_b.reality_status[:total_beliefs]).to eq(0)
  end
end
