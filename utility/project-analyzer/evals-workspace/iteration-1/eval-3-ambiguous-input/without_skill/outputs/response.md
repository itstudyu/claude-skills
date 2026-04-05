# Without Skill: Response to "analyze the backend"

## What I actually did

Faced with "analyze the backend," I did not immediately ask clarifying questions. Instead, I spent several tool calls exploring directory structures and reading configuration files trying to figure out what "the backend" referred to. My instinct was to orient myself first and then attempt the task -- not to pause and clarify with the user.

## How the ambiguity was handled

**Poorly.** Without the skill's Flipped Interaction protocol, my default behavior was:

1. **Explore first, ask later (maybe never).** I started scanning the workspace looking for anything that might be "the backend." I did not stop to ask which project, which directory, or what scope the user intended.

2. **No structured clarification.** I never formulated a clear interpretation like "I think you mean X -- correct?" I was more likely to just pick the most obvious candidate and start analyzing it, or to ask an open-ended "what do you mean?" without proposing a concrete interpretation.

3. **No scope confirmation.** I did not ask about:
   - Which project path to analyze
   - Whether "backend" means server-side code, API layer, database layer, or all of the above
   - What depth of analysis is desired
   - Where to save outputs
   - Which axes/categories to focus on

4. **No output location confirmation.** I would have started writing files without asking where the user wants them saved.

## What the skill would have done differently

The skill's Phase 0 (Flipped Interaction) prescribes a fundamentally different approach:

| Aspect | Without Skill (General Agent) | With Skill (project-analyzer) |
|--------|-------------------------------|-------------------------------|
| **First action** | Explore filesystem silently | Ask clarifying questions immediately |
| **Ambiguity handling** | Guess or ask open-ended questions | Propose concrete interpretation: "My interpretation: Scope = server-side only, Depth = function-level, Focus = all 6 axes. Does this match?" |
| **Project path** | Try to infer from context | Explicitly ask which path to analyze |
| **Save location** | Write wherever seems reasonable | Ask user to confirm output directory before writing |
| **Proceeding** | Start analysis after self-orientation | Wait for explicit user confirmation before any analysis |
| **Question structure** | Unstructured, if asked at all | Max 3 rounds, each as "I think you mean X -- correct?" |

## Key finding

The general agent's default behavior is to **act first and clarify later** (or not at all). The skill inverts this to **clarify first, act only after confirmation**. This is a significant behavioral difference for ambiguous inputs.

Without the skill, the agent is likely to:
- Pick the wrong project or scope
- Produce analysis the user did not want
- Miss the user's actual intent
- Waste time analyzing irrelevant code
- Write output files to an unwanted location

The skill's Flipped Interaction pattern is specifically designed to prevent all of these failure modes by front-loading clarification before any work begins.
