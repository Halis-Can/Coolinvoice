//
//  InvoiceNumberGenerator.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation

class InvoiceNumberGenerator {
    static func generateNextInvoiceNumber(from invoices: [Invoice]) -> String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearPrefix = "INV-\(currentYear)-"
        
        // Extract all invoice numbers for the current year
        let currentYearInvoices = invoices.filter { invoice in
            invoice.invoiceNumber.hasPrefix(yearPrefix)
        }
        
        // Extract the numeric part from invoice numbers
        var maxNumber = 0
        for invoice in currentYearInvoices {
            let numberPart = String(invoice.invoiceNumber.dropFirst(yearPrefix.count))
            if let number = Int(numberPart) {
                maxNumber = max(maxNumber, number)
            }
        }
        
        // Generate next number
        let nextNumber = maxNumber + 1
        return "\(yearPrefix)\(String(format: "%03d", nextNumber))"
    }
}


