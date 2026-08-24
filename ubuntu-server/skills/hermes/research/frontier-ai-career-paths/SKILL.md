---
name: frontier-ai-career-paths
description: Evaluate and plan careers at frontier AI labs (Anthropic, OpenAI, DeepMind). Distinct from "AI Engineer" roadmap-of-the-day content. Covers the three real career layers (application / infra / research), what each lab actually hires for, math and stack requirements, and realistic trajectories for users with non-traditional backgrounds. Use when the user asks how to work at a place like Anthropic, what to study to build AI models themselves, or to distinguish career-hype content from real lab requirements.
---

# Frontier AI Career Paths

## When to load this skill

Load whenever the user asks about working at a frontier AI lab (Anthropic / OpenAI / DeepMind / Mistral), what to study to "build the models themselves" rather than use them via API, or when they bring a "roadmap" from X/YouTube and want to know if it's the real stack. Also load when they ask about research-engineer interviews, what math they need, or whether their non-PhD background blocks them.

Do NOT load for: building LLM apps, using Claude/GPT APIs, menu-driven ML tutorials, or generic "how do I learn AI" questions that don't touch the frontier-lab career layer.

## The core distinction — three career layers

People conflate these into one "AI" career. They are different careers with different requirements:

| Layer | What you do | Example role | Hired by frontier labs directly? |
|-------|-------------|--------------|------------------------------------|
| **Application** | Use model APIs. Build RAG, agents, chatbots, AI products. | AI Engineer / LLM app engineer | No — labs don't hire for this much |
| **Infra / Serving** | Deploy, serve, scale models in production. vLLM, distributed serving, GPU clusters, ETL pipelines. | ML Infrastructure Engineer | Yes — and Java/JVM is a real advantage here (Spark/Kafka/Flink) |
| **Research / Core** | Design architectures, train models from scratch, optimize kernels, align. Read papers, implement, publish. | Research Engineer / Research Scientist / Member of Technical Staff | Yes — primary MTS hiring at Anthropic |

The 12-stage roadmaps on X (Python -> RAG -> Prompt Engineering -> Agents -> "Build AI") cover **Layer 1**. They do NOT prepare you for Anthropic. Anthropic hires Layer 3 primarily, Layer 2 selectively.

## What to say about X/Twitter "AI Engineer roadmaps"

Candid, not diplomatic: they are engagement content, not study plans. Good as a topic index (what exists in the field), useless as a curriculum. Specifically:
- No depth, no projects, no time estimates, no pass criteria.
- Putting "Prompt Engineering" at the same level as "Deep Learning" inflates the count.
- "Statistics & Linear Algebra" as 1/12 of a roadmap is misleading — it's the foundation of everything that follows.
- No mention of data engineering, evaluation, MLOps, cost trade-offs, alignment, interpretability.
- Linear flow is a pedagogical lie — people enter through use and retrocede to fundamentals.

Don't moralize. Say what they're useful for (topic index) and what they're not (a plan).

## What frontier labs actually hire for — see `references/anthropic-research-engineer.md`

That reference has the verified Anthropic Research Engineer (Pre-training) requirements extracted live from the job posting: salary ($350K-$850K USD), MS/PhD preferred, location SF/Seattle/NYC hybrid, visa sponsorship available, sample projects, interview loop.

Key recurring facts (cross-lab, not just Anthropic):
- **Acceptance rate for research roles is sub-1%** even among onsite candidates.
- **Coding screen is NOT LeetCode.** It's ML-native: implement attention from scratch in PyTorch, diagnose "broken neural net" bugs by reasoning about gradients, debug training dynamics.
- **Research taste > coding.** Anthropic explicitly evaluates: research intuition, research taste, calibrated epistemic honesty, intellectual humility under pressure. They phrase it as: "We don't hire the best coders who happen to know ML. We hire people who demonstrate research taste."
- **Interview probe pattern:** interviewer pushes into a topic until you reach the edge of what you know. Correct answer = "I'm not certain, but here's how I would reason about it." Incorrect = confabulated confidence.
- **PhD is not hard-required**, but common. ML Infrastructure roles are more flexible on credentials and reward distributed-systems experience.

## Math requirements (don't soften this)

Telling someone "you don't need much math" is malpractice for this career track. The minimum honest list:

