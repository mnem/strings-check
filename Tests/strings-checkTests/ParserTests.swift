//
//  ParserTests.swift
//  
//
//  Created by David Wagner on 02/10/2022.
//

import XCTest
@testable import strings_check

final class ParserTests: XCTestCase {
    func testWhitespaceOnlyString() throws {
        let input = "            "
        let result = Parser.key(from: input)
        XCTAssertNil(result)
    }
    
    func testStringWithExtraWhitespace() throws {
        let input = #"   "key"   =   "value"      "#
        let result = Parser.key(from: input)
        XCTAssertEqual(result, #""key""#)
    }
    
    func testStringWithEqualsInKey() throws {
        let input = #""key = bob" = "value";"#
        let result = Parser.key(from: input)
        XCTAssertEqual(result, #""key = bob""#)
    }
    
    func testStringWithQuotesInKey() throws {
        let input = #""k"'e'"y" = "value";"#
        let result = Parser.key(from: input)
        XCTAssertEqual(result, #""k"'e'"y""#)
    }
    
    func testEmptyLine() throws {
        let input = ""
        let result = Parser.key(from: input)
        XCTAssertNil(result)
    }
    
    func testStringWithNormalKey() throws {
        let input = #""key" = "value";"#
        let result = Parser.key(from: input)
        XCTAssertEqual(result, #""key""#)
    }

    func testStringComment() throws {
        let input = #"  /* wibble */ "#
        let result = Parser.key(from: input)
        XCTAssertNil(result)
    }

    func testCommentedOutKeyOnSingleLine() throws {
        let input = #"  /* "key" = "value"; */ "#
        let result = Parser.key(from: input)
        XCTAssertNil(result)
    }

    func testMultiLineKey() throws {
        let input = "\"key\ntwo\" = \"value\";"
        let result = Parser.key(from: input)
        XCTAssertEqual(result, "\"key\ntwo\"")
    }
}
