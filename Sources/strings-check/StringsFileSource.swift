import Foundation

protocol StringsFileSource {
    var name: String { get }
    var keys: Set<String> { get }
}
