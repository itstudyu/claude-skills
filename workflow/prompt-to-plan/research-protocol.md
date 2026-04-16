# Domain Research Protocol (Deep Tier Only)

Only activate for Deep tier or when the user explicitly requests research.

1. Construct 2-3 WebSearch queries:
   - `"{domain} best practices {current_year}"`
   - `"{specific_task} implementation patterns"`
   - `"site:docs.anthropic.com {topic}"` or official docs for mentioned tools
2. Prioritize: official documentation > established tech blogs > conference talks > community forums
3. Extract actionable patterns and incorporate into `<context>` and `<constraints>`
4. Maximum 3 WebSearch calls — avoid analysis paralysis

## Sequential Reflection

After each WebSearch result:
1. Extract 2-3 actionable findings with confidence tags (see below)
2. Check: does this change my understanding of the problem?
3. Decide: does the next planned query still make sense, or should I adjust it?
4. If two findings conflict, note the disagreement — the final query may resolve it

This means the second and third queries may differ from what you originally
planned. That is the point — each search informs the next.

Stop early if the first query already provides sufficient high-confidence
findings. Do not use all 3 queries just because you can.

## Confidence Tagging

Tag each finding before incorporating into the spec:

- **High confidence** — Official documentation, first-party source, verified by
  multiple authoritative references. Incorporate directly into `<constraints>`.
- **Medium confidence** — Established blog, conference talk, single authoritative
  source. Incorporate into `<context>` as "recommended practice" with source noted.
- **Low confidence** — Community forum, single blog post, unverified claim.
  Mention in `<context>` as "one approach suggests..." or omit if alternatives exist.

When two sources contradict, note both positions in `<context>` and flag for user
decision: "Source A recommends X, Source B recommends Y. Which approach fits
your team's preferences?"

## Domain-Specific Query Patterns

```
# Software Development
"{language} coding conventions official style guide"
"{framework} architecture patterns {year}"

# Web Frontend
"{framework} component design patterns {year}"
"{framework} state management best practices"

# Backend / API
"REST API design guidelines {year}"
"{database} query optimization guide"

# DevOps / Infrastructure
"{platform} deployment best practices"
"CI/CD pipeline {tool} configuration guide"

# AI / ML
"prompt engineering {model} best practices {year}"
"RAG implementation best practices {year}"
```
