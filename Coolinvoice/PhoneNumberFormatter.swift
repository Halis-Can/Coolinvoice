//
//  PhoneNumberFormatter.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation

class PhoneNumberFormatter {
    static func formatPhoneNumber(_ phone: String) -> String {
        // Remove all non-digit characters
        let digits = phone.filter { $0.isNumber }
        
        // Format as (XXX) XXX-XXXX
        if digits.count <= 3 {
            return digits
        } else if digits.count <= 6 {
            let areaCode = String(digits.prefix(3))
            let firstPart = String(digits.dropFirst(3))
            return "(\(areaCode)) \(firstPart)"
        } else if digits.count <= 10 {
            let areaCode = String(digits.prefix(3))
            let firstPart = String(digits.dropFirst(3).prefix(3))
            let secondPart = String(digits.dropFirst(6))
            return "(\(areaCode)) \(firstPart)-\(secondPart)"
        } else {
            // If more than 10 digits, take first 10
            let areaCode = String(digits.prefix(3))
            let firstPart = String(digits.dropFirst(3).prefix(3))
            let secondPart = String(digits.dropFirst(6).prefix(4))
            return "(\(areaCode)) \(firstPart)-\(secondPart)"
        }
    }
    
    static func unformatPhoneNumber(_ phone: String) -> String {
        // Remove formatting characters, keep only digits
        return phone.filter { $0.isNumber }
    }
}

