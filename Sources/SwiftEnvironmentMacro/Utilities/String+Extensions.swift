//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 16/3/24.
//

import Foundation

extension String {
    @inlinable func match(_ regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
            let stringRange = NSRange(location: .zero, length: utf16.count)
            let matches = regex.matches(in: self, range: stringRange)
            return !matches.isEmpty
        } catch {
            return false
        }
    }
    
    @inlinable var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
    
    @inlinable var isVoidPattern: Bool {
        match(#"^(Void|\(\s*\))$"#)
    }
    @inlinable var isOptionalPattern: Bool {
        match(#"^Optional\s?<.+>$"#)
    }
    @inlinable var isDictionaryPattern: Bool {
        match(#"^Dictionary\s?<.+>$"#)
    }
    @inlinable var isArrayPattern: Bool {
        match(#"^Array\s?<.+>$"#)
    }
}
