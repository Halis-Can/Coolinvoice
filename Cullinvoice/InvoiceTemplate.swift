//
//  InvoiceTemplate.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation
import SwiftUI
import Combine

enum InvoiceTemplate: String, Codable, CaseIterable {
    case defaultTemplate = "Default"
    case modernTemplate = "Modern"
    case classicTemplate = "Classic"
    case minimalTemplate = "Minimal"
    
    var displayName: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .defaultTemplate:
            return "Clean and professional design"
        case .modernTemplate:
            return "Modern layout with bold accents"
        case .classicTemplate:
            return "Traditional business style"
        case .minimalTemplate:
            return "Simple and minimalist design"
        }
    }
    
    var icon: String {
        switch self {
        case .defaultTemplate:
            return "doc.text.fill"
        case .modernTemplate:
            return "square.stack.3d.up.fill"
        case .classicTemplate:
            return "book.fill"
        case .minimalTemplate:
            return "square.fill"
        }
    }
}

class TemplateManager: ObservableObject {
    static let shared = TemplateManager()
    
    @Published var selectedInvoiceTemplate: InvoiceTemplate {
        didSet {
            saveTemplate()
        }
    }
    
    private let templateKey = "selectedInvoiceTemplate"
    
    private init() {
        if let savedTemplateData = UserDefaults.standard.data(forKey: templateKey),
           let savedTemplate = try? JSONDecoder().decode(InvoiceTemplate.self, from: savedTemplateData) {
            self.selectedInvoiceTemplate = savedTemplate
        } else {
            self.selectedInvoiceTemplate = .defaultTemplate
        }
    }
    
    private func saveTemplate() {
        if let encoded = try? JSONEncoder().encode(selectedInvoiceTemplate) {
            UserDefaults.standard.set(encoded, forKey: templateKey)
        }
    }
}

