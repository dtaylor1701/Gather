I will read the project's source code and configuration to understand its purpose and dependencies before generating the README.
# gather

`gather` is a command-line tool written in Swift designed to automatically generate a comprehensive workspace context file. It analyzes your project structure and aggregates key documentation into a single, structured Markdown file (typically `AGENTS.md` or `GEMINI.md`), making it easier for AI agents or developers to quickly understand the project's layout, purpose, and design.

## Purpose

The primary goal of `gather` is to bridge the gap between fragmented project documentation and the need for a unified "source of truth" context. It handles:
- **Project Auto-Detection**: Identifies if the project is a Swift Package, an Xcode project, or a Node.js web project.
- **Structural Analysis**: Lists targets, products, and top-level directories while ignoring noise (like `.git`, `.build`, or `node_modules`).
- **Content Aggregation**: Automatically pulls in standard files like `README.md`, `Design.md`, and `Product.md` if they exist.
- **Header Normalization**: Automatically adjusts Markdown header levels of imported files to ensure the generated context file remains hierarchical and readable.

## Usage

Run `gather` from the root of your project:

```bash
swift run gather [OPTIONS] [INPUT_PAIRS]...
```

### Arguments

*   `<input-pairs>`: Optional list of input file and section name pairs in `path:name` format (e.g., `docs/API.md:API`).

### Options

*   `-o, --output <output>`: Specify a custom output file path. Defaults to `AGENTS.md` (or `GEMINI.md` if using the `--gemini` flag).
*   `-r, --root <root>`: The root directory to analyze for context. Defaults to the current directory (`.`).
*   `--gemini`: Generate a `GEMINI.md` file using `@import("path")` syntax instead of inlining the file content.

### Examples

**Default behavior (Inlines content into AGENTS.md):**
```bash
swift run gather
```

**Generate a Gemini CLI compatible context file:**
```bash
swift run gather --gemini
```

**Include specific extra files:**
```bash
swift run gather Documentation/Architecture.md:Architecture docs/Setup.md:Setup
```

## Installation

### Requirements
- macOS 13.0 or later
- Swift 5.10 or later

### Building from Source
1. Clone the repository.
2. Build the executable:
   ```bash
   swift build -c release
   ```
3. (Optional) Install the binary to your path:
   ```bash
   cp .build/release/gather /usr/local/bin/gather
   ```

## Dependencies

`gather` relies on the following official Apple library:
- [swift-argument-parser](https://github.com/apple/swift-argument-parser): Provides the robust command-line interface and argument handling.

## Components

- **Gather (@main)**: The entry point and command definition using `ArgumentParser`.
- **Context Analysis**: Logic to detect project types (Swift, Xcode, Node.js) and map the directory structure.
- **Header Adjuster**: Utility to shift Markdown header levels (`#` -> `###`) to maintain document hierarchy when merging files.
