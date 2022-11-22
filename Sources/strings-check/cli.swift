import ArgumentParser
import Path

@main
struct StringsCheck: AsyncParsableCommand {
    enum OutputMode: String, CaseIterable, ExpressibleByArgument {
        case human, json

        fileprivate static var help: String {
            Self.allCases.map { $0.rawValue } .lazy.joined(separator: "|")
        }
    }

    static let configuration = CommandConfiguration(
        abstract: """
            Lists missing strings keys.
            
            One or more .strings files can be compared against a
            base .strings file to find keys that exist in the base
            file but not in the other strings files.
            """
    )

    @Flag(name: .shortAndLong)
    private(set) var verbose = false
    
    @Option(name: [.short, .customLong("base")], help: "The base .strings file the others are compared against.")
    private(set) var baseStringsFilename: String
    
    @Argument(help: "The other .strings files to compare against the base.")
    private(set) var otherStringsFilename: [String]

    @Option(name: .shortAndLong, help: "How to output the findings. [\(OutputMode.help)]")
    private(set) var output: OutputMode = .human

    func validate() throws {
        guard baseStringsFilename.path.exists else {
            throw ValidationError("Base strings file does not exist: \(baseStringsFilename.path)")
        }

        for otherFilename in otherStringsFilename {
            guard otherFilename.path.exists else {
                throw ValidationError("Strings file does not exist: \(otherFilename.path)")
            }
        }
    }

    mutating func run() async throws {
        let base = try await PathStringsFileSource(source: baseStringsFilename.path)
        var others = [StringsFileSource]()
        for other in otherStringsFilename {
            others.append(try await PathStringsFileSource(source: other.path))
        }

        let comparatron = Comparatron(base: base, others: others)
        let results = comparatron.compare().sorted { $0.name < $1.name }

        print(try OutputFormatter(output, base: base, results: results).output)
    }
}

extension String {
    fileprivate var path: Path {
        Path(self) ?? Path.cwd/self
    }
}

extension OutputFormatter {
    fileprivate init(
        _ outputMode: StringsCheck.OutputMode,
        base: StringsFileSource,
        results: [Comparatron.StringsComparisonResult]
    ) {
        switch outputMode {
        case .human:
            self = .human(base: base, results: results)
        case .json:
            self = .robot(base: base, results: results)
        }
    }
}
