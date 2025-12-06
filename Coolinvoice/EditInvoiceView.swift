//
//  EditInvoiceView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct EditInvoiceView: View {
    @Binding var invoice: Invoice
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddItem = false
    @State private var showingOrganizeItems = false
    @State private var editingItem: InvoiceItem?
    @State private var showingEditItem = false
    @State private var clientPhoneText: String = ""
    @FocusState private var isPhoneFocused: Bool
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
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Phone Number", text: $clientPhoneText)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .focused($isPhoneFocused)
                        .onChange(of: isPhoneFocused) { oldValue, newValue in
                            // Format when focus is lost
                            if !newValue && oldValue {
                                let formatted = PhoneNumberFormatter.formatPhoneNumber(clientPhoneText)
                                clientPhoneText = formatted
                                invoice.clientPhone = formatted
                            }
                        }
                    
                    TextField("Email", text: $invoice.clientEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    TextField("Address", text: $invoice.clientAddress, axis: .vertical)
                        .lineLimit(3...10)
                        .textContentType(.fullStreetAddress)
                        .autocapitalization(.words)
                } header: {
                    Text("Client Information")
                }
                
                Section {
                    ForEach(invoice.items) { item in
                        InvoiceItemEditRow(item: item) {
                            editingItem = item
                            showingEditItem = true
                        }
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
                
                Section {
                    Toggle("Show Quantity", isOn: $invoice.showQuantity)
                    Toggle("Show Price", isOn: $invoice.showPrice)
                    Toggle("Show Total", isOn: $invoice.showTotal)
                } header: {
                    Text("Display Options")
                } footer: {
                    Text("Choose which columns to display in the PDF view.")
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
                        // Format phone number before saving
                        let formatted = PhoneNumberFormatter.formatPhoneNumber(clientPhoneText)
                        clientPhoneText = formatted
                        invoice.clientPhone = formatted
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
            .sheet(isPresented: $showingEditItem) {
                if let item = editingItem {
                    AddInvoiceItemView(editingItem: item) { updatedItem in
                        if let index = invoice.items.firstIndex(where: { $0.id == item.id }) {
                            invoice.items[index] = updatedItem
                            updateTotals()
                        }
                        editingItem = nil
                    }
                } else {
                    // Fallback - should not happen
                    Text("Error loading item")
                }
            }
            .sheet(isPresented: $showingOrganizeItems) {
                OrganizeItemsView(items: $invoice.items)
            }
            .onAppear {
                clientPhoneText = invoice.clientPhone
            }
        }
    }
    
    private func updateTotals() {
        let subtotal = invoice.items.reduce(0) { $0 + $1.total }
        invoice.amount = subtotal
        invoice.tax = TaxSettingsManager.shared.calculateTax(for: subtotal)
        // total is computed property: amount + tax, so it updates automatically
    }
}

struct InvoiceItemEditRow: View {
    let item: InvoiceItem
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
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
            
            Spacer()
            
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EditInvoiceView(invoice: .constant(Invoice.sampleInvoices[0])) {
        print("Saved")
    }
}

