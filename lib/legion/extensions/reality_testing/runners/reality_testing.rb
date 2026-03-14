# frozen_string_literal: true

module Legion
  module Extensions
    module RealityTesting
      module Runners
        module RealityTesting
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_belief(claim:, domain: :general, confidence: nil, **)
            conf   = confidence || Helpers::Constants::DEFAULT_CONFIDENCE
            result = reality_engine.create_belief(claim: claim, domain: domain, confidence: conf)
            Legion::Logging.info "[reality_testing] create_belief claim=#{claim[0, 60]} domain=#{domain}"
            result
          end

          def test_belief(belief_id:, evidence_type:, weight: 0.1, **)
            etype = evidence_type.to_sym
            reality_engine.test_belief(belief_id: belief_id, evidence_type: etype, weight: weight)
          end

          def get_belief(belief_id:, **)
            engine = reality_engine
            belief = engine.instance_variable_get(:@beliefs)[belief_id]
            return { found: false, belief_id: belief_id } unless belief

            { found: true, belief: belief.to_h }
          end

          def beliefs_needing_testing(**)
            beliefs = reality_engine.beliefs_needing_testing
            Legion::Logging.debug "[reality_testing] needs_testing count=#{beliefs.size}"
            { count: beliefs.size, beliefs: beliefs.map(&:to_h) }
          end

          def strongest_beliefs(limit: 10, **)
            beliefs = reality_engine.strongest_beliefs(limit: limit)
            { count: beliefs.size, beliefs: beliefs.map(&:to_h) }
          end

          def weakest_beliefs(limit: 10, **)
            beliefs = reality_engine.weakest_beliefs(limit: limit)
            { count: beliefs.size, beliefs: beliefs.map(&:to_h) }
          end

          def beliefs_by_domain(domain:, **)
            beliefs = reality_engine.beliefs_by_domain(domain: domain.to_sym)
            { domain: domain, count: beliefs.size, beliefs: beliefs.map(&:to_h) }
          end

          def overall_coherence(**)
            coherence = reality_engine.overall_reality_coherence
            Legion::Logging.debug "[reality_testing] coherence=#{coherence.round(3)}"
            { coherence: coherence.round(3) }
          end

          def decay_beliefs(**)
            count = reality_engine.decay_all
            Legion::Logging.debug "[reality_testing] decay_all count=#{count}"
            { decayed: count }
          end

          def prune_rejected_beliefs(**)
            pruned = reality_engine.prune_rejected
            { pruned: pruned }
          end

          def reality_report(**)
            reality_engine.reality_report
          end

          def reality_status(**)
            {
              total_beliefs:   reality_engine.size,
              coherence:       reality_engine.overall_reality_coherence.round(3),
              needing_testing: reality_engine.beliefs_needing_testing.size
            }
          end

          private

          def reality_engine
            @reality_engine ||= Helpers::RealityEngine.new
          end
        end
      end
    end
  end
end
