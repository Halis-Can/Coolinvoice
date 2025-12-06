//
//  InvoicePaymentView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct InvoicePaymentView: View {
    let invoice: Invoice
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMethod: PaymentMethod = .creditCard
    @State private var paymentAmount: Double
    @State private var showingSuccess = false
    
    let onUpdate: ((Invoice) -> Void)?
    
    init(invoice: Invoice, onUpdate: ((Invoice) -> Void)? = nil) {
        self.invoice = invoice
        self.onUpdate = onUpdate
        _paymentAmount = State(initialValue: invoice.total)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Invoice: \(invoice.invoiceNumber)")
                            .font(.headline)
                        Text("Client: \(invoice.clientName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Invoice Information")
                }
                
                Section {
                    Picker("Payment Method", selection: $selectedMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $paymentAmount, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Payment Details")
                }
            }
            .navigationTitle("Record Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePayment()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Payment Recorded", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Payment of \(paymentAmount, format: .currency(code: "USD")) has been recorded.")
            }
        }
    }
    
    private func savePayment() {
        // Update invoice status to paid
        var updatedInvoice = invoice
        updatedInvoice.status = .paid
        updatedInvoice.paymentMethod = selectedMethod
        updatedInvoice.paidDate = Date()
        updatedInvoice.paymentAmount = paymentAmount
        
        onUpdate?(updatedInvoice)
        showingSuccess = true
    }
}

#Preview {
    InvoicePaymentView(invoice: Invoice.sampleInvoices[0])
}

