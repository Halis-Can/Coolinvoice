//
//  EstimateToInvoiceView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct EstimateToInvoiceView: View {
    let estimate: Estimate
    @Environment(\.dismiss) private var dismiss
    @State private var invoiceNumber: String = ""
    @State private var invoiceDate: Date = Date()
    @State private var dueDate: Date = Date()
    @State private var showingSuccess = false
    
    let onSave: (Invoice) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Invoice Number", text: $invoiceNumber)
                        .textContentType(.none)
                    
                    DatePicker("Invoice Date", selection: $invoiceDate, displayedComponents: .date)
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                } header: {
                    Text("Invoice Details")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Client: \(estimate.clientName)")
                        Text("Amount: \(estimate.total, format: .currency(code: "USD"))")
                        Text("Items: \(estimate.items.count)")
                    }
                    .font(.subheadline)
                } header: {
                    Text("From Estimate")
                }
            }
            .navigationTitle("Convert to Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createInvoice()
                    }
                    .disabled(invoiceNumber.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .alert("Invoice Created", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Invoice has been created successfully from the estimate.")
            }
        }
    }
    
    private func createInvoice() {
        let invoice = Invoice(
            invoiceNumber: invoiceNumber.isEmpty ? "INV-\(Int.random(in: 1000...9999))" : invoiceNumber,
            clientName: estimate.clientName,
            clientPhone: estimate.clientPhone,
            clientEmail: estimate.clientEmail,
            clientAddress: "",
            amount: estimate.amount,
            tax: estimate.tax,
            date: invoiceDate,
            dueDate: dueDate,
            status: .active,
            items: estimate.items,
            notes: estimate.notes
        )
        
        onSave(invoice)
        showingSuccess = true
    }
}

#Preview {
    EstimateToInvoiceView(estimate: Estimate.sampleEstimates[0]) { invoice in
        print("Created invoice: \(invoice.invoiceNumber)")
    }
}

