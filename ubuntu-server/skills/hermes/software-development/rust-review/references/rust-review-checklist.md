# Rust review checklist

One-page distilled version of the `/rust-review` skill. Run the gate, then walk
the 5 points. Skip points that don't apply to the crate, but look at each.

## Gate (run before reading code)

```bash
cargo build                                # compiles
cargo clippy --all-targets -- -D warnings  # warnings = failures
cargo test --verbose                       # count + pass/fail
cargo fmt --all -- --check                 # style
```

Record real output. clippy warnings under `-D warnings` = broken CI gate. Few
tests for a "safety"-marketed crate = coverage gap finding.

## 5-point structured read

### 1. Choke points
- [ ] Single adapter layer for external binary shell-out? `Command::new`
      outside it = boundary leak.
- [ ] Single `execute`/`apply` function every mutation routes through?
      Scattered deletes = no audit-hook point.
- [ ] Assess-vs-act split? Risk checks in a module that *cannot* write =
      testable safety. Safety logic that also writes = hazard.

### 2. Safety by construction
- [ ] Can a caller bypass safety by importing the wrong function? Check
      `pub(super)` / `pub(crate)` visibility.
- [ ] Does the classify/scan module refuse to perform the action it flags?
      (cleanup scanner that only classifies, deletion via `operations`.)
- [ ] Cancel tokens real (`Arc<AtomicBool>`) or string heuristics?
- [ ] Cross-device detection: `stat().dev()` / `EXDEV` errno, not drive-letter
      string matching?

### 3. Test coverage honest to claims
- [ ] Which modules have `#[cfg(test)]`? Which safety-critical ones don't?
- [ ] Integration tests (`tests/`) or only inline unit tests?
- [ ] `operations::plan_*` / `plan_delete` tested against `tempdir`?
- [ ] Risk-tier classification (pure pattern matching) tested? Easy win.

### 4. Git + CI + release readiness
- [ ] Commit exists on default branch? No commits + a `v*`-triggered
      `release.yml` = dead on arrival.
- [ ] CI `on:` branch name matches actual default branch (`main` vs `master`)?
- [ ] clippy + fmt are real gates (`-D warnings`) or informational?
- [ ] Release matrix covers platforms the README claims (aarch64/macOS/Windows)?

### 5. Honest limitations
- [ ] `#[cfg(target_os = ...)]` that silently falls back to `false` elsewhere?
- [ ] Caps/limits that break silently (2M-file doctor cap, 5K-candidate cap)?
- [ ] Parsers that acknowledge edge cases in comments (label split on `,`)?
    Documented trade-off ≠ bug. Cite as limitation, not defect.

## Output shape

1. Verdict (one line)
2. Gate results (the four commands + output)
3. Architecture strengths (cite `src/path.rs:line`)
4. Real weaknesses (priority order, each with a concrete fix)
5. No-issues you checked (so the user knows you looked)
6. Roadmap state (done/pending from code, not from ROADMAP.md claims)

Cite `path:line`. Never paste whole files.
