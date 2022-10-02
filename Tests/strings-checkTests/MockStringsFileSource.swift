//
//  File.swift
//  
//
//  Created by David Wagner on 02/10/2022.
//

import Foundation
@testable import strings_check

struct MockStringsFileSource {
    let name: String
    let keys: Set<String>
    
    init(name: String = UUID().uuidString, keys: Set<String>) {
        self.name = name
        self.keys = keys
    }
}

extension MockStringsFileSource: StringsFileSource {}
