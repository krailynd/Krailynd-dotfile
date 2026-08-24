# Anthropic Research Engineer — verified requirements + interview loop

Extracted live on 2026-07-23 from:
- Anthropic job posting **"Research Engineer/Research Scientist, Pre-training"** (job id 4616971008, hosted at greenhouse.io/anthropic).
- Coaching account by Sundeep Teki (sundeepteki.org/advice/anthropic-research-engineer-interview-2026), describing the full RE interview loop based on a client who passed.

Refresh this file if Anthropic changes their job post or if a more recent interview account surfaces. The SKILL.md is the durable structure; this file holds the numbers and quotes that drift over time.

---

## Job posting — Research Engineer/Research Scientist, Pre-training

**Location:** Remote-friendly (travel required) / San Francisco / Seattle / NYC. Hybrid 25% in-office.
**Salary:** $350,000 — $850,000 USD per year.
**Minimum education:** Bachelor's degree or equivalent experience (fields relevant to the role demonstrated through coursework/training/professional experience).
**Visa sponsorship:** Yes, Anthropic sponsors and retains an immigration lawyer to help. Not guaranteed for every candidate, but they try if they make an offer.

### Key responsibilities (quoted)
- Conduct research and implement solutions in areas such as model architecture, algorithms, data processing, and optimizer development.
- Independently lead small research projects while collaborating on larger initiatives.
- Design, run, and analyze scientific experiments to advance understanding of large language models.
- Optimize and scale training infrastructure to improve efficiency and reliability.
- Develop and improve dev tooling to enhance team productivity.
- Contribute to the entire stack, from low-level optimizations to high-level model design.

### Qualifications (the floor, not the ceiling)
- Advanced degree (MS or PhD) in Computer Science, Machine Learning, or related field.
- Strong software engineering skills with proven track record building complex systems.
- Expertise in Python and experience with deep learning frameworks (PyTorch preferred).
- Familiarity with large-scale machine learning, particularly in context of language models.
- Ability to balance research goals with practical engineering constraints.
- Strong problem-solving and results-oriented mindset.
- Excellent communication skills and collaborative ability.
- Care about the societal impacts of your work.

### Preferred experience (what they actually want to see)
- Work on high-performance, large-scale ML systems.
- Familiarity with **GPUs, Kubernetes, and OS internals** ← note for infra-track candidates.
- Experience with language modeling using transformer architectures.
- Knowledge of reinforcement learning techniques.
- Background in large-scale ETL processes.

### Sample projects (what you'd do on the job)
- Optimizing the throughput of novel attention mechanisms.
- Comparing compute efficiency of different Transformer variants.
- Preparing large-scale datasets for efficient model consumption.
- **Scaling distributed training jobs to thousands of GPUs.**
- Designing fault tolerance strategies for training infrastructure.
- Creating interactive visualizations of model internals, such as attention patterns.

### Notable signal — they encourage applying even without meeting every qualification
> "We encourage you to apply even if you do not believe you meet every single qualification. Not all strong candidates will meet every single qualification as listed."

This is sincere, not boilerplate. Research especially shows women and underrepresented candidates self-exclude prematurely. Anthropic states this explicitly in the job post.

### How Anthropic describes what makes them different
> "We believe that the highest-impact AI research will be big science. At Anthropic we work as a single cohesive team on just a few large-scale research efforts. And we value impact — advancing our long-term goals of steerable, trustworthy AI — rather than work on smaller and more specific puzzles. We view AI research as an empirical science, which has as much in common with physics and biology as with traditional efforts in computer science."

Read their published research to understand directions: prior work includes GPT-3, Circuit-Based Interpretability, Multimodal Neurons, Scaling Laws, AI & Compute, Concrete Problems in AI Safety, Learning from Human Preferences, and Constitutional AI.

---

## Interview process shape

Based on Sundeep Teki's account (coaching site, client who passed the loop in 2026):

1. **Recruiter screen** — non-trivial, not just standard questions.
2. **Hiring manager call** — have a strong narrative ready.
3. **Technical phone screen / coding assessment.**
4. **Take-home project** — 5-7 day window typically.
5. **Virtual onsite** — 4-5 hours in a single day, covering:
   - ML coding and debugging
   - Systems design (distributed training, inference infra, checkpointing, pipeline parallelism, memory-efficient training, serving at scale)
   - Research discussion
   - Paper discussion
   - Culture and values round
6. **Reference checks** — conducted DURING the process, not at the end. Unusual, reflects how seriously Anthropic treats cultural alignment.

Total elapsed time: **6-10 weeks** from application to offer.

Acceptance rate: **sub-1%** for Research Engineer roles, consistent with DeepMind and OpenAI figures.

---

## The four things Anthropic tests that most candidates don't prepare for

These are the dimensions coaching accounts surface that are NOT on the job listing:

