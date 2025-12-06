//
//  EstimateToInvoiceView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct EstimateToInvoiceView: View {
    let estimate: Estimate
    let existingInvoices: [Invoice]
    @Environment(\.dismiss) private var dismiss
    @State private var invoiceNumber: String = ""
    @State private var invoiceDate: Date = Date()
    @State private var dueDate: Date = Date()
    @State private var showingSuccess = false
    @State private var showingConfirmAlert = false
    
    let onSave: (Invoice) -> Void
    
    init(estimate: Estimate, existingInvoices: [Invoice] = [], onSave: @escaping (Invoice) -> Void) {
        self.estimate = estimate
        self.existingInvoices = existingInvoices
        self.onSave = onSave
        let generatedNumber = InvoiceNumberGenerator.generateNextInvoiceNumber(from: existingInvoices)
        _invoiceNumber = State(initialValue: generatedNumber)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Invoice Number", text: $invoiceNumber)
                        .textContentType(.none)
                        .disabled(true) // Auto-generated, not editable
                    
                    DatePicker("Invoice Date", selection: $invoiceDate, displayedComponents: .date)
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                } header: {
                    Text("Invoice Details")
                } footer: {
                    Text("Invoice number is automatically generated.")
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
                        if estimate.status == .approved {
                            showingConfirmAlert = true
                        } else {
                            createInvoice()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Confirm Invoice Creation", isPresented: $showingConfirmAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Create Invoice") {
                    createInvoice()
                }
            } message: {
                Text("This will create a new invoice from the approved estimate. Continue?")
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
        let finalInvoiceNumber = invoiceNumber.trimmingCharacters(in: .whitespaces).isEmpty ?
            InvoiceNumberGenerator.generateNextInvoiceNumber(from: existingInvoices) :
            invoiceNumber.trimmingCharacters(in: .whitespaces)
        
        let invoice = Invoice(
            invoiceNumber: finalInvoiceNumber,
            clientName: estimate.clientName,
            clientPhone: estimate.clientPhone,
            clientEmail: estimate.clientEmail,
            clientAddress: estimate.clientAddress,
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

