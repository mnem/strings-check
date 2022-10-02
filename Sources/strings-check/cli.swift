import ArgumentParser
import Path

@main
struct StringsCheck: AsyncParsableCommand {
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
        
        print(OutputFormatter.results(base: base, results: results))
    }
    
    enum OutputFormatter {
        static func results(base: StringsFileSource, results: [Comparatron.StringsComparisonResult]) -> String {
            var output = [String]()
            output.append(header(base: base))
            
            for result in results {
                output.append(header(result: result))
                if result.isExactStringsMatch {
                    output.append(identical())
                } else {
                    if result.missingKeys.isNotEmpty {
                        output.append(different(keys: result.missingKeys, indent: "    - "))
                    }
                    if result.extraKeys.isNotEmpty {
                        output.append(different(keys: result.extraKeys, indent: "    + "))
                    }
                }
            }
            
            return output.joined(separator: "\n")
        }
        
        static func header(base: StringsFileSource) -> String {
            "Base file: \(base.name)"
        }
        
        static func header(result: Comparatron.StringsComparisonResult) -> String {
            "  \(result.name):"
        }
        
        static func identical() -> String {
            "    Identical"
        }
        
        static func different(keys: [String], indent: String) -> String {
            let keySeparator = "\n\(indent)"
            return "\(indent)\(keys.sorted().joined(separator: keySeparator))"
        }
    }
}

extension String {
    fileprivate var path: Path {
        Path(self) ?? Path.cwd/self
    }
}

extension Array {
    fileprivate var isNotEmpty: Bool {
        !self.isEmpty
    }
}
