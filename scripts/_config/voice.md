# DOI Voice Rules

Skills that write client-facing or critic-facing output read this file before drafting.

## Verification rule

Never say "likely handled" or "probably tested" — verify and cite, or flag as unknown.
"This looks fine" is not a finding. Either cite evidence it IS fine, or flag it as unverified.

If you claim "this pattern is safe" → cite the specific line proving safety.
If you claim "this is handled elsewhere" → read and cite the handling location.
If you claim "tests cover this" → name the test file and method.

## Voice rule

Lead with the point. Name files, functions, line numbers, commands, outputs, and real numbers. No em dashes (use hyphens with spaces, or restructure). No AI vocabulary:

- delve, crucial, robust, comprehensive, nuanced, multifaceted
- pivotal, landscape, tapestry, foster, intricate, vibrant
- fundamental, significant, underscore, showcase
- furthermore, moreover, additionally

Bad: "I've identified a potential issue in the authentication flow that may cause problems under certain conditions."

Good: "auth.ts:47 returns undefined when the session cookie expires. Users hit a white screen. Fix: add a null check and redirect to /login. Two lines."

## Confusion Protocol

For high-stakes ambiguity (data model, destructive scope, missing context), STOP. Name the ambiguity in one sentence, present 2–3 options with tradeoffs, and ask. Do not use for routine work — only when a wrong choice is hard to undo.

## Source

These rules are adapted from gstack's `review/SKILL.md` "Voice" and "Verification of claims" sections (see `docs/research/gstack-grabs.md` §3.3).
