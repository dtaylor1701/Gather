# System Design: gather

## 1. High-Level Architecture & Technical Stack

`gather` is a monolithic command-line interface (CLI) tool written in Swift. Its primary function is to analyze a local project directory and aggregate documentation and context into a single, unified Markdown file (typically `AGENTS.md` or `GEMINI.md`).

**Technical Stack:**
*   **Language:** Swift 5.10+
*   **Platform:** macOS 13.0+
*   **Build System:** Swift Package Manager (SPM)
*   **Core Dependencies:** `swift-argument-parser` (v1.3.0+) for robust CLI routing, argument parsing, and help generation.
*   **Frameworks:** `Foundation` (for `FileManager`, `URL`, `NSRegularExpression`, and String manipulation).

## 2. Core Design Philosophies & Principles

*   **Zero Configuration / Convention over Configuration:** The tool is designed to work out of the box. It automatically detects project types and looks for standard documentation files (`README.md`, `Design.md`, `Product.md`) without requiring explicit configuration files.
*   **Procedural Pipeline:** The core execution follows a strictly linear, predictable pipeline: 
    1. Parse Arguments 
    2. Analyze Project Context 
    3. Resolve Input Files 
    4. Process/Format Content 
    5. Write Output.
*   **Non-Destructive Aggregation:** It reads from the workspace and generates a new artifact. It does not modify existing source files.
*   **Structural Integrity:** When inlining multiple Markdown files, the tool automatically adjusts header levels to maintain a cohesive document hierarchy in the final output.

## 3. Technical Environment & Tooling

*   **Setup & Build:** Managed entirely via `Package.swift`. Building is executed via `swift build -c release`.
*   **Execution:** Run via `swift run gather` or as a compiled binary.
*   **Dependency Management:** SPM handles the fetching and linking of `swift-argument-parser`.

## 4. Data Models & Persistence

*   **Persistence Strategy:** `gather` is entirely stateless between runs. There is no database or caching layer. The final output is written to a local Markdown file.
*   **Data Models:** Internal models are primitive. 
    *   Command-line arguments are mapped to Swift properties (`String`, `[String]`, `Bool`).
    *   File references are handled via `URL` and `String` paths.
    *   Content is manipulated in-memory as `String` data.

## 5. Key Components & Interactions

The application logic is encapsulated within a single `@main` executable struct: `Gather: ParsableCommand`.

*   **CLI Router (`run()`):** The main orchestrator. It merges user-provided inputs with default conventions, iterates over the requested files, and coordinates the file writing.
*   **Context Analyzer (`analyzeContext(at:)`):** 
    *   Scans the target directory using `FileManager`.
    *   Detects the project ecosystem (Swift Package, Xcode project, Node.js web project) based on the presence of key files (`Package.swift`, `*.xcodeproj`, `package.json`).
    *   Uses Regular Expressions (`NSRegularExpression`) to parse `Package.swift` and extract declared targets and products.
    *   Filters out noise directories (e.g., `.git`, `node_modules`, `.build`).
*   **Markdown Formatter (`adjustHeaderLevels(in:by:)`):** A text processing utility that scans lines for Markdown headers (`#`) and prepends additional `#` characters. This ensures imported files (which might start with `# Title`) nest properly under the generated section headers (e.g., `## Section Name`).
*   **Output Generator:** Depending on the `--gemini` flag, it either strictly outputs `@import("path")` directives or physically reads the file contents, adjusts headers, and concatenates them into the final output string before writing atomically to disk.

## 6. Technical Specifications

*   **Concurrency Model:** The tool executes synchronously on the main thread. Given the typical size of project documentation and local file I/O speeds, asynchronous processing is not currently required.
*   **Error Handling:** 
    *   Fails gracefully on missing files: If a specified file cannot be read, it prints a warning to the console (`stderr`) and continues processing the remaining files.
    *   Uses `try?` for non-critical reads (e.g., attempting to read directory contents or parse a package file for context).
    *   Throws on critical failures (e.g., unable to write the final output file).
*   **State Management:** State is ephemeral and localized to the `run()` method's execution context.

## 7. Testing Infrastructure

*   *Current State:* The project currently lacks a dedicated testing target or infrastructure (no `Tests` directory or `.testTarget` in `Package.swift`).
*   *Future Strategy:* 
    *   **Unit Tests:** Should be implemented to test the `adjustHeaderLevels` string manipulation logic and the Regex-based `Package.swift` parsing in `analyzeContext`.
    *   **Integration Tests:** Should verify the CLI behavior against mock directory structures (fixtures) to ensure correct file aggregation and output generation without side effects.

## 8. Security, Scalability, & Performance

*   **Security:** 
    *   The tool runs with the user's current local permissions.
    *   Input parsing is rudimentary; while it splits `path:name`, it assumes local, trusted execution. If extended to run in automated environments based on untrusted input, path traversal vulnerabilities would need to be mitigated.
*   **Scalability & Performance:**
    *   File contents are loaded entirely into memory as Strings. For massive files (hundreds of megabytes), this could cause memory pressure, but for standard project documentation (READMEs, Design docs), this approach is highly performant and trivial to manage.
    *   Regular expressions used for parsing Swift packages are localized and applied only to a single file, ensuring fast execution.
