//
//  AddInvoiceItemView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct AddInvoiceItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var description: String = ""
    @State private var quantity: String = "1"
    @State private var unitPrice: String = ""
    
    let editingItem: InvoiceItem?
    let onSave: (InvoiceItem) -> Void
    
    init(editingItem: InvoiceItem? = nil, onSave: @escaping (InvoiceItem) -> Void) {
        self.editingItem = editingItem
        self.onSave = onSave
        _description = State(initialValue: editingItem?.description ?? "")
        _quantity = State(initialValue: editingItem != nil ? String(format: "%.1f", editingItem!.quantity) : "1")
        _unitPrice = State(initialValue: editingItem != nil ? String(format: "%.2f", editingItem!.unitPrice) : "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Item Description")
                }
                
                Section {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("1", text: $quantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Unit Price")
                        Spacer()
                        TextField("0.00", text: $unitPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                        Text("USD")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Pricing")
                }
                
                if let quantityValue = Double(quantity), let priceValue = Double(unitPrice), quantityValue > 0, priceValue >= 0 {
                    Section {
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(quantityValue * priceValue, format: .currency(code: "USD"))
                                .font(.headline)
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle(editingItem != nil ? "Edit Item" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingItem != nil ? "Save" : "Add") {
                        saveItem()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(quantity) != nil &&
        Double(quantity) ?? 0 > 0 &&
        Double(unitPrice) != nil &&
        Double(unitPrice) ?? 0 >= 0
    }
    
    private func saveItem() {
        guard let quantityValue = Double(quantity),
              let priceValue = Double(unitPrice) else {
            return
        }
        
        let item: InvoiceItem
        if let existingItem = editingItem {
            // Preserve the ID when editing
            item = InvoiceItem(
                id: existingItem.id,
                description: description.trimmingCharacters(in: .whitespaces),
                quantity: quantityValue,
                unitPrice: priceValue
            )
        } else {
            // Create new item with new ID
            item = InvoiceItem(
                description: description.trimmingCharacters(in: .whitespaces),
                quantity: quantityValue,
                unitPrice: priceValue
            )
        }
        
        onSave(item)
        dismiss()
    }
}

#Preview {
    AddInvoiceItemView { item in
        print("Added item: \(item.description)")
    }
}