| Area | Why | Specific topics |
|------|-----|-----------------|
| Linear Algebra | A transformer IS linear algebra | Tensors, matrix multiplication, SVD (for interpretability), eigenvectors, projections |
| Multivariable Calculus | Backpropagation | Partial derivatives, chain rule (the whole backprop), gradients, Jacobians |
| Probability & Statistics | Understanding outputs, sampling, RLHF | Distributions, Bayes, expectation, variance, KL divergence, softmax |
| Optimization | Training = optimizing | GD, Adam, learning rates, loss landscapes, convex vs non-convex |
| Information Theory | Tokens, compression, attention | Entropy, cross-entropy (the literal LLM loss), mutual information |
| Reinforcement Learning | RLHF — how Claude gets safe | PPO, reward modeling, policy gradients |

Bonus that distinguishes: complexity theory, differential geometry/manifold learning (interpretability), control theory (alignment research).

## Stack actually required

**Python + PyTorch is non-negotiable** for research roles. No path around it. Java does NOT get you in through the research door.

**Java IS a real advantage for ML Infrastructure roles.** Anthropic's "ML Infrastructure Engineer, Safeguards Research" type roles want GPUs, Kubernetes, OS internals, large-scale ETL — all of which are JVM territory (Spark/Kafka/Flink). This is the realistic non-PhD entry.

**What you must be able to build (not "know exists"):**
1. A transformer from scratch in PyTorch — every component, no copying.
2. A full training loop: forward, loss, backward, optimizer step, gradient clipping, LR scheduling, checkpointing.
3. Debug a broken neural net — diagnose subtle gradient/attention bugs by reasoning about dynamics.
4. Implement a recent paper and reproduce results.
5. Reason about distributed training: data parallel, tensor parallel, pipeline parallel, why a batch won't fit on one GPU.

## Realistic trajectory for a non-traditional candidate

Do NOT promise this is easy or fast. The honest framing:

| Phase | Time | Goal |
|-------|------|------|
| Foundation | Now to 2 yrs | Math bases (calc, linalg, prob), read Anthropic papers chronologically, first transformer from scratch, PyTorch fluency |
| Applied research | Yrs 3-4 | Implement papers publicly, summer research / REU / collaborate with a professor, public artifacts |
| Transition | Yr 4-5 | ML Engineer at a tech company FIRST (Google/Meta/Amazon ML), not frontier lab yet |
| Frontier labs | Yrs 5-7 | Apply to Anthropic/OpenAI/DeepMind via either: (a) strong public research artifacts, (b) MS/PhD path, (c) ML Infra track via distributed-systems experience |

For users with Java + Python + operational infra experience (Docker/Linux/Tailscale/Caddy), the realistic entry is **ML Infrastructure Engineer** — not Research Engineer straight in. Sell the Java/distributed-systems angle.

## Pitfall — do not give false confidence

The most common failure mode of advice here is: "follow this roadmap and you'll get in." Reality: 99% rejection at onsite. The path is real but contingent. Tell users:
- Math is not optional.
- PhD makes it materially easier — saying otherwise is dishonest.
- Five years of disciplined work is realistic, not pessimistic.
- Frontier labs are a small target, not the only valuable AI career.

At the same time, do NOT discourage ambition. The path exists. Non-PhD entries exist. Young age is a real asset (time). Give the honest version, including the hard parts, and a concrete plan.

## Today actions (when user is ready to start)

1. Read "Attention Is All You Need" (Vaswani 2017). If not understood, that's the gap.
2. 3Blue1Brown neural network + attention series — best visual entry to the math.
3. Stanford CS224N (NLP with Deep Learning) — free on YouTube.
4. Andrej Karpathy "Let's build GPT from scratch" — standard entry to from-scratch implementation.

Do NOT recommend jumping to RAG/LangChain/agents if the goal is research engineering. That's Layer 1 content. It distracts from the math + from-scratch foundation.

## Reference files

- `references/anthropic-research-engineer.md` — verified Anthropic Research Engineer job posting (Pre-training role), interview process shape from coaching accounts, math/stack breakdown, common interview probe patterns. Re-read before any Anthropic-specific career answer — it has the concrete numbers and quotes.
- `references/krailynd-notion-roadmap.md` — YOUR_NAME's personal 10-phase AI engineering roadmap in Notion (structure, phase IDs, analysis pattern). Read when evaluating his roadmap or advising on career track decisions. Has the "what it does right / what to flag" framework.

## Overlap notes

- `investiga` — for fetching the latest job postings from frontier labs (X, lab careers pages, greenhouse boards). Use it when refreshing the reference.
- `research-paper-writing` — the next layer up once a user starts producing research artifacts. Adjacent, not overlapping.
- No career-planning umbrella existed before this skill; do not proliferate narrow per-lab skills. Extend this one's references/ instead.
