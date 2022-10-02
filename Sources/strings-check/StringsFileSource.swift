//
//  File.swift
//  
//
//  Created by David Wagner on 02/10/2022.
//

import Foundation

protocol StringsFileSource {
    var name: String { get }
    var keys: Set<String> { get }
}
