# frozen_string_literal: true

require 'legion/extensions/reality_testing/client'

RSpec.describe Legion::Extensions::RealityTesting::Runners::RealityTesting do
  let(:client) { Legion::Extensions::RealityTesting::Client.new }

  describe '#create_belief' do
    it 'creates a belief and returns created: true' do
      result = client.create_belief(claim: 'Water boils at 100C')
      expect(result[:created]).to be true
    end

    it 'uses default confidence when not specified' do
      result = client.create_belief(claim: 'default conf')
      expect(result[:belief][:confidence]).to eq(0.5)
    end

    it 'accepts custom confidence' do
      result = client.create_belief(claim: 'high conf', confidence: 0.9)
      expect(result[:belief][:confidence]).to eq(0.9)
    end

    it 'accepts custom domain' do
      result = client.create_belief(claim: 'domain test', domain: :physics)
      expect(result[:belief][:domain]).to eq(:physics)
    end
  end

  describe '#test_belief' do
    let(:belief_id) { client.create_belief(claim: 'testable')[:belief][:id] }

    it 'returns tested: true for known belief' do
      expect(client.test_belief(belief_id: belief_id, evidence_type: :confirming)[:tested]).to be true
    end

    it 'returns tested: false for unknown belief' do
      result = client.test_belief(belief_id: 'ghost', evidence_type: :confirming)
      expect(result[:tested]).to be false
    end

    it 'accepts string evidence_type' do
      result = client.test_belief(belief_id: belief_id, evidence_type: 'confirming')
      expect(result[:tested]).to be true
    end

    it 'increases confidence with confirming evidence' do
      result = client.test_belief(belief_id: belief_id, evidence_type: :confirming)
      expect(result[:belief][:confidence]).to be > 0.5
    end

    it 'decreases confidence with disconfirming evidence' do
      result = client.test_belief(belief_id: belief_id, evidence_type: :disconfirming)
      expect(result[:belief][:confidence]).to be < 0.5
    end
  end

  describe '#get_belief' do
    it 'returns found: true for existing belief' do
      id = client.create_belief(claim: 'fetch me')[:belief][:id]
      result = client.get_belief(belief_id: id)
      expect(result[:found]).to be true
      expect(result[:belief][:claim]).to eq('fetch me')
    end

    it 'returns found: false for missing belief' do
      result = client.get_belief(belief_id: 'missing')
      expect(result[:found]).to be false
    end
  end

  describe '#beliefs_needing_testing' do
    it 'returns count and beliefs array' do
      client.create_belief(claim: 'uncertain', confidence: 0.5)
      result = client.beliefs_needing_testing
      expect(result).to include(:count, :beliefs)
      expect(result[:count]).to be >= 1
    end
  end

  describe '#strongest_beliefs' do
    it 'returns highest-confidence beliefs' do
      client.create_belief(claim: 'weak', confidence: 0.2)
      client.create_belief(claim: 'strong', confidence: 0.9)
      result = client.strongest_beliefs(limit: 1)
      expect(result[:beliefs].first[:claim]).to eq('strong')
    end
  end

  describe '#weakest_beliefs' do
    it 'returns lowest-confidence beliefs' do
      client.create_belief(claim: 'weak', confidence: 0.2)
      client.create_belief(claim: 'strong', confidence: 0.9)
      result = client.weakest_beliefs(limit: 1)
      expect(result[:beliefs].first[:claim]).to eq('weak')
    end
  end

  describe '#beliefs_by_domain' do
    it 'filters beliefs by domain' do
      client.create_belief(claim: 'logic rule', domain: :logic)
      client.create_belief(claim: 'social norm', domain: :social)
      result = client.beliefs_by_domain(domain: :logic)
      expect(result[:domain]).to eq(:logic)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#overall_coherence' do
    it 'returns a coherence value between 0 and 1' do
      client.create_belief(claim: 'test')
      result = client.overall_coherence
      expect(result[:coherence]).to be_between(0.0, 1.0)
    end
  end

  describe '#decay_beliefs' do
    it 'returns the number of decayed beliefs' do
      client.create_belief(claim: 'one')
      result = client.decay_beliefs
      expect(result[:decayed]).to eq(1)
    end
  end

  describe '#prune_rejected_beliefs' do
    it 'returns count of pruned beliefs' do
      client.create_belief(claim: 'dead', confidence: 0.05)
      result = client.prune_rejected_beliefs
      expect(result[:pruned]).to eq(1)
    end

    it 'returns 0 when nothing pruned' do
      client.create_belief(claim: 'alive', confidence: 0.8)
      expect(client.prune_rejected_beliefs[:pruned]).to eq(0)
    end
  end

  describe '#reality_report' do
    it 'returns a full report hash' do
      client.create_belief(claim: 'fact')
      report = client.reality_report
      expect(report).to include(:total_beliefs, :coherence, :needing_testing, :domains)
    end
  end

  describe '#reality_status' do
    it 'returns total_beliefs, coherence, needing_testing' do
      client.create_belief(claim: 'status test')
      result = client.reality_status
      expect(result).to include(:total_beliefs, :coherence, :needing_testing)
      expect(result[:total_beliefs]).to eq(1)
    end
  end
end
