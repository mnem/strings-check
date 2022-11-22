import Foundation

enum OutputFormatter {
    case human(base: StringsFileSource, results: [Comparatron.StringsComparisonResult])
    case robot(base: StringsFileSource, results: [Comparatron.StringsComparisonResult])

    var output: String {
        get throws {
            switch self {
            case let .human(base, results):
                return try Human.results(base: base, results: results)
            case let .robot(base, results):
                return try Robot.results(base: base, results: results)
            }
        }
    }
}

extension OutputFormatter {
    private enum Human {
        static func results(base: StringsFileSource, results: [Comparatron.StringsComparisonResult]) throws -> String {
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

extension OutputFormatter {
    private enum Robot {
        private struct Output: Encodable {
            var baseFile: String
            var results: [Result]

            struct Result: Encodable {
                var filename: String
                var keysDiff: KeysDiff

                struct KeysDiff: Encodable {
                    var missing: [String]
                    var extra: [String]
                }

                init(comparisonResult: Comparatron.StringsComparisonResult) {
                    self.filename = comparisonResult.name
                    self.keysDiff = .init(
                        missing: comparisonResult.missingKeys,
                        extra: comparisonResult.extraKeys
                    )
                }
            }
        }

        static func results(base: StringsFileSource, results: [Comparatron.StringsComparisonResult]) throws  -> String {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase

            let output = Output(
                baseFile: base.name,
                results: results.map(Output.Result.init)
            )

            return String(decoding: try encoder.encode(output), as: UTF8.self)
        }
    }
}
