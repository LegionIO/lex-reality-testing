# frozen_string_literal: true

module Legion
  module Extensions
    module RealityTesting
      module Helpers
        class Belief
          include Constants

          attr_reader :id, :claim, :domain, :confidence, :evidence_count,
                      :confirming_count, :disconfirming_count, :created_at, :last_tested_at

          def initialize(id:, claim:, domain: :general, confidence: Constants::DEFAULT_CONFIDENCE)
            @id                  = id
            @claim               = claim
            @domain              = domain
            @confidence          = confidence.clamp(0.0, 1.0)
            @evidence_count      = 0
            @confirming_count    = 0
            @disconfirming_count = 0
            @created_at          = Time.now.utc
            @last_tested_at      = nil
          end

          def test_with_evidence!(evidence_type:, weight: 0.1)
            raise ArgumentError, "unknown evidence_type: #{evidence_type}" unless Constants::EVIDENCE_TYPES.include?(evidence_type)

            @evidence_count   += 1
            @last_tested_at    = Time.now.utc

            case evidence_type
            when :confirming
              @confirming_count += 1
              @confidence = (@confidence + (Constants::CONFIDENCE_BOOST * weight * 10)).clamp(0.0, 1.0)
            when :disconfirming
              @disconfirming_count += 1
              @confidence = (@confidence - (Constants::CONFIDENCE_PENALTY * weight * 10)).clamp(0.0, 1.0)
            when :neutral
              # no confidence change
            when :ambiguous
              delta = @confidence - 0.5
              @confidence = (@confidence - (delta * 0.1)).clamp(0.0, 1.0)
            end

            self
          end

          def confidence_label
            Constants::CONFIDENCE_LABELS.find { |entry| entry[:range].cover?(@confidence) }&.fetch(:label) || :rejected
          end

          def validity
            total = @confirming_count + @disconfirming_count
            return 0.5 if total.zero?

            @confirming_count.to_f / total
          end

          def validity_label
            v = validity
            Constants::VALIDITY_LABELS.find { |entry| entry[:range].cover?(v) }&.fetch(:label) || :refuted
          end

          def needs_testing?
            @confidence.between?(0.3, 0.7)
          end

          def decay!
            @confidence = (@confidence - Constants::CONFIDENCE_DECAY).clamp(0.0, 1.0)
            self
          end

          def to_h
            {
              id:                  @id,
              claim:               @claim,
              domain:              @domain,
              confidence:          @confidence,
              confidence_label:    confidence_label,
              evidence_count:      @evidence_count,
              confirming_count:    @confirming_count,
              disconfirming_count: @disconfirming_count,
              validity:            validity.round(3),
              validity_label:      validity_label,
              needs_testing:       needs_testing?,
              created_at:          @created_at,
              last_tested_at:      @last_tested_at
            }
          end
        end
      end
    end
  end
end
