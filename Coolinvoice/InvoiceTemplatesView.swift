//
//  InvoiceTemplatesView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct InvoiceTemplatesView: View {
    @StateObject private var templateManager = TemplateManager.shared
    @State private var selectedTemplate: InvoiceTemplate
    
    init() {
        _selectedTemplate = State(initialValue: TemplateManager.shared.selectedInvoiceTemplate)
    }
    
    var body: some View {
        Form {
            Section {
                ForEach(InvoiceTemplate.allCases, id: \.self) { template in
                    Button {
                        selectedTemplate = template
                        templateManager.selectedInvoiceTemplate = template
                    } label: {
                        HStack {
                            Image(systemName: template.icon)
                                .foregroundStyle(selectedTemplate == template ? .blue : .gray)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text(template.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedTemplate == template {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            } header: {
                Text("Available Templates")
            } footer: {
                Text("Select a template to use for all new invoices. The default template is currently active.")
            }
        }
        .navigationTitle("Invoice Templates")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        InvoiceTemplatesView()
    }
}


