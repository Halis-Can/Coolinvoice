//
//  NewInvoiceView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct NewInvoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var clientName: String = ""
    @State private var clientPhone: String = ""
    @State private var clientEmail: String = ""
    @State private var clientAddress: String = ""
    @State private var invoiceItems: [InvoiceItem] = []
    @State private var showingAddItem = false
    @State private var editingItem: InvoiceItem?
    @State private var showingEditItem = false
    @State private var invoiceNumber: String = ""
    @State private var invoiceDate: Date = Date()
    @State private var dueDate: Date = Date()
    @State private var notes: String = ""
    @State private var showingDoneAlert = false
    @FocusState private var isPhoneFocused: Bool
    
    let existingInvoices: [Invoice]
    let onSave: (Invoice) -> Void
    
    init(existingInvoices: [Invoice] = [], onSave: @escaping (Invoice) -> Void) {
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
                } header: {
                    Text("Invoice Information")
                } footer: {
                    Text("Invoice number is automatically generated.")
                }
                
                Section {
                    DatePicker("Invoice Date", selection: $invoiceDate, displayedComponents: .date)
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                } header: {
                    Text("Dates")
                }
                
                Section {
                    TextField("Name", text: $clientName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Phone Number", text: $clientPhone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .focused($isPhoneFocused)
                        .onChange(of: isPhoneFocused) { oldValue, newValue in
                            // Format when focus is lost
                            if !newValue && oldValue {
                                let formatted = PhoneNumberFormatter.formatPhoneNumber(clientPhone)
                                clientPhone = formatted
                            }
                        }
                    
                    TextField("Email", text: $clientEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    TextField("Address", text: $clientAddress, axis: .vertical)
                        .lineLimit(3...10)
                        .textContentType(.fullStreetAddress)
                        .autocapitalization(.words)
                } header: {
                    Text("Client Information")
                }
                
                Section {
                    ForEach(invoiceItems) { item in
                        InvoiceItemEditRow(item: item) {
                            editingItem = item
                            showingEditItem = true
                        }
                    }
                    .onDelete { indexSet in
                        invoiceItems.remove(atOffsets: indexSet)
                        updateTotals()
                    }
                    
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                } header: {
                    Text("Items")
                }
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("New Invoice")
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
                        let formatted = PhoneNumberFormatter.formatPhoneNumber(clientPhone)
                        clientPhone = formatted
                        createInvoice()
                    }
                    .disabled(!canCreateInvoice)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddInvoiceItemView { item in
                    invoiceItems.append(item)
                    updateTotals()
                }
            }
            .sheet(isPresented: $showingEditItem) {
                if let item = editingItem {
                    AddInvoiceItemView(editingItem: item) { updatedItem in
                        if let index = invoiceItems.firstIndex(where: { $0.id == item.id }) {
                            invoiceItems[index] = updatedItem
                            updateTotals()
                        }
                        editingItem = nil
                    }
                } else {
                    // Fallback - should not happen
                    Text("Error loading item")
                }
            }
            .alert("Invoice Created", isPresented: $showingDoneAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your invoice has been created successfully.")
            }
        }
    }
    
    private var subtotal: Double {
        invoiceItems.reduce(0) { $0 + $1.total }
    }
    
    private var tax: Double {
        TaxSettingsManager.shared.calculateTax(for: subtotal)
    }
    
    private var total: Double {
        subtotal + tax
    }
    
    private var canCreateInvoice: Bool {
        !clientName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !invoiceItems.isEmpty
    }
    
    private func updateTotals() {
        // Totals are computed properties, no need to update
    }
    
    private func createInvoice() {
        guard !clientName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let finalInvoiceNumber = invoiceNumber.trimmingCharacters(in: .whitespaces).isEmpty ?
            InvoiceNumberGenerator.generateNextInvoiceNumber(from: existingInvoices) :
            invoiceNumber.trimmingCharacters(in: .whitespaces)
        
        let invoice = Invoice(
            invoiceNumber: finalInvoiceNumber,
            clientName: clientName.trimmingCharacters(in: .whitespaces),
            clientPhone: clientPhone,
            clientEmail: clientEmail,
            clientAddress: clientAddress,
            amount: subtotal,
            tax: tax,
            date: invoiceDate,
            dueDate: dueDate,
            status: .active,
            items: invoiceItems,
            notes: notes
        )
        
        onSave(invoice)
        showingDoneAlert = true
    }
}

#Preview {
    NewInvoiceView(existingInvoices: Invoice.sampleInvoices) { invoice in
        print("Created invoice: \(invoice.invoiceNumber)")
    }
}

