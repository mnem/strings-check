import Foundation

struct Comparatron {
    struct StringsComparisonResult {
        let name: String
        let missingKeys: [String]
        let extraKeys: [String]

        var isExactStringsMatch: Bool {
            missingKeys.isEmpty && extraKeys.isEmpty
        }
    }

    let base: StringsFileSource
    let others: [StringsFileSource]

    func compare() -> [StringsComparisonResult] {
        var results = [StringsComparisonResult]()
        for other in others {
            let missing = base.keys.subtracting(other.keys)
            let extra = other.keys.subtracting(base.keys)
            let result = StringsComparisonResult(
                name: other.name,
                missingKeys: Array(missing),
                extraKeys: Array(extra)
            )
            results.append(result)
        }
        return results
    }
}

extension Array where Element == Comparatron.StringsComparisonResult {
    var isExactStringsMatch: Bool {
        for result in self {
            guard result.isExactStringsMatch else {
                return false
            }
        }

        return true
    }
}
