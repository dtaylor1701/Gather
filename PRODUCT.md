I will read the `README.md` and `DESIGN.md` files to understand the core purpose and design of the `gather` tool.
# Product Strategy: gather

## 1. Product Vision & Core Objectives
**Vision:** To be the standard utility for generating "context-aware" documentation that empowers AI agents and developers to understand any codebase instantly.

### Core Objectives:
*   **Context Consolidation:** Transform fragmented documentation (READMEs, design docs, specs) into a single, structured "source of truth."
*   **Zero-Config Intelligence:** Automatically detect project types (Swift, Node.js, Xcode) and structure without requiring user setup.
*   **AI-Readiness:** Format output specifically for LLM ingestion, using conventions like `@import` or hierarchical header normalization.
*   **Workflow Integration:** Fit seamlessly into developer CLI workflows and CI/CD pipelines.

### The Problem:
Modern development increasingly relies on AI agents (like Gemini CLI, Cursor, or Copilot) that require project context to be effective. However, documentation is often scattered across multiple files, ignored by `.gitignore`, or structured in a way that loses hierarchy when concatenated. Manually maintaining a "master context" file is tedious, error-prone, and quickly becomes outdated.

---

## 2. Target Audience & User Personas
*   **The AI-First Developer:** Uses CLI agents daily and needs a quick way to "feed" the agent the latest project state before starting a task.
*   **The Open-Source Maintainer:** Wants to provide a clear, structured `AGENTS.md` for contributors who use AI tools to explore the codebase.
*   **The Tech Lead:** Needs to ensure that team documentation is consistent and that new hires (or agents) can bootstrap their understanding of a complex repository in seconds.

---

## 3. Feature Roadmap

### Short-Term (Current - 3 Months)
*   **Core Stability:** Finalize the header normalization logic and project detection for Swift/Node.js.
*   **Gemini Mode:** Full support for the `@import` syntax used by Gemini CLI.
*   **Basic Customization:** Allow users to pass custom file pairs (`path:name`) to the aggregator.
*   **Self-Documentation:** Ensure `gather` can reliably generate its own `AGENTS.md`.

### Medium-Term (3 - 9 Months)
*   **Ecosystem Expansion:** Add support for Python (Poetry/Pip), Go (modules), and Rust (Cargo) project detection.
*   **Ignore Patterns:** Implement a `.gatherignore` or respect `.gitignore` to prevent leaking sensitive or noisy data into the context.
*   **Template Support:** Allow users to define a custom Markdown template for the output file.
*   **Validation Suite:** Introduce unit and integration tests for all project detection logic.

### Long-Term (9+ Months)
*   **Live Context Mode:** A "watch" mode that updates the context file as documentation changes.
*   **Recursive Gathering:** Ability to "gather" documentation from sub-modules or monorepo packages.
*   **GitHub Action / Pre-commit Hook:** Official integrations to automate context generation on every PR or commit.

---

## 4. Feature Prioritization & Core Value
The core value of `gather` lies in **Automation and Normalization**.

1.  **High Priority (Core):** Header Adjustment. Without this, the merged file is a flat mess. This is the "killer feature" that makes the output readable.
2.  **High Priority (Core):** Auto-detection. The tool must feel "magical." If the user has to tell the tool it's a Swift project, we've failed the "zero-config" promise.
3.  **Medium Priority:** Multi-language support. While starting with Swift/Node, expansion is necessary for market fit.
4.  **Lower Priority:** UI/UX fluff. As a CLI tool, performance and reliability trump visual aesthetics.

---

## 5. Iteration Strategy
Our development is driven by **Dogfooding** and **AI Feedback Loops**.
*   **Dogfooding:** We use `gather` on itself. If the generated `GEMINI.md` doesn't help an AI agent fix a bug in `gather`, the tool needs improvement.
*   **User Feedback:** We monitor how AI agents react to the generated files. If agents get "confused" by certain structures, we adjust the formatting logic.
*   **Experimentation:** We test different "context styles" (inlined vs. referenced) to see which yields better LLM performance.

---

## 6. Release Strategy & Onboarding
*   **Distribution:** Primarily via Homebrew and direct Swift Package downloads.
*   **Onboarding Goal:** A user should be able to run `gather` in a new repo and get a perfect `AGENTS.md` in under 2 seconds with zero arguments.
*   **Documentation:** The `README.md` serves as the primary onboarding guide, supplemented by the tool's own `--help` output.

---

## 7. Success Metrics (KPIs)
*   **Time-to-Context:** The time it takes for a user to generate a valid context file (Target: < 5 seconds).
*   **Agent Success Rate:** (Qualitative) Do users report that their AI agents are more effective after running `gather`?
*   **Adoption:** Number of repositories containing a `gather`-generated `AGENTS.md` or `GEMINI.md`.
*   **Zero-Config Accuracy:** Percentage of projects where `gather` correctly identifies the ecosystem without manual flags.

---

## 8. Future Opportunities
*   **Contextual Snippets:** Beyond just documentation, `gather` could include "key code snippets" (e.g., main entry points, API routes) to provide even deeper technical context.
*   **Plugin System:** Allow third-party developers to write "analyzers" for niche frameworks or proprietary internal tools.
*   **IDE Integration:** A VS Code or Xcode extension that runs `gather` in the background to keep the agent context fresh.
