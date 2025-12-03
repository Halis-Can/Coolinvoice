//
//  NewEstimateView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct NewEstimateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedClient: Client?
    @State private var showingClientPicker = false
    @State private var estimateItems: [InvoiceItem] = []
    @State private var showingAddItem = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var estimateNumber: String = ""
    @State private var estimateDate: Date = Date()
    @State private var poNumber: String = ""
    @State private var showingDoneAlert = false
    
    let clients: [Client] = Client.sampleClients
    let onSave: (Estimate) -> Void
    
    init(onSave: @escaping (Estimate) -> Void) {
        self.onSave = onSave
        let count = Estimate.sampleEstimates.count + 1
        let year = Calendar.current.component(.year, from: Date())
        _estimateNumber = State(initialValue: "EST-\(year)-\(String(format: "%03d", count))")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Add Client Section
                Section {
                    if let client = selectedClient {
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text(client.initials)
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(client.name)
                                    .font(.headline)
                                if !client.company.isEmpty {
                                    Text(client.company)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                selectedClient = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                    } else {
                        Button {
                            showingClientPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("Add Client")
                                    .foregroundStyle(.blue)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Client")
                }
                
                // Add Line Items Section
                Section {
                    if estimateItems.isEmpty {
                        Button {
                            showingAddItem = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("Add Line Item")
                                    .foregroundStyle(.blue)
                                Spacer()
                            }
                        }
                    } else {
                        ForEach(estimateItems) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.description)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("\(item.quantity, format: .number) × \(item.unitPrice, format: .currency(code: "USD"))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(item.total, format: .currency(code: "USD"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .onDelete { indexSet in
                            estimateItems.remove(atOffsets: indexSet)
                        }
                        
                        Button {
                            showingAddItem = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("Add Line Item")
                                    .foregroundStyle(.blue)
                                Spacer()
                            }
                        }
                        
                        if !estimateItems.isEmpty {
                            Divider()
                            
                            HStack {
                                Text("Subtotal")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(subtotal, format: .currency(code: "USD"))
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Tax (9%)")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(tax, format: .currency(code: "USD"))
                                    .fontWeight(.semibold)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(total, format: .currency(code: "USD"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                } header: {
                    Text("Line Items")
                }
                
                // Photos Section
                Section {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                                .foregroundStyle(.blue)
                            Text("Add Photos")
                                .foregroundStyle(.blue)
                            Spacer()
                            if !selectedPhotos.isEmpty {
                                Text("\(selectedPhotos.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    if !loadedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button {
                                            loadedImages.remove(at: index)
                                            if index < selectedPhotos.count {
                                                selectedPhotos.remove(at: index)
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Photos")
                }
                
                // Estimate Details Section
                Section {
                    TextField("Estimate Number", text: $estimateNumber)
                        .textContentType(.none)
                    
                    DatePicker("Date", selection: $estimateDate, displayedComponents: .date)
                    
                    TextField("PO Number", text: $poNumber)
                        .textContentType(.none)
                } header: {
                    Text("Estimate Details")
                }
            }
            .navigationTitle("New Estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        createEstimate()
                    }
                    .disabled(!canCreateEstimate)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingClientPicker) {
                ClientPickerView(clients: clients) { client in
                    selectedClient = client
                    showingClientPicker = false
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddInvoiceItemView { item in
                    estimateItems.append(item)
                }
            }
            .onChange(of: selectedPhotos) { oldValue, newValue in
                Task {
                    await loadImages(from: newValue)
                }
            }
            .alert("Estimate Created", isPresented: $showingDoneAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your estimate has been created successfully.")
            }
        }
    }
    
    private var subtotal: Double {
        estimateItems.reduce(0) { $0 + $1.total }
    }
    
    private var tax: Double {
        subtotal * 0.09
    }
    
    private var total: Double {
        subtotal + tax
    }
    
    private var canCreateEstimate: Bool {
        selectedClient != nil &&
        !estimateItems.isEmpty
    }
    
    private func createEstimate() {
        guard let client = selectedClient else { return }
        
        let finalEstimateNumber = estimateNumber.trimmingCharacters(in: .whitespaces).isEmpty ? 
            "EST-\(Calendar.current.component(.year, from: Date()))-\(String(format: "%03d", Int.random(in: 100...999)))" : estimateNumber.trimmingCharacters(in: .whitespaces)
        
        let estimate = Estimate(
            estimateNumber: finalEstimateNumber,
            clientName: client.name,
            clientPhone: client.phone,
            clientEmail: client.email,
            clientAddress: client.address,
            amount: subtotal,
            tax: tax,
            date: estimateDate,
            expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: estimateDate),
            status: .pending,
            items: estimateItems,
            notes: poNumber.isEmpty ? "" : "PO Number: \(poNumber)"
        )
        
        onSave(estimate)
        showingDoneAlert = true
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        loadedImages.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    loadedImages.append(image)
                }
            }
        }
    }
}

struct ClientPickerView: View {
    let clients: [Client]
    let onSelect: (Client) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        } else {
            return clients.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText) ||
                client.company.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredClients) { client in
                    Button {
                        onSelect(client)
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text(client.initials)
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(client.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                if !client.company.isEmpty {
                                    Text(client.company)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else if !client.email.isEmpty {
                                    Text(client.email)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Select Client")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search clients")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NewEstimateView { estimate in
        print("Created estimate: \(estimate.estimateNumber)")
    }
}

