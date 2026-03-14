# lex-reality-testing

Belief formation and evidence-based confidence updating for the LegionIO cognitive architecture.

## What It Does

Maintains a registry of beliefs (claim + domain + confidence score). Each belief can be tested with evidence — confirming evidence boosts confidence, disconfirming evidence penalizes it. Confidence decays each tick. Low-confidence beliefs can be pruned. Overall reality coherence is computed as the mean validity across all active beliefs.

## Usage

```ruby
client = Legion::Extensions::RealityTesting::Client.new

# Register a belief
b = client.create_belief(
  claim:      'The API endpoint is available at port 8080',
  domain:     :infrastructure,
  confidence: 0.7
)
belief_id = b[:belief][:id]

# Test with evidence
client.test_belief(belief_id: belief_id, evidence_type: :confirming, weight: 0.5)
# => { tested: true, belief: { confidence: 0.75, confidence_label: :confident, ... } }

client.test_belief(belief_id: belief_id, evidence_type: :disconfirming, weight: 0.3)
# => { tested: true, belief: { confidence: 0.705, confidence_label: :confident, ... } }

# Query beliefs
client.strongest_beliefs(limit: 5)
client.beliefs_needing_testing
client.beliefs_by_domain(domain: :infrastructure)

# System coherence
client.overall_coherence
# => { coherence: 0.71 }

# Reports
client.reality_report
client.reality_status

# Periodic maintenance
client.decay_beliefs
client.prune_rejected_beliefs
```

## Evidence Types

`:confirming`, `:disconfirming`, `:neutral`, `:ambiguous`

## Confidence Labels

`:certain` (>= 0.85), `:confident` (>= 0.65), `:tentative` (>= 0.35), `:doubtful` (>= 0.15), `:rejected` (< 0.15)

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
