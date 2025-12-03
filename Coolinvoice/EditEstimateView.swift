//
//  EditEstimateView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI
import PhotosUI

struct EditEstimateView: View {
    @Binding var estimate: Estimate
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddItem = false
    @State private var showingOrganizeItems = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var poNumber: String = ""
    
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Estimate Number", text: $estimate.estimateNumber)
                        .disabled(true)
                    
                    DatePicker("Date", selection: $estimate.date, displayedComponents: .date)
                    
                    DatePicker("Expiry Date", selection: $estimate.expiryDate, displayedComponents: .date)
                    
                    Picker("Status", selection: $estimate.status) {
                        ForEach(EstimateStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("PO Number", text: $poNumber)
                        .textContentType(.none)
                } header: {
                    Text("Estimate Information")
                }
                
                Section {
                    TextField("Name", text: $estimate.clientName)
                    
                    TextField("Phone Number", text: $estimate.clientPhone)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $estimate.clientEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Address", text: $estimate.clientAddress, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("Client Information")
                }
                
                Section {
                    ForEach(estimate.items) { item in
                        EstimateItemEditRow(item: item)
                    }
                    .onDelete { indexSet in
                        estimate.items.remove(atOffsets: indexSet)
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
                        if !estimate.items.isEmpty {
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
                    TextField("Notes", text: $estimate.notes, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Edit Estimate")
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
                    estimate.items.append(item)
                    updateTotals()
                }
            }
            .sheet(isPresented: $showingOrganizeItems) {
                OrganizeItemsView(items: $estimate.items)
            }
        }
    }
    
    private func updateTotals() {
        let subtotal = estimate.items.reduce(0) { $0 + $1.total }
        estimate.amount = subtotal
        estimate.tax = subtotal * 0.09
        // total is computed property: amount + tax, so it updates automatically
    }
}

struct EstimateItemEditRow: View {
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
    EditEstimateView(estimate: .constant(Estimate.sampleEstimates[0])) {
        print("Saved")
    }
}

