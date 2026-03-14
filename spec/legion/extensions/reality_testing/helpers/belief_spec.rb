# frozen_string_literal: true

RSpec.describe Legion::Extensions::RealityTesting::Helpers::Belief do
  subject(:belief) { described_class.new(id: 'b1', claim: 'The sky is blue', domain: :perception) }

  describe '#initialize' do
    it 'sets id' do
      expect(belief.id).to eq('b1')
    end

    it 'sets claim' do
      expect(belief.claim).to eq('The sky is blue')
    end

    it 'sets domain' do
      expect(belief.domain).to eq(:perception)
    end

    it 'sets default confidence' do
      expect(belief.confidence).to eq(0.5)
    end

    it 'clamps confidence above 1.0' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 1.5)
      expect(b.confidence).to eq(1.0)
    end

    it 'clamps confidence below 0.0' do
      b = described_class.new(id: 'x', claim: 'test', confidence: -0.5)
      expect(b.confidence).to eq(0.0)
    end

    it 'initializes evidence counts to zero' do
      expect(belief.evidence_count).to eq(0)
      expect(belief.confirming_count).to eq(0)
      expect(belief.disconfirming_count).to eq(0)
    end
  end

  describe '#test_with_evidence!' do
    it 'increments evidence_count for any type' do
      belief.test_with_evidence!(evidence_type: :confirming)
      expect(belief.evidence_count).to eq(1)
    end

    it 'increases confidence for confirming evidence' do
      before = belief.confidence
      belief.test_with_evidence!(evidence_type: :confirming)
      expect(belief.confidence).to be > before
    end

    it 'decreases confidence for disconfirming evidence' do
      before = belief.confidence
      belief.test_with_evidence!(evidence_type: :disconfirming)
      expect(belief.confidence).to be < before
    end

    it 'does not change confidence for neutral evidence' do
      before = belief.confidence
      belief.test_with_evidence!(evidence_type: :neutral)
      expect(belief.confidence).to eq(before)
    end

    it 'nudges confidence toward 0.5 for ambiguous evidence when above' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 0.8)
      before = b.confidence
      b.test_with_evidence!(evidence_type: :ambiguous)
      expect(b.confidence).to be < before
    end

    it 'nudges confidence toward 0.5 for ambiguous evidence when below' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 0.2)
      before = b.confidence
      b.test_with_evidence!(evidence_type: :ambiguous)
      expect(b.confidence).to be > before
    end

    it 'tracks confirming_count' do
      belief.test_with_evidence!(evidence_type: :confirming)
      expect(belief.confirming_count).to eq(1)
    end

    it 'tracks disconfirming_count' do
      belief.test_with_evidence!(evidence_type: :disconfirming)
      expect(belief.disconfirming_count).to eq(1)
    end

    it 'raises for unknown evidence_type' do
      expect { belief.test_with_evidence!(evidence_type: :unknown) }.to raise_error(ArgumentError)
    end

    it 'returns self for chaining' do
      result = belief.test_with_evidence!(evidence_type: :neutral)
      expect(result).to be(belief)
    end
  end

  describe '#confidence_label' do
    it 'returns :certain at 1.0' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 1.0)
      expect(b.confidence_label).to eq(:certain)
    end

    it 'returns :tentative at 0.5' do
      expect(belief.confidence_label).to eq(:tentative)
    end

    it 'returns :rejected near 0.0' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 0.05)
      expect(b.confidence_label).to eq(:rejected)
    end
  end

  describe '#validity' do
    it 'returns 0.5 when no evidence' do
      expect(belief.validity).to eq(0.5)
    end

    it 'returns 1.0 with only confirming evidence' do
      3.times { belief.test_with_evidence!(evidence_type: :confirming) }
      expect(belief.validity).to eq(1.0)
    end

    it 'returns 0.0 with only disconfirming evidence' do
      3.times { belief.test_with_evidence!(evidence_type: :disconfirming) }
      expect(belief.validity).to eq(0.0)
    end

    it 'returns 0.5 with equal confirming and disconfirming' do
      belief.test_with_evidence!(evidence_type: :confirming)
      belief.test_with_evidence!(evidence_type: :disconfirming)
      expect(belief.validity).to eq(0.5)
    end
  end

  describe '#validity_label' do
    it 'returns :validated with all confirming' do
      3.times { belief.test_with_evidence!(evidence_type: :confirming) }
      expect(belief.validity_label).to eq(:validated)
    end

    it 'returns :refuted with all disconfirming' do
      3.times { belief.test_with_evidence!(evidence_type: :disconfirming) }
      expect(belief.validity_label).to eq(:refuted)
    end
  end

  describe '#needs_testing?' do
    it 'returns true at default confidence 0.5' do
      expect(belief.needs_testing?).to be true
    end

    it 'returns false at high confidence' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 0.9)
      expect(b.needs_testing?).to be false
    end

    it 'returns false at low confidence' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 0.1)
      expect(b.needs_testing?).to be false
    end
  end

  describe '#decay!' do
    it 'reduces confidence by CONFIDENCE_DECAY' do
      before = belief.confidence
      belief.decay!
      expect(belief.confidence).to be_within(0.001).of(before - 0.02)
    end

    it 'floors at 0.0' do
      b = described_class.new(id: 'x', claim: 'test', confidence: 0.01)
      b.decay!
      expect(b.confidence).to eq(0.0)
    end

    it 'returns self' do
      expect(belief.decay!).to be(belief)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = belief.to_h
      expect(h).to include(
        :id, :claim, :domain, :confidence, :confidence_label,
        :evidence_count, :confirming_count, :disconfirming_count,
        :validity, :validity_label, :needs_testing, :created_at, :last_tested_at
      )
    end

    it 'sets last_tested_at after testing' do
      belief.test_with_evidence!(evidence_type: :confirming)
      expect(belief.to_h[:last_tested_at]).not_to be_nil
    end
  end
end
