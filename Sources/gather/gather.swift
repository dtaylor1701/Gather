import ArgumentParser
import Foundation

@main
struct Gather: ParsableCommand {
    @Option(name: .shortAndLong, help: "The output file path.")
    var output: String?

    @Argument(help: "Input file and section name pairs in 'path:name' format.")
    var inputPairs: [String] = []

    @Option(name: .shortAndLong, help: "The root directory to analyze for context.")
    var root: String = "."

    @Flag(
        name: .customLong("gemini"),
        help: "Generate a GEMINI.md file with imports instead of inline content.")
    var useGeminiImports: Bool = false

    func run() throws {
        let finalOutput = output ?? (useGeminiImports ? "GEMINI.md" : "AGENTS.md")
        var content = "# Workspace Context\n\n"

        // 1. Context Analysis (Directly in the file)
        content += analyzeContext(at: root)

        // 2. Prepare Inputs (Defaults + Provided)
        var allInputs = inputPairs
        let fm = FileManager.default
        let rootURL = URL(fileURLWithPath: root)

        let defaults = [
            "README.md": "Overview",
            "Design.md": "Design",
            "Product.md": "Product",
        ]

        for (file, section) in defaults {
            let filePath = rootURL.appendingPathComponent(file).path
            if fm.fileExists(atPath: filePath) {
                let pair = "\(file):\(section)"
                if !allInputs.contains(where: { $0.hasPrefix("\(file):") }) {
                    allInputs.insert(pair, at: 0)
                }
            }
        }

        // 3. Process Inputs
        for inputPair in allInputs {
            let parts = inputPair.split(separator: ":", maxSplits: 1).map(String.init)
            guard parts.count == 2 else {
                print("Warning: Invalid input format '\(inputPair)'. Expected 'path:name'.")
                continue
            }
            let path = parts[0]
            let name = parts[1]

            content += "## \(name)\n\n"

            if useGeminiImports {
                content += "@./\(path)\n\n"
            } else {
                let fileURL = URL(fileURLWithPath: path)
                do {
                    let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
                    let adjustedContent = adjustHeaderLevels(in: fileContent, by: 2)
                    content += adjustedContent + "\n\n"
                } catch {
                    print("Warning: Could not read file at '\(path)': \(error)")
                }
            }
        }

        // 4. Write Output
        let outputURL = URL(fileURLWithPath: finalOutput)
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        print("Generated context at \(finalOutput)")
    }

    private func adjustHeaderLevels(in content: String, by levels: Int) -> String {
        let prefix = String(repeating: "#", count: levels)
        let lines = content.components(separatedBy: .newlines)
        let adjustedLines = lines.map { line -> String in
            if line.range(of: "^#+ ", options: .regularExpression) != nil {
                return prefix + line
            }
            return line
        }
        return adjustedLines.joined(separator: "\n")
    }

    private func analyzeContext(at path: String) -> String {
        let fm = FileManager.default
        let rootURL = URL(fileURLWithPath: path)
        var contextInfo = "## Project Context\n\n"

        let contents = (try? fm.contentsOfDirectory(atPath: path)) ?? []

        var projectType = "Generic"
        var targets: [String] = []

        if fm.fileExists(atPath: rootURL.appendingPathComponent("Package.swift").path) {
            projectType = "Swift Package"
            if let packageContent = try? String(
                contentsOf: rootURL.appendingPathComponent("Package.swift"), encoding: .utf8)
            {
                let patterns = [
                    #"(\.target|\.executableTarget|\.testTarget)\s*\(\s*name\s*:\s*"([^"]+)"#,
                    #"name\s*:\s*"([^"]+)"\s*,\s*targets\s*:\s*\["#,
                ]

                for pattern in patterns {
                    let regex = try? NSRegularExpression(pattern: pattern, options: [])
                    let nsRange = NSRange(
                        packageContent.startIndex..<packageContent.endIndex, in: packageContent)
                    regex?.enumerateMatches(in: packageContent, options: [], range: nsRange) {
                        match, _, _ in
                        if let match = match,
                            let range = Range(
                                match.range(at: match.numberOfRanges - 1), in: packageContent)
                        {
                            let name = String(packageContent[range])
                            if !targets.contains(name) { targets.append(name) }
                        }
                    }
                }
            }
        } else if contents.contains(where: {
            $0.hasSuffix(".xcodeproj") || $0.hasSuffix(".xcworkspace")
        }) {
            projectType = "iOS/macOS Project (Xcode)"
        } else if fm.fileExists(atPath: rootURL.appendingPathComponent("package.json").path) {
            projectType = "Web Project (Node.js)"
        }

        contextInfo += "- **Type**: \(projectType)\n"
        contextInfo += "- **Root**: \(fm.currentDirectoryPath)\n"
        if !targets.isEmpty {
            contextInfo += "- **Targets/Products**: \(targets.joined(separator: ", "))\n"
        }

        let ignoredFolders = [
            ".git", ".build", ".swiftpm", "node_modules", ".xcodeproj", ".xcworkspace",
        ]
        let topDirs = contents.filter { item in
            var isDir: ObjCBool = false
            return fm.fileExists(
                atPath: rootURL.appendingPathComponent(item).path, isDirectory: &isDir)
                && isDir.boolValue && !ignoredFolders.contains(where: { item.hasSuffix($0) })
        }

        if !topDirs.isEmpty {
            contextInfo += "- **Top-level Directories**: \(topDirs.joined(separator: ", "))\n"
        }
        contextInfo += "\n"
        return contextInfo
    }
}
