# frozen_string_literal: true

module Legion
  module Extensions
    module RealityTesting
      module Helpers
        module Constants
          MAX_BELIEFS   = 300
          MAX_EVIDENCE  = 500

          DEFAULT_CONFIDENCE  = 0.5
          CONFIDENCE_BOOST    = 0.1
          CONFIDENCE_PENALTY  = 0.15
          CONFIDENCE_DECAY    = 0.02

          CONFIDENCE_LABELS = [
            { range: (0.85..1.0), label: :certain },
            { range: (0.65...0.85), label: :confident  },
            { range: (0.35...0.65), label: :tentative  },
            { range: (0.15...0.35), label: :doubtful   },
            { range: (0.0...0.15),  label: :rejected   }
          ].freeze

          EVIDENCE_TYPES = %i[confirming disconfirming neutral ambiguous].freeze

          VALIDITY_LABELS = [
            { range: (0.75..1.0),   label: :validated    },
            { range: (0.55...0.75), label: :supported    },
            { range: (0.35...0.55), label: :uncertain    },
            { range: (0.15...0.35), label: :questionable },
            { range: (0.0...0.15),  label: :refuted      }
          ].freeze
        end
      end
    end
  end
end
