//
//  ComparatronTests.swift
//  
//
//  Created by David Wagner on 02/10/2022.
//

import XCTest
@testable import strings_check

final class ComparatronTests: XCTestCase {
    func testExactMatches() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "b", "c"]))
        let otherB = MockStringsFileSource(keys: Set(["a", "b", "c"]))
        let sut = Comparatron(base: base, others: [otherA, otherB])
        let results = sut.compare()
        
        XCTAssertTrue(results.isExactStringsMatch)
    }
    
    func testMissingStringsInOne() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "b"]))
        let otherB = MockStringsFileSource(keys: Set(["a", "b", "c"]))
        let sut = Comparatron(base: base, others: [otherA, otherB])
        let results = sut.compare()
        
        XCTAssertFalse(results.isExactStringsMatch)
        XCTAssertTrue( try XCTUnwrap(results[otherB.name]).isExactStringsMatch)
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.extraKeys.count, 0)
        XCTAssertEqual(resulA.missingKeys.sorted(), ["c"])
    }
    
    func testMissingStringsInBoth() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "b"]))
        let otherB = MockStringsFileSource(keys: Set(["a", "c"]))
        let sut = Comparatron(base: base, others: [otherA, otherB])
        let results = sut.compare()
        
        XCTAssertFalse(results.isExactStringsMatch)
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.extraKeys.count, 0)
        XCTAssertEqual(resulA.missingKeys.sorted(), ["c"])
        
        let resultB = try XCTUnwrap(results[otherB.name])
        XCTAssertFalse(resultB.isExactStringsMatch)
        XCTAssertEqual(resultB.extraKeys.count, 0)
        XCTAssertEqual(resultB.missingKeys.sorted(), ["b"])
    }
    
    func testExtraStringsInOne() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "b", "c", "d"]))
        let otherB = MockStringsFileSource(keys: Set(["a", "b", "c"]))
        let sut = Comparatron(base: base, others: [otherA, otherB])
        let results = sut.compare()
        
        XCTAssertFalse(results.isExactStringsMatch)
        XCTAssertTrue( try XCTUnwrap(results[otherB.name]).isExactStringsMatch)
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.missingKeys.count, 0)
        XCTAssertEqual(resulA.extraKeys.sorted(), ["d"])
    }
    
    func testExtraStringsInBoth() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "b", "c", "d"]))
        let otherB = MockStringsFileSource(keys: Set(["a", "b", "c", "e"]))
        let sut = Comparatron(base: base, others: [otherA, otherB])
        let results = sut.compare()
        
        XCTAssertFalse(results.isExactStringsMatch)
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.missingKeys.count, 0)
        XCTAssertEqual(resulA.extraKeys.sorted(), ["d"])
        
        let resultB = try XCTUnwrap(results[otherB.name])
        XCTAssertFalse(resultB.isExactStringsMatch)
        XCTAssertEqual(resultB.missingKeys.count, 0)
        XCTAssertEqual(resultB.extraKeys.sorted(), ["e"])
    }

    func testExtraAndMissingStringsInOne() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "c", "d"]))
        let otherB = MockStringsFileSource(keys: Set(["a", "b", "c"]))
        let sut = Comparatron(base: base, others: [otherA, otherB])
        let results = sut.compare()

        XCTAssertFalse(results.isExactStringsMatch)
        XCTAssertTrue( try XCTUnwrap(results[otherB.name]).isExactStringsMatch)
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.missingKeys.sorted(), ["b"])
        XCTAssertEqual(resulA.extraKeys.sorted(), ["d"])
    }

    
    func testExtraAndMissingStringsInBoth() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "c", "d"]))
        let otherB = MockStringsFileSource(keys: Set(["a", "b", "e"]))
        let sut = Comparatron(base: base, others: [otherA, otherB])
        let results = sut.compare()
        
        XCTAssertFalse(results.isExactStringsMatch)
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.missingKeys.sorted(), ["b"])
        XCTAssertEqual(resulA.extraKeys.sorted(), ["d"])
        
        let resultB = try XCTUnwrap(results[otherB.name])
        XCTAssertFalse(resultB.isExactStringsMatch)
        XCTAssertEqual(resultB.missingKeys.sorted(), ["c"])
        XCTAssertEqual(resultB.extraKeys.sorted(), ["e"])
    }

    func testMultipleMissingStrings() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set([]))
        let sut = Comparatron(base: base, others: [otherA])
        let results = sut.compare()
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.extraKeys.count, 0)
        XCTAssertEqual(resulA.missingKeys.sorted(), ["a", "b", "c"])
    }

    func testMultipleExtraStrings() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["a", "b", "c", "d", "e", "f"]))
        let sut = Comparatron(base: base, others: [otherA])
        let results = sut.compare()
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.extraKeys.sorted(), ["d", "e", "f"])
        XCTAssertEqual(resulA.missingKeys.count, 0)
    }

    func testMultipleMissingAndExtraStrings() throws {
        let base = MockStringsFileSource(name: "source, ", keys: Set(["a", "b", "c"]))
        let otherA = MockStringsFileSource(keys: Set(["d", "e", "f"]))
        let sut = Comparatron(base: base, others: [otherA])
        let results = sut.compare()
        
        let resulA = try XCTUnwrap(results[otherA.name])
        XCTAssertFalse(resulA.isExactStringsMatch)
        XCTAssertEqual(resulA.extraKeys.sorted(), ["d", "e", "f"])
        XCTAssertEqual(resulA.missingKeys.sorted(), ["a", "b", "c"])
    }
}

extension Array where Element == Comparatron.StringsComparisonResult {
    fileprivate subscript(name: String) -> Element? {
        self.first { $0.name == name }
    }
}
