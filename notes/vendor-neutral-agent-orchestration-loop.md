# Prompt

Please sketch a vendor‑neutral agent orchestration loop

# Answer

Great—this is a fun problem, and you’re asking it at exactly the right abstraction level.

Below is a **vendor‑neutral agent orchestration loop** that deliberately avoids *any* dependence on Claude/OpenAI/Copilot semantics. Think of this as an **engineered control loop**, not a “clever prompt”.

I’ll start with the **conceptual architecture**, then give a **step‑by‑step loop**, and finally a **concrete pseudo‑implementation** you could adapt to Copilot CLI, Claude Code, or raw APIs.

***

## 1. Core principle (the invariant)

> **Agents are data + policies.  
> The LLM is just a pure function: input → output.**

Everything interesting happens **outside** the model.

***

## 2. High‑level architecture

```
                  Orchestrator

      ┌────────────┐    ┌────────────────┐
      │ Task Queue │───>│ Agent Selector │
      └────────────┘    └────────────────┘
             │                   │
             v                   v
      ┌─────────┐      ┌──────────────────┐
      │ Context │─────>│ Prompt Composer  │
      │ Manager │      └──────────────────┘
      └─────────┘                │
                                 v
                          ┌────────────┐
                          │ LLM Bridge │─────┐ (Copilot / Claude /
                          └────────────┘     │  Local Model)
                                 │           │
                                 v           │
                       ┌──────────────────┐  │
                       │ Output Evaluator │  │
                       └──────────────────┘  │
                                 │           │
                                 v           │
                          ┌─────────────┐    │
                          │ State Store │<───┘
                          └─────────────┘
```

**Nothing in this diagram assumes a specific vendor.**

***

## 3. The orchestration loop (step by step)

### Step 0: Define the contracts

Before any loop runs, you define **three stable schemas**:

#### Agent definition

```yaml
id: api_designer
role: Define and evolve public APIs
inputs:
  - requirements
  - existing_openapi
outputs:
  - updated_openapi
constraints:
  - backward_compatible
rubric:
  - no breaking changes
  - semantic versioning rules followed
```

#### Task definition

```yaml
task_id: T-042
goal: Add pagination support to list endpoints
artifacts:
  requirements.md
  openapi.yaml
status: pending
```

#### State definition

```yaml
artifacts:
  openapi.yaml
  requirements.md
history:
  - agent: api_designer
    output_ref: run-123
```

These are **LLM‑agnostic contracts**.

***

### Step 1: Task intake

The orchestrator pulls the next task:

```text
task = dequeue(task_queue)
```

No model call yet.

***

### Step 2: Agent selection

This can be trivial or sophisticated:

```text
agent = select_agent(task.goal, task.artifacts)
```

Rules‑based example:

*   API change → `api_designer`
*   Code change → `implementation_agent`
*   Verification → `reviewer_agent`

Later, this selection itself can be LLM‑driven—but that’s optional.

***

### Step 3: Context slicing (critically important)

The orchestrator decides:

*   **what the agent sees**
*   **what it does not**

```text
context = build_context(
  agent.inputs,
  global_state.artifacts,
  token_budget
)
```

This is *the* lever that makes multi‑agent systems scale.

Example:

*   API designer never sees UI code
*   Reviewer never sees system prompts
*   Planner never sees raw diffs

***

### Step 4: Prompt composition

Now (and only now) you generate a prompt:

```text
prompt =
  SYSTEM: agent.role + agent.constraints
  INPUTS: context
  TASK: task.goal
  OUTPUT_SCHEMA: agent.outputs
```

This is where Copilot CLI, Claude Code, or API calls plug in—but **only here**.

***

### Step 5: LLM invocation (black box)

```text
raw_output = llm_bridge.invoke(prompt)
```

The orchestrator does **not** trust this output yet.

This function can be backed by:

*   `copilot chat`
*   `claude code`
*   `openai.responses`
*   `ollama`
*   a future model

***

### Step 6: Output evaluation

This step is what most demos skip (and why they collapse).

```text
result = evaluate(
  raw_output,
  agent.rubric,
  expected_schema
)
```

Outcomes:

*   ✅ Accepted
*   🔁 Retry (same agent, modified prompt)
*   🔀 Escalate (different agent)
*   ❌ Fail task

Evaluation can be:

*   schema validation
*   diff analysis
*   test execution
*   even *another* agent acting as a critic

***

### Step 7: State update

```text
update_state(
  artifacts = result.outputs,
  history += { agent, prompt_hash, output_ref }
)
```

The **state store is your source of truth**, not the model memory.

***

### Step 8: Loop / termination

```text
if task.complete:
    mark_done(task)
else:
    enqueue(next_subtask)
```

You now either:

*   continue the pipeline
*   fan out into parallel agents
*   halt safely

***

## 4. Minimal orchestration loop (pseudo‑code)

This is intentionally boring—and that’s a compliment.

```python
while tasks.remaining():
    task = tasks.next()

    agent = select_agent(task)
    context = slice_context(agent, state)

    prompt = compose_prompt(agent, task, context)
    output = llm.invoke(prompt)

    evaluation = evaluate_output(agent, output)

    if evaluation.accepted:
        state.apply(evaluation.results)
        tasks.advance(task)
    elif evaluation.retryable:
        tasks.retry(task, adjustments=evaluation.feedback)
    else:
        tasks.escalate(task)
```

No vendor assumptions.
No magic agent teams.
No hidden memory.

***

## 5. Why this stays vendor‑neutral

| Concern            | Where it lives           |
| ------------------ | ------------------------ |
| Prompt format      | Your composer            |
| Context window     | Your slicer              |
| Agent coordination | Your loop                |
| Memory             | Your state store         |
| Tool calls         | Your executor            |
| Model choice       | One replaceable function |

Claude, Copilot, OpenAI, local models—all become **pluggable workers**.

***

## 6. How this maps to Copilot CLI *today*

*   `llm.invoke()` → `copilot chat --prompt <file>`
*   Agents → directories (`/agents/api_designer`)
*   Context → assembled temp files
*   State → git + structured logs
*   Evaluation → scripts, tests, diff checks

Not elegant—but architecturally clean.

***

## 7. Key takeaway

> **If your agent system can be replayed deterministically without an LLM,  
> you’ve designed it correctly.**

Everything else is implementation detail.

***

If you want next, we can:

*   add **parallel fan‑out with quorum voting**
*   design a **file‑based agent protocol**
*   or implement a **thin orchestrator specifically tuned for Copilot CLI**

Just tell me where you want to go next.

