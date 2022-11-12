//
//  File.swift
//  
//
//  Created by David Wagner on 02/10/2022.
//

import Foundation

struct Parser {
    /// Given a string containing a strings like entry, returns the
    /// key part.
    ///
    /// For example, given the string:
    ///
    ///     "foo.title" = "Super Special Thing";
    ///
    /// It will return: `"foo.title"`
    /// - Parameter from: The line to parse
    /// - Returns: The key part of the line, if one can be found
    static func key(from line: String) -> String? {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedLine.count > 0 else
        {
            return nil
        }
        
        let lineRange = NSMakeRange(0, trimmedLine.count)
        let matches = lineMatcher.matches(in: trimmedLine, options: [], range: lineRange)
        guard let match = matches.first,
              let keyRange = Range(match.range(withName: "key"), in: trimmedLine)
        else {
            return nil
        }
        
        return String(trimmedLine[keyRange])
    }
    
    private static let lineMatcher: NSRegularExpression = {
        try! NSRegularExpression(pattern: #"^\s*?(?<key>".*").*=.*?(?<value>".*").*?$"#, options: [.dotMatchesLineSeparators])
    }()
}
