//
//  File.swift
//  
//
//  Created by csoler on 7/3/24.
//

import Foundation

public extension String {
    
    func extractStringsBetweenDelimiters(from startDelimiter: String, to endDelimiter: String) -> [String] {
        var extractedStrings = [String]()
        var currentIndex = self.startIndex
        
        while let startIndex = self.range(of: startDelimiter, options: [], range: currentIndex ..< self.endIndex)?.lowerBound {
            let nextIndex = self.index(startIndex, offsetBy: startDelimiter.count)
            guard let endIndex = self.range(of: endDelimiter, options: [], range: nextIndex ..< self.endIndex)?.lowerBound else { break }
            
            let extractedString = String(self[nextIndex..<endIndex])
            extractedStrings.append(extractedString)
            
            currentIndex = endIndex
        }
        
        return extractedStrings
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    
}
