# Domain Research Protocol (Deep Tier Only)

Only activate for Deep tier or when the user explicitly requests research.

1. Construct 2-3 WebSearch queries:
   - `"{domain} best practices {current_year}"`
   - `"{specific_task} implementation patterns"`
   - `"site:docs.anthropic.com {topic}"` or official docs for mentioned tools
2. Prioritize: official documentation > established tech blogs > conference talks > community forums
3. Extract actionable patterns and incorporate into `<context>` and `<constraints>`
4. Maximum 3 WebSearch calls — avoid analysis paralysis

After each WebSearch result, reflect on how the findings affect the spec
before running the next query. Let each search inform the next rather than
running all searches upfront.

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
