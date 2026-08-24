---
name: rust-review
description: "Review a Rust crate: gate, choke points, safety, tests, CI."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Rust, CodeReview, Architecture, CI, Safety, Cargo, Clippy]
---

# /rust-review

Review a Rust crate beyond "does it compile". Run the full gate, then read the
architecture for the things that distinguish a serious Rust project from a toy:
choke points, safety-by-construction, test coverage honest enough for the
project's claims, and release/CI readiness.

## When to use

- User says "analiza X", "revisa este crate", "audit this Rust project".
- User hands you a Rust repo path and wants a real assessment, not a `cargo build` y/n.
- A Rust project claims "safety" or "safe by design" in its README — verify it in the code.

Do NOT use for: writing Rust from scratch (devforge), debugging a specific Rust
bug (systematic-debugging), or choosing a Rust crate version (devforge versions).

## The gate — run before reading the code

Four commands, in order. All four must pass before the review is meaningful:

```bash
cargo build                                # does it compile at all
cargo clippy --all-targets -- -D warnings  # warnings = failures (serious-project gate)
cargo test --verbose                       # how many tests, do they pass
cargo fmt --all -- --check                 # style consistent
```

Record the real output. If clippy emits warnings under `-D warnings`, the CI
gate is broken — that's a finding, not a nit. If `cargo test` shows 4 tests for
a 6K-LOC crate that markets "safety", that's a coverage gap worth stating.

## The structured read — what to look for

After the gate is green, read the code for the following. Not all apply to every
crate; skip what doesn't, but look at each.

### 1. Choke points (single-responsibility seams)

A serious crate has a small number of places where a concern is centralized, so
it can change in one file later. The classic ones in a Rust CLI/tool:

- **Adapter layer** — the only module that shells out to an external binary
  (docker, git, a REST client). If `Command::new` appears outside that one
  file, the boundary is leaking.
- **Execute/apply choke point** — every mutating operation routes through one
  function. If deletes/updates are scattered, there's no single place to hook
  an audit log or a permission check.
- **Assess-vs-act separation** — risk/permission checks live in a module that
  *cannot* perform I/O writes. Safety logic that also writes is a testability
  and reviewability hazard.

If you can't identify these in 10 minutes of reading, the codebase doesn't have
them yet — that's a finding, not necessarily a bug.

### 2. Safety by construction (not by convention)

For crates whose value prop is "safe operations" (file managers, docker
wrappers, anything that deletes), check whether safety is enforced by the
type/module system or by "remembering to call the check":

- Can a caller bypass the safety check by importing the wrong function?
  (`pub(super)` / `pub(crate)` matters here.)
- Does the classify/scan module refuse to perform the destructive action it
  flags? (e.g. a cleanup scanner that only classifies, deletion routed through
  a separate `operations` module.)
- Are cancel tokens real (`Arc<AtomicBool>`) or string-flag heuristics?
- For filesystem ops: cross-device detection via `stat().dev()` (Unix) /
  `EXDEV` errno handling, not "different drive letter" string matching.

State what you find as "safety is enforced by X", not "safety looks good".

### 3. Test coverage honest to the project's claims

A crate that sells "safety" needs tests on the safety-critical paths, not just
the happy-path helpers. Check concretely:

- Which modules have `#[cfg(test)]`? Which safety-critical ones don't?
- Are there integration tests (`tests/` dir) or only unit tests inline?
- For a file/docker tool: are `operations::plan_*` / `plan_delete` tested
  against a `tempdir`? If not, the "safe delete" claim rests on untested code.
- Risk-tier classification logic (Safe/Review/Dangerous/Protected) is pure
  pattern matching — if it's untested, that's an easy win to call out.

### 4. Git + CI + release readiness

The code can be perfect and still undeliverable:

- Is there a commit on the default branch? A fresh repo with no commits but a
  `.github/workflows/release.yml` that triggers on `v*` tags is dead on arrival.
- Does the branch name in CI (`main`) match the actual default branch
  (`master`)? This silently breaks the release pipeline.
- Are clippy + fmt actual CI gates (`-D warnings`) or just informational?
- Cross-compile targets in the release matrix: does it cover the platforms the
  README claims (aarch64, macOS, Windows)?

### 5. Honest limitations

A good Rust crate states what it doesn't do yet, in comments or a ROADMAP.
When reading, note: platform-conditional code (`#[cfg(target_os = ...)]`) that
silently falls back to `false` on non-Linux. A `doctor` check with a 2M-file
cap that breaks without telling the user. A label parser that splits on `,`
and acknowledges in a comment that compose paths can contain commas. These are
not bugs — they're documented trade-offs. Cite them as such in the review.

## Writing the review

Structure the output so the user can act on it:

1. **Verdict first** — one line: professional quality / usable / needs work.
2. **Gate results** — the four commands and what they returned.
3. **Architecture strengths** — cite file:line for each, not adjectives.
4. **Real weaknesses** — ordered by priority, each with a concrete fix.
5. **No-issues you checked** — the things you verified and found correct,
   so the user knows you actually looked (cancel handles, `Box::leak` guard,
   `#[allow]` rationale, etc.).
6. **Roadmap state** — if the repo has a ROADMAP.md, map phases to "done /
   pending" based on the code you read, not what the file claims.

Cite paths as `src/module/file.rs:line`. Never paste whole files — point.

## Pitfalls

- **Don't stop at "compiles, clippy clean".** That's the gate, not the review.
  A crate with 4 unit tests and no integration tests passes both and still has
  a real coverage problem.
- **Don't report documented trade-offs as bugs.** If a comment explicitly
  says "we split on commas, compose paths can contain commas in edge cases"
  and the scope is correct, that's an accepted limitation — call it out as
  one, not as a defect.
- **Don't confuse `master` vs `main` cosmetic difference with a real branch
  mismatch.** Check `git branch -a` and the CI `on:` block together.
- **Don't invent access or runtime behavior.** If you didn't run `cargo run`
  interactively, don't claim the TUI flashes or the spinner animates — say
  the loop structure supports it, not that you saw it.

## References

| File | Content |
|---|---|
| `references/rust-review-checklist.md` | One-page checklist version of the 5-point structured read, for fast re-use. |
