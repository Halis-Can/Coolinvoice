//
//  OrganizeItemsView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct OrganizeItemsView: View {
    @Binding var items: [InvoiceItem]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.description)
                                .font(.headline)
                            Text("\(item.quantity, format: .number) × \(item.unitPrice, format: .currency(code: "USD"))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(item.total, format: .currency(code: "USD"))
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 4)
                }
                .onMove { source, destination in
                    items.move(fromOffsets: source, toOffset: destination)
                }
            }
            .navigationTitle("Organize Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .environment(\.editMode, .constant(.active))
        }
    }
}

#Preview {
    OrganizeItemsView(items: .constant([
        InvoiceItem(description: "Item 1", quantity: 1, unitPrice: 100),
        InvoiceItem(description: "Item 2", quantity: 2, unitPrice: 200),
        InvoiceItem(description: "Item 3", quantity: 3, unitPrice: 300)
    ]))
}

