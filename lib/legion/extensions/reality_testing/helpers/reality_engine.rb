# frozen_string_literal: true

module Legion
  module Extensions
    module RealityTesting
      module Helpers
        class RealityEngine
          def initialize
            @beliefs     = {}
            @next_id     = 1
          end

          def create_belief(claim:, domain: :general, confidence: Constants::DEFAULT_CONFIDENCE)
            return { created: false, reason: :at_capacity } if @beliefs.size >= Constants::MAX_BELIEFS

            id = "belief_#{@next_id}"
            @next_id += 1
            belief = Belief.new(id: id, claim: claim, domain: domain, confidence: confidence)
            @beliefs[id] = belief
            Legion::Logging.debug "[reality_testing] create_belief id=#{id} domain=#{domain} confidence=#{confidence.round(2)}"
            { created: true, belief: belief.to_h }
          end

          def test_belief(belief_id:, evidence_type:, weight: 0.1)
            belief = @beliefs[belief_id]
            return { tested: false, reason: :not_found } unless belief

            belief.test_with_evidence!(evidence_type: evidence_type, weight: weight)
            Legion::Logging.debug "[reality_testing] test_belief id=#{belief_id} evidence=#{evidence_type} confidence=#{belief.confidence.round(2)}"
            { tested: true, belief: belief.to_h }
          end

          def beliefs_needing_testing
            @beliefs.values.select(&:needs_testing?)
          end

          def strongest_beliefs(limit: 10)
            @beliefs.values
                    .sort_by { |b| -b.confidence }
                    .first(limit)
          end

          def weakest_beliefs(limit: 10)
            @beliefs.values
                    .sort_by(&:confidence)
                    .first(limit)
          end

          def beliefs_by_domain(domain:)
            @beliefs.values.select { |b| b.domain == domain }
          end

          def overall_reality_coherence
            return 0.0 if @beliefs.empty?

            total = @beliefs.values.sum(&:validity)
            total / @beliefs.size
          end

          def decay_all
            @beliefs.each_value(&:decay!)
            @beliefs.size
          end

          def prune_rejected
            before = @beliefs.size
            @beliefs.delete_if { |_id, b| b.confidence < 0.1 }
            pruned = before - @beliefs.size
            Legion::Logging.debug "[reality_testing] prune_rejected pruned=#{pruned} remaining=#{@beliefs.size}"
            pruned
          end

          def reality_report
            domains = @beliefs.values.group_by(&:domain)
            {
              total_beliefs:   @beliefs.size,
              coherence:       overall_reality_coherence.round(3),
              needing_testing: beliefs_needing_testing.size,
              domains:         domains.transform_values(&:size),
              strongest_claim: @beliefs.values.max_by(&:confidence)&.claim,
              weakest_claim:   @beliefs.values.min_by(&:confidence)&.claim
            }
          end

          def to_h
            {
              belief_count: @beliefs.size,
              coherence:    overall_reality_coherence.round(3),
              beliefs:      @beliefs.values.map(&:to_h)
            }
          end

          def size
            @beliefs.size
          end
        end
      end
    end
  end
end