### 1. Research intuition
Can you tell promising directions from dead ends?
- Probe: "If you were designing a follow-up experiment to this paper, what would you test and why?"
- Probe: "What would falsify the central hypothesis here?"
- They evaluate the quality of your reasoning process, not whether you produce the "correct" answer (often there isn't one).
- Failure mode: treating paper discussions as comprehension tests. They already read the paper.

### 2. Research taste
Do you know what problems actually matter?
- A candidate with taste has opinions: can articulate why mechanistic interpretability is more tractable near-term than ambitious theoretical formalisms, can explain why Constitutional AI is a specific theory of how to make LLMs safer AND what its limitations are.
- Has read beyond fashionable papers. Thinks on a 5-year horizon.
- They screen out people who recite Anthropic's research agenda back faster than people who disagree thoughtfully.

### 3. Communicating uncertainty (epistemic honesty)
Holds beliefs with appropriate strength given evidence. Updates on new info.
- Probe: explain a topic, then increasingly detailed follow-ups until you reach the edge of what you know.
- Wrong response: fill the gap with confident-sounding speculation.
- Right response: "I don't know the answer to that with confidence, but here is how I would reason about it."
- Note: academia often rewards overstatement (grant proposals, defenses, conference talks). Anthropic treats epistemic honesty as a signal of maturity, not weakness.

### 4. Intellectual humility under pressure
- Not adversarial; not trying to intimidate. They are checking whether you can distinguish "I was wrong and here is why" vs "I was right but communicated it poorly" and respond appropriately.
- First failure: caving immediately when your reasoning was sound.
- Second failure: holding stubbornly when they present a genuine counterargument.
- Right: engages with the substance, updates with explicit reasoning OR defends with new evidence.

---

## Coding screen — what it actually evaluates

**NOT LeetCode.** The coding screen for Research Engineers tests ML engineering fluency:
- NumPy and PyTorch implementations of fundamental building blocks: attention mechanisms, training loops, loss functions, optimizers.
- The "broken neural net" format: code with subtle bugs, diagnose and fix by reasoning about what the model SHOULD be doing — not pattern-matching common error types.
- Proficiency with data structures and algorithms is a WEAK signal at Anthropic.
- What matters: understanding why a neural network learns what it learns, reasoning about a training run from loss curves and gradient statistics, implementing a paper's core contribution in clean readable code under time pressure.

System design (where it appears): distributed training and inference infrastructure — checkpointing strategies, pipeline parallelism, memory-efficient training, serving at scale. Real engineering stakes, not toy design.

---

## Take-home project — what they evaluate

- Process as much as output.
- Strong submissions: make explicit the choices considered but not pursued, document tradeoffs, honest about limitations. Reads like the methods section of a well-written paper.
- Candidates who optimize for the most polished final result at the expense of process transparency consistently underperform.

---

## Paper discussion

- Uses a paper from Anthropic's own research output or closely adjacent field.
- Expected: understand experimental setup, key claims, ablation studies, what results actually show vs what authors claim.
- Discussion moves quickly beyond comprehension to evaluative questions:
  - "What would a replication study look like?"
  - "What is the most plausible alternative explanation for the key result?"
  - "What experiment would most efficiently distinguish between the authors' hypothesis and that alternative?"

---

## Six-month framework to build the profile

From the coaching account, what successful candidates do BEFORE the interview cycle (not 6 weeks before — 6 months before):

- **Months 1-2 — Research reading habit.** Read Anthropic's major papers in chronological order. Start with Constitutional AI (2022), move through Claude model family papers, mechanistic interpretability (Elhage, Nanda), recent RLHF and alignment research. Take notes not on what the papers say but on what they leave open: experiments not run, alternative interpretations, follow-on questions.
- **Months 2-3 — Implement from scratch.** Build a transformer in PyTorch without referring to existing implementations until genuinely stuck. Implement a basic RLHF pipeline (reward modelling, PPO, the full loop). Write a simple safety evaluation suite. Goal: hands-on fluency that makes the coding screen feel familiar rather than novel.
- **Months 3-4 — Research critique practice.** Write 3-5 short critiques (500-800 words each) of recent Anthropic or alignment-adjacent papers. Focus on what the paper does NOT prove, where the experimental design is weakest, what you would test next. This is the single most direct preparation for the paper discussion round. Most candidates skip it.
- **Months 4-5 — Practice communicating uncertainty.** Record yourself answering technical questions, flag every instance where you expressed more certainty than you have. Develop fluency with calibrated-uncertainty language: "My best understanding is...", "I am fairly confident about X but less certain about Y because...", "I would want to run an experiment to distinguish between these two explanations before committing to a view."
- **Months 5-6 — Public research artifact.** Contribute to an open-source ML project, publish a well-documented implementation of a recent paper, or write a substantive technical post. Artifact matters less than the process it demonstrates: translating research ideas into working code, communicating approach, engaging with feedback.

---

## How Claude was actually built (the lineage users should know)

Founders: Dario Amodei (CEO, led GPT-3 at OpenAI) and Daniela Amodei (President), with siblings/team. Founded 2021. Left OpenAI specifically because they believed AI development was outpacing safety considerations.

Claude is not the product of one person "programming" it. It's the product of:
1. **Pre-training** — feed terabytes of text to a transformer architecture with thousands of GPUs running in parallel for months. Model learns by predicting the next token billions of times.
2. **Constitutional AI** — Anthropic's distinctive training technique. Instead of only RLHF (humans rating responses), they give the model a "constitution" — principles of help, harmlessness, honesty — and have it self-evaluate and self-correct. This is what makes Claude distinct from GPT.
3. **Interpretability research** — Nelson Elhage, Neel Nanda and the team published work on "opening" the model and inspecting what individual neurons do (mechanistic interpretability).

This context matters because users often imagine Claude as a program someone wrote. It's the output of a research program. Getting a job there means contributing to the research program, not maintaining a codebase.

---

## Related roles at Anthropic (for non-research entries)

- **ML Infrastructure Engineer** — broader on credentials, rewards distributed-systems experience. Java/JVM candidates (Spark/Kafka/Flink) fit here. Look for "Safeguards Research", "Compute", "Data Science & Analytics" job families on the careers page.
- **Member of Technical Staff, Machine Learning Capabilities** (new grad track exists) — watch LinkedIn for these; they open periodically.
- **Data Science & Analytics** — lighter ML, more product-analytics leaning.

The careers page (anthropic.com/careers/jobs) categorizes openings as AI Research & Engineering / Applied AI / Communications / Compute / Data Science & Analytics / Engineering & Design - Product / Finance / Legal.
