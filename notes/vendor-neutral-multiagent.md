# Prompt

I want to experiment with mult-agent / subagent based software development with an orchestrating main context. I'm using copilot cli but it seems teams and subagents is more an anthropic / claude thing. I want to build up a capability that isn't tightly coupled to any implementation. Currently I'm using copilot cli as my chat interface. Should I change to claude code cli instead or abandon the idea of coming up with something that is not vendor locked-in?

# Answer

Short answer: **don’t abandon vendor‑neutral multi‑agent ideas—but don’t expect the CLI alone to be the abstraction layer**. The cleanest path is to **treat agents as a capability of *your* orchestrator**, not of Copilot CLI, Claude Code, or any other vendor tool. Then you can use **either CLI (or both)** as interchangeable frontends.

Below I’ll break this down pragmatically, from a systems‑architect perspective.

***

## 1. Reality check: where “sub‑agents” actually live

You’ve already noticed something important:

*   **“Teams”, “sub‑agents”, “functions”, etc. are *product semantics***, not fundamental capabilities.
*   The underlying primitives are much simpler:
    *   prompt construction
    *   role/context isolation
    *   state passing
    *   tool invocation
    *   turn routing

Anthropic (Claude Code) and OpenAI (Copilot) expose **different metaphors**, but they are all wrappers over the same underlying ideas.

**Key insight:**  
👉 *Multi‑agent systems are an orchestration pattern, not a model feature.*

***

## 2. Copilot CLI vs Claude Code CLI (today)

### Copilot CLI

**Strengths**

*   Tight integration with GitHub, repo context, PR workflows
*   Good for *single context* coding assistance
*   Enterprise friendly

**Limitations**

*   No native concept of:
    *   agent hierarchies
    *   persistent agent roles
    *   explicit orchestration
*   You’re effectively managing one evolving prompt thread

**Implication**
You can *simulate* sub‑agents (prompt prefixes, delimiters, role tags), but orchestration logic has to live **outside** Copilot.

***

### Claude Code CLI

**Strengths**

*   Explicit support for:
    *   task decomposition
    *   “specialist” behavior
*   Friendly for agent‑style workflows

**Limitations**

*   The abstractions (teams, specialists) are **Claude‑specific**
*   Harder to lift out without re‑implementing semantics

**Implication**
Better UX for experiments, but **higher conceptual lock‑in** if you rely on its agent metaphors directly.

***

## 3. The trap to avoid

> “Should I switch CLIs to get multi‑agent capability?”

That’s the wrong axis.

If you build *against*:

*   Claude “teams”
*   OpenAI “functions”
*   Copilot “workspace context”

…you will **inevitably be vendor‑locked**, regardless of CLI choice.

***

## 4. The right architectural boundary

### Treat LLMs as **stateless workers**

Agents should not be:

*   long‑lived in the model
*   aware of each other implicitly

Instead:

```text
[ Orchestrator ]
   |
   +-- Agent Spec (role, goals, constraints)
   +-- Context Slice
   +-- Tool Permissions
          |
          v
     [ LLM Call ]
```

Where:

*   **Agents are just configurations**
*   **State lives in your orchestrator**, not the model
*   **The model is replaceable**

This is the same principle as:

*   Erlang processes
*   actor systems
*   Kubernetes controllers

***

## 5. What “vendor neutral” actually looks like

### A. Define your own agent schema

Example (conceptual, not tied to Claude/OpenAI):

```yaml
agent:
  name: api-designer
  responsibilities:
    - define REST contracts
    - identify breaking changes
  inputs:
    - requirements.md
    - existing_openapi.yaml
  outputs:
    - openapi.yaml
  constraints:
    - backward compatible
    - no auth changes
```

### B. Orchestrator decides

*   when to invoke the agent
*   what context slice to give it
*   how to validate outputs
*   whether to retry or escalate

### C. CLI = just a shell

Use:

*   Copilot CLI
*   Claude Code
*   plain HTTP
*   local model

…as a **transport**, not a design dependency.

***

## 6. How this works with Copilot CLI *today*

You can still do multi‑agent development:

*   Maintain a `/agents/` directory
*   Each agent has:
    *   role definition
    *   expected IO
    *   evaluation rubric
*   Your orchestration script:
    *   invokes Copilot CLI multiple times
    *   injects role‑specific prompts
    *   captures outputs
    *   feeds structured summaries to the next agent

Yes, it’s more work than Claude Code.
But:

*   it’s portable
*   it’s explicit
*   it’s auditable

***

## 7. When Claude Code *does* make sense

Claude Code is useful if:

*   you’re **exploring interaction patterns**
*   you want fast feedback on agent collaboration UX
*   you’re comfortable later rebuilding the core abstractions

**Think of it as a research environment**, not a foundation.

***

## 8. A pragmatic recommendation (for you specifically)

Given you’re a Lead Systems Architect:

### ✅ Don’t abandon vendor neutrality

But also…

### ✅ Don’t fetishize purity

**Recommended setup**

*   ✅ Keep Copilot CLI as the daily driver
*   ✅ Build a lightweight orchestrator layer:
    *   agent registry
    *   prompt composer
    *   context router
*   ✅ Optionally experiment with Claude Code **in parallel**
*   ✅ Port only *ideas*, never *abstractions*

If tomorrow:

*   Copilot improves agent support → you adopt it
*   Claude changes APIs → you’re unaffected
*   You move to local models → same orchestrator works

***

## 9. Mental model to carry forward

> **Agents are not things the LLM knows about.  
> They are things *you* know about.**

Once that clicks, the vendor question mostly disappears.

***

If you want, next we can:

*   sketch a **vendor‑neutral agent orchestration loop**
*   design a **file‑based or event‑driven agent protocol**
*   map how Copilot CLI, Claude Code, and raw APIs plug into the same core

Just tell me which direction you want to go.
