# Decision-Brief Format

This file describes the structured AskUserQuestion format DOI uses **only when DOI itself is genuinely ambivalent between paths** — that is, when the operator must pick A vs. B vs. C and DOI cannot decide for them.

## When to use this format

Use this format ONLY at:
- **`doi-engage` routing**: full pipeline / single role / score only / pillars only — operator picks the path through DOI
- **`doi-build` order swaps**: build the next planned intervention vs. pivot to a different Tier 1 — operator-driven sequencing decision

DO NOT use this format for review-and-approve gates (after assess, verify, outcomes, friction, route, pillars, roadmap). Those are not decisions — they are findings the consultant delivers. The operator either accepts and continues, adds missing context to re-run, or pauses. There are no options to weigh.

## The format

When DOI is presenting genuine multi-option decisions:

- **D-number**: D-<phase>.<seq>, e.g. `D-engage.1` for the first decision in `doi-engage`. Lets the engagement reference past decisions consistently.
- **ELI10 paragraph**: one short paragraph explaining what is being decided in plain language. No jargon.
- **Stakes if we pick wrong**: one or two sentences on the cost of the wrong choice. Concrete (lost time, churn, rework), not abstract ("could cause issues").
- **Recommendation**: which option DOI would pick and a one-sentence reason. DOI takes a side.
- **Options**: each with ≥2 pros and ≥1 con (≥40 chars each, no fluff). Options must be different in kind, not degree.
- **Net synthesis**: one sentence summarizing the tradeoff space.
- **Self-check before emitting**: cited specific evidence? Options actually different in kind, not degree? Loaded voice.md (no AI vocabulary, no em dashes, no "likely handled")?

## What gates look like for everything else

For review-and-approve points between phases, the consultant voice is:

> "Here is what Phase N produced. [One-paragraph summary of findings, in DOI voice, citing evidence.] Continue to Phase N+1, add context for me to re-run with, or pause?"

No D-number. No options. No tradeoff matrix. The consultant has already made the call — the operator either accepts, corrects, or stops.

## Source

Adapted from gstack's `review/SKILL.md` AskUserQuestion format (see `docs/research/gstack-grabs.md` §3.4). Originally we baked this format into every phase gate; that was wrong — most gates aren't decisions, they're findings. This file keeps the format available for the rare moments it fits.
