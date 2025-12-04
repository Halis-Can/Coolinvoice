//
//  TaxSettingsManager.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation
import Combine

class TaxSettingsManager: ObservableObject {
    static let shared = TaxSettingsManager()
    
    @Published var taxRate: Double {
        didSet {
            saveTaxRate()
        }
    }
    
    private let taxRateKey = "taxRate"
    
    private init() {
        if let savedRate = UserDefaults.standard.object(forKey: taxRateKey) as? Double {
            self.taxRate = savedRate
        } else {
            self.taxRate = 0.09 // Default 9%
        }
    }
    
    private func saveTaxRate() {
        UserDefaults.standard.set(taxRate, forKey: taxRateKey)
    }
    
    func calculateTax(for amount: Double) -> Double {
        return amount * taxRate
    }
}


