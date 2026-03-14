# lex-reality-testing

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-reality-testing`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::RealityTesting`

## Purpose

Belief formation and evidence-based confidence updating. Maintains a registry of beliefs (claim + domain + confidence). Each belief can be tested with evidence (confirming, disconfirming, neutral, ambiguous), which adjusts confidence via `CONFIDENCE_BOOST` or `CONFIDENCE_PENALTY`. Beliefs decay each tick. Low-confidence beliefs (< 0.1) are prunable. Overall reality coherence is the mean validity across all beliefs.

## Gem Info

- **Homepage**: https://github.com/LegionIO/lex-reality-testing
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/reality_testing/
  version.rb
  client.rb
  helpers/
    constants.rb        # Thresholds, CONFIDENCE_LABELS, EVIDENCE_TYPES, VALIDITY_LABELS, limits
    belief.rb           # Belief class — claim with confidence and evidence tracking
    reality_engine.rb   # RealityEngine — belief registry with coherence scoring
  runners/
    reality_testing.rb  # Runner module
spec/
  helpers/constants_spec.rb
  helpers/belief_spec.rb
  helpers/reality_engine_spec.rb
  runners/reality_testing_spec.rb
  client_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `MAX_BELIEFS = 300`, `MAX_EVIDENCE = 500`
- `DEFAULT_CONFIDENCE = 0.5`, `CONFIDENCE_BOOST = 0.1`, `CONFIDENCE_PENALTY = 0.15`, `CONFIDENCE_DECAY = 0.02`
- `CONFIDENCE_LABELS`: `:certain` (0.85+), `:confident` (0.65+), `:tentative` (0.35+), `:doubtful` (0.15+), `:rejected` (< 0.15)
- `EVIDENCE_TYPES = %i[confirming disconfirming neutral ambiguous]`
- `VALIDITY_LABELS`: `:validated` (0.75+), `:supported`, `:uncertain`, `:questionable`, `:refuted`

## Runners

| Method | Key Parameters | Returns |
|---|---|---|
| `create_belief` | `claim:`, `domain: :general`, `confidence:` | `{ created:, belief: }` |
| `test_belief` | `belief_id:`, `evidence_type:`, `weight: 0.1` | `{ tested:, belief: }` |
| `get_belief` | `belief_id:` | `{ found:, belief: }` |
| `beliefs_needing_testing` | — | `{ count:, beliefs: }` |
| `strongest_beliefs` | `limit: 10` | sorted by confidence desc |
| `weakest_beliefs` | `limit: 10` | sorted by confidence asc |
| `beliefs_by_domain` | `domain:` | beliefs in domain |
| `overall_coherence` | — | `{ coherence: }` (mean validity across all beliefs) |
| `decay_beliefs` | — | `{ decayed: count }` |
| `prune_rejected_beliefs` | — | `{ pruned: count }` (removes beliefs with confidence < 0.1) |
| `reality_report` | — | totals, coherence, needing_testing, domain distribution, strongest/weakest claim |
| `reality_status` | — | `{ total_beliefs:, coherence:, needing_testing: }` |

## Helpers

### `Helpers::Belief`
Single belief: `id` (sequential "belief_N"), `claim`, `domain`, `confidence` (clamped 0–1). `test_with_evidence!(evidence_type:, weight:)` applies `CONFIDENCE_BOOST` (confirming) or `CONFIDENCE_PENALTY` (disconfirming) scaled by weight. `validity` derived from confidence. `needs_testing?` = tested fewer than threshold times. `confidence_label`, `validity_label` mapped from constants.

### `Helpers::RealityEngine`
Manages `@beliefs` hash with sequential ID counter. `create_belief` returns capacity error at `MAX_BELIEFS`. `test_belief` delegates to Belief. `beliefs_needing_testing` filters. `strongest_beliefs` / `weakest_beliefs` sort by confidence. `beliefs_by_domain` filters. `overall_reality_coherence` = mean validity. `decay_all` applies `CONFIDENCE_DECAY` to all. `prune_rejected` removes beliefs below 0.1 confidence. `reality_report` aggregates.

## Integration Points

- `create_belief` can receive claims from `lex-prediction` prediction outcomes
- `test_belief` can process evidence signals from `lex-memory` trace retrieval
- `overall_coherence` feeds `lex-reflection` as a reality orientation health metric
- `beliefs_needing_testing` triggers investigation tasks in `lex-planning`
- Low-coherence states can elevate anxiety in `lex-emotion`
- `reality_status` can feed `lex-tick`'s `post_tick_reflection` phase

## Development Notes

- Belief IDs are sequential strings ("belief_1", "belief_2") not UUIDs — predictable for testing
- `overall_reality_coherence` = mean of `validity` across all beliefs (0.0 if empty)
- `prune_rejected` threshold is hardcoded at 0.1 (separate from `CONFIDENCE_LABELS[:rejected]` < 0.15)
- Evidence weight parameter scales the boost/penalty: `effective = BOOST * weight`
- `decay_all` returns count of beliefs (not pruned count)
- All state is in-memory; reset on process restart
