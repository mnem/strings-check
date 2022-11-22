import Foundation
import Path

final class PathStringsFileSource {
    let source: Path
    let keys: Set<String>

    convenience init(source: Path) async throws {
        let file = try FileHandle(forReadingAt: source)
        var keys = Set<String>()
        for try await line in file.bytes.lines {
            guard let key = Parser.key(from: line) else {
                continue
            }
            keys.insert(key)
        }

        self.init(source: source, keys: keys)
    }

    init(source: Path, keys: Set<String>) {
        self.source = source
        self.keys = keys
    }

    private static func parse(line: String) -> String? {
        line
    }
}

extension PathStringsFileSource: StringsFileSource {
    var name: String {
        source.string
    }
}
