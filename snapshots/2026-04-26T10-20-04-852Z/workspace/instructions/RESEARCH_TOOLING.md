# Research Tooling Overlay

## Preferred research engines
1. Perplexity (via local wrapper): `scripts/perplexity-search.sh`
2. Built-in web fetch/search fallbacks when Perplexity key path is unavailable.

## Perplexity integration notes
- Installed skill: `skills/perplexity-safe`
- Wrapper: `scripts/perplexity-search.sh`
- Key source: Bitwarden secure note `Perplexity.ai API key` (via `rbw`)
- Key source is Bitwarden (`rbw`) secure note only

## Usage examples
```bash
scripts/perplexity-search.sh --list-models
scripts/perplexity-search.sh -f markdown "latest AI policy updates"
```

## Quality rules
- For outbound news/current-events summaries, include direct links/citations.
- If a source cannot be validated, explicitly mark uncertainty.
