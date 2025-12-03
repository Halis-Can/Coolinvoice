//
//  InvoiceMoreOptionsView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct InvoiceMoreOptionsView: View {
    let invoice: Invoice
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        // Edit invoice
                    } label: {
                        Label("Edit Invoice", systemImage: "pencil")
                    }
                    
                    Button {
                        // Duplicate invoice
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        // Delete invoice
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Button {
                        // Mark as paid
                    } label: {
                        Label("Mark as Paid", systemImage: "checkmark.circle")
                    }
                    
                    Button {
                        // Send reminder
                    } label: {
                        Label("Send Reminder", systemImage: "bell.badge")
                    }
                    
                    Button {
                        // View history
                    } label: {
                        Label("View History", systemImage: "clock")
                    }
                }
            }
            .navigationTitle("More Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    InvoiceMoreOptionsView(invoice: Invoice.sampleInvoices[0])
}

