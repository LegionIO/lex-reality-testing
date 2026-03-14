# frozen_string_literal: true

RSpec.describe Legion::Extensions::RealityTesting::Helpers::RealityEngine do
  subject(:engine) { described_class.new }

  describe '#create_belief' do
    it 'creates a belief and returns created: true' do
      result = engine.create_belief(claim: 'All humans are mortal')
      expect(result[:created]).to be true
    end

    it 'includes the belief hash in the result' do
      result = engine.create_belief(claim: 'All humans are mortal')
      expect(result[:belief]).to include(:id, :claim, :confidence)
    end

    it 'assigns sequential IDs' do
      r1 = engine.create_belief(claim: 'claim 1')
      r2 = engine.create_belief(claim: 'claim 2')
      expect(r1[:belief][:id]).to eq('belief_1')
      expect(r2[:belief][:id]).to eq('belief_2')
    end

    it 'respects custom domain' do
      result = engine.create_belief(claim: 'test', domain: :science)
      expect(result[:belief][:domain]).to eq(:science)
    end

    it 'respects custom confidence' do
      result = engine.create_belief(claim: 'test', confidence: 0.8)
      expect(result[:belief][:confidence]).to eq(0.8)
    end

    it 'returns at_capacity when MAX_BELIEFS reached' do
      stub_const('Legion::Extensions::RealityTesting::Helpers::Constants::MAX_BELIEFS', 2)
      engine.create_belief(claim: 'one')
      engine.create_belief(claim: 'two')
      result = engine.create_belief(claim: 'three')
      expect(result[:created]).to be false
      expect(result[:reason]).to eq(:at_capacity)
    end
  end

  describe '#test_belief' do
    let(:belief_id) do
      engine.create_belief(claim: 'test claim')[:belief][:id]
    end

    it 'returns tested: true for known belief' do
      result = engine.test_belief(belief_id: belief_id, evidence_type: :confirming)
      expect(result[:tested]).to be true
    end

    it 'returns tested: false for unknown belief' do
      result = engine.test_belief(belief_id: 'nope', evidence_type: :confirming)
      expect(result[:tested]).to be false
      expect(result[:reason]).to eq(:not_found)
    end

    it 'updates confidence after confirming evidence' do
      before = engine.test_belief(belief_id: belief_id, evidence_type: :confirming)
      expect(before[:belief][:confidence]).to be > 0.5
    end

    it 'updates confidence after disconfirming evidence' do
      result = engine.test_belief(belief_id: belief_id, evidence_type: :disconfirming)
      expect(result[:belief][:confidence]).to be < 0.5
    end
  end

  describe '#beliefs_needing_testing' do
    it 'returns beliefs with confidence between 0.3 and 0.7' do
      engine.create_belief(claim: 'uncertain', confidence: 0.5)
      engine.create_belief(claim: 'strong', confidence: 0.95)
      engine.create_belief(claim: 'weak', confidence: 0.05)
      result = engine.beliefs_needing_testing
      expect(result.size).to eq(1)
      expect(result.first.claim).to eq('uncertain')
    end
  end

  describe '#strongest_beliefs' do
    it 'returns beliefs sorted by descending confidence' do
      engine.create_belief(claim: 'low', confidence: 0.2)
      engine.create_belief(claim: 'high', confidence: 0.9)
      engine.create_belief(claim: 'mid', confidence: 0.5)
      result = engine.strongest_beliefs(limit: 2)
      expect(result.first.claim).to eq('high')
      expect(result.size).to eq(2)
    end
  end

  describe '#weakest_beliefs' do
    it 'returns beliefs sorted by ascending confidence' do
      engine.create_belief(claim: 'low', confidence: 0.2)
      engine.create_belief(claim: 'high', confidence: 0.9)
      result = engine.weakest_beliefs(limit: 1)
      expect(result.first.claim).to eq('low')
    end
  end

  describe '#beliefs_by_domain' do
    it 'filters beliefs by domain' do
      engine.create_belief(claim: 'science fact', domain: :science)
      engine.create_belief(claim: 'social fact', domain: :social)
      result = engine.beliefs_by_domain(domain: :science)
      expect(result.size).to eq(1)
      expect(result.first.domain).to eq(:science)
    end
  end

  describe '#overall_reality_coherence' do
    it 'returns 0.0 with no beliefs' do
      expect(engine.overall_reality_coherence).to eq(0.0)
    end

    it 'returns 0.5 with one belief and no evidence' do
      engine.create_belief(claim: 'test')
      expect(engine.overall_reality_coherence).to eq(0.5)
    end

    it 'increases toward 1.0 with confirming evidence' do
      id = engine.create_belief(claim: 'test')[:belief][:id]
      5.times { engine.test_belief(belief_id: id, evidence_type: :confirming) }
      expect(engine.overall_reality_coherence).to be > 0.5
    end
  end

  describe '#decay_all' do
    it 'decays all beliefs and returns count' do
      engine.create_belief(claim: 'b1')
      engine.create_belief(claim: 'b2')
      count = engine.decay_all
      expect(count).to eq(2)
    end

    it 'reduces confidence of each belief' do
      id = engine.create_belief(claim: 'test')[:belief][:id]
      belief_before = engine.instance_variable_get(:@beliefs)[id].confidence
      engine.decay_all
      belief_after = engine.instance_variable_get(:@beliefs)[id].confidence
      expect(belief_after).to be < belief_before
    end
  end

  describe '#prune_rejected' do
    it 'removes beliefs with confidence below 0.1' do
      id = engine.create_belief(claim: 'very weak', confidence: 0.05)[:belief][:id]
      engine.create_belief(claim: 'strong', confidence: 0.8)
      pruned = engine.prune_rejected
      expect(pruned).to eq(1)
      expect(engine.instance_variable_get(:@beliefs)).not_to have_key(id)
    end

    it 'returns 0 when nothing to prune' do
      engine.create_belief(claim: 'ok', confidence: 0.5)
      expect(engine.prune_rejected).to eq(0)
    end
  end

  describe '#reality_report' do
    it 'returns a report hash with required keys' do
      engine.create_belief(claim: 'test')
      report = engine.reality_report
      expect(report).to include(:total_beliefs, :coherence, :needing_testing, :domains)
    end

    it 'reports total_beliefs correctly' do
      engine.create_belief(claim: 'a')
      engine.create_belief(claim: 'b')
      expect(engine.reality_report[:total_beliefs]).to eq(2)
    end
  end

  describe '#to_h' do
    it 'returns belief_count and beliefs array' do
      engine.create_belief(claim: 'one')
      h = engine.to_h
      expect(h[:belief_count]).to eq(1)
      expect(h[:beliefs]).to be_an(Array)
    end
  end

  describe '#size' do
    it 'returns the number of stored beliefs' do
      expect(engine.size).to eq(0)
      engine.create_belief(claim: 'one')
      expect(engine.size).to eq(1)
    end
  end
end
