//
//  DetectorError.swift
//  TextColorDetector
//
//  Created by Beatriz Leonel da Silva on 19/05/23.
//

import Foundation

enum DectectorErrors: Error {
    case notInEnglish
    case noColors
    case noColorFound
}

extension DectectorErrors: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notInEnglish:
            return "Invalid language!"
        case .noColors:
            return "No color!"
        case .noColorFound:
            return "No color found!"
        }
    }
}

extension DectectorErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .notInEnglish:
            return NSLocalizedString(
                "Your entry needs to be in english.",
                comment: "Invalid language!"
            )
            
        case .noColors:
            return NSLocalizedString(
                "Your entry needs to have some color.",
                comment: "No color!"
            )
        
        case .noColorFound:
            return NSLocalizedString(
                "No color found. Try again with some other entry.",
                comment: "No color!"
            )
        }
        
        
    }
}
