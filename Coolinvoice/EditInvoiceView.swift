//
//  EditInvoiceView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct EditInvoiceView: View {
    @Binding var invoice: Invoice
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddItem = false
    @State private var showingOrganizeItems = false
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Invoice Number", text: $invoice.invoiceNumber)
                    
                    DatePicker("Date", selection: $invoice.date, displayedComponents: .date)
                    
                    DatePicker("Due Date", selection: $invoice.dueDate, displayedComponents: .date)
                    
                    Picker("Status", selection: $invoice.status) {
                        ForEach(InvoiceStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                } header: {
                    Text("Invoice Information")
                }
                
                Section {
                    TextField("Name", text: $invoice.clientName)
                    
                    TextField("Phone Number", text: $invoice.clientPhone)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $invoice.clientEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Address", text: $invoice.clientAddress, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("Client Information")
                }
                
                Section {
                    ForEach(invoice.items) { item in
                        InvoiceItemEditRow(item: item)
                    }
                    .onDelete { indexSet in
                        invoice.items.remove(atOffsets: indexSet)
                        updateTotals()
                    }
                    
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                } header: {
                    HStack {
                        Text("Items")
                        Spacer()
                        if !invoice.items.isEmpty {
                            Button {
                                showingOrganizeItems = true
                            } label: {
                                Label("Organize", systemImage: "arrow.up.arrow.down")
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                Section {
                    TextField("Notes", text: $invoice.notes, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Edit Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateTotals()
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddInvoiceItemView { item in
                    invoice.items.append(item)
                    updateTotals()
                }
            }
            .sheet(isPresented: $showingOrganizeItems) {
                OrganizeItemsView(items: $invoice.items)
            }
        }
    }
    
    private func updateTotals() {
        let subtotal = invoice.items.reduce(0) { $0 + $1.total }
        invoice.amount = subtotal
        invoice.tax = subtotal * 0.09
        // total is computed property: amount + tax, so it updates automatically
    }
}

struct InvoiceItemEditRow: View {
    let item: InvoiceItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.description)
                .font(.headline)
            Text("\(item.quantity, format: .number) × \(item.unitPrice, format: .currency(code: "USD"))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(item.total, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EditInvoiceView(invoice: .constant(Invoice.sampleInvoices[0])) {
        print("Saved")
    }
}

