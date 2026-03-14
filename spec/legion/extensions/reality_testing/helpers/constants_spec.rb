# frozen_string_literal: true

RSpec.describe Legion::Extensions::RealityTesting::Helpers::Constants do
  subject(:mod) { described_class }

  describe 'capacity constants' do
    it 'defines MAX_BELIEFS as 300' do
      expect(mod::MAX_BELIEFS).to eq(300)
    end

    it 'defines MAX_EVIDENCE as 500' do
      expect(mod::MAX_EVIDENCE).to eq(500)
    end
  end

  describe 'confidence constants' do
    it 'defines DEFAULT_CONFIDENCE as 0.5' do
      expect(mod::DEFAULT_CONFIDENCE).to eq(0.5)
    end

    it 'defines CONFIDENCE_BOOST as 0.1' do
      expect(mod::CONFIDENCE_BOOST).to eq(0.1)
    end

    it 'defines CONFIDENCE_PENALTY as 0.15' do
      expect(mod::CONFIDENCE_PENALTY).to eq(0.15)
    end

    it 'defines CONFIDENCE_DECAY as 0.02' do
      expect(mod::CONFIDENCE_DECAY).to eq(0.02)
    end
  end

  describe 'CONFIDENCE_LABELS' do
    it 'returns :certain for 1.0' do
      label = mod::CONFIDENCE_LABELS.find { |e| e[:range].cover?(1.0) }[:label]
      expect(label).to eq(:certain)
    end

    it 'returns :confident for 0.75' do
      label = mod::CONFIDENCE_LABELS.find { |e| e[:range].cover?(0.75) }[:label]
      expect(label).to eq(:confident)
    end

    it 'returns :tentative for 0.5' do
      label = mod::CONFIDENCE_LABELS.find { |e| e[:range].cover?(0.5) }[:label]
      expect(label).to eq(:tentative)
    end

    it 'returns :doubtful for 0.2' do
      label = mod::CONFIDENCE_LABELS.find { |e| e[:range].cover?(0.2) }[:label]
      expect(label).to eq(:doubtful)
    end

    it 'returns :rejected for 0.05' do
      label = mod::CONFIDENCE_LABELS.find { |e| e[:range].cover?(0.05) }[:label]
      expect(label).to eq(:rejected)
    end
  end

  describe 'EVIDENCE_TYPES' do
    it 'includes all four types' do
      expect(mod::EVIDENCE_TYPES).to eq(%i[confirming disconfirming neutral ambiguous])
    end
  end

  describe 'VALIDITY_LABELS' do
    it 'returns :validated for 0.9' do
      label = mod::VALIDITY_LABELS.find { |e| e[:range].cover?(0.9) }[:label]
      expect(label).to eq(:validated)
    end

    it 'returns :refuted for 0.05' do
      label = mod::VALIDITY_LABELS.find { |e| e[:range].cover?(0.05) }[:label]
      expect(label).to eq(:refuted)
    end
  end
end
