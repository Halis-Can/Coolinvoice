//
//  TaxSettingsView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct TaxSettingsView: View {
    @StateObject private var taxManager = TaxSettingsManager.shared
    @State private var taxRatePercentage: Double = 9.0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tax Rate")
                        .font(.headline)
                    
                    HStack {
                        Slider(value: $taxRatePercentage, in: 0...30, step: 0.1)
                        
                        Text("\(taxRatePercentage, specifier: "%.1f")%")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width: 60)
                    }
                    
                    Text("Current tax rate: \(taxRatePercentage, specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Tax Configuration")
            } footer: {
                Text("This tax rate will be applied to all new invoices and estimates. Existing documents will not be affected.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Example Calculation")
                        .font(.headline)
                    
                    let exampleAmount: Double = 1000.0
                    let exampleTax = exampleAmount * (taxRatePercentage / 100)
                    let exampleTotal = exampleAmount + exampleTax
                    
                    HStack {
                        Text("Subtotal:")
                        Spacer()
                        Text(exampleAmount, format: .currency(code: "USD"))
                    }
                    
                    HStack {
                        Text("Tax (\(taxRatePercentage, specifier: "%.1f")%):")
                        Spacer()
                        Text(exampleTax, format: .currency(code: "USD"))
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(exampleTotal, format: .currency(code: "USD"))
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Preview")
            }
        }
        .navigationTitle("Tax Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    taxManager.taxRate = taxRatePercentage / 100
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            taxRatePercentage = taxManager.taxRate * 100
        }
    }
}

#Preview {
    NavigationStack {
        TaxSettingsView()
    }
}


