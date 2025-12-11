//
//  ContentView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: FirebaseDataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Estimates Tab
            NavigationStack {
                EstimateView()
            }
            .tabItem {
                Label("Estimate", systemImage: "doc.fill")
            }
            .tag(0)
            
            // Invoices Tab
            NavigationStack {
                InvoiceListView()
            }
            .tabItem {
                Label("Invoice", systemImage: "doc.text.fill")
            }
            .tag(1)
            
            // Clients Tab
            NavigationStack {
                ClientsView()
            }
            .tabItem {
                Label("Clients", systemImage: "person.2.fill")
            }
            .tag(2)
            
            // Payment Tab
            NavigationStack {
                PaymentView()
            }
            .tabItem {
                Label("Payment", systemImage: "creditcard.fill")
            }
            .tag(3)
            
            // More Tab
            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle.fill")
            }
            .tag(4)
        }
    }
}

struct InvoiceListView: View {
    @EnvironmentObject var dataManager: FirebaseDataManager
    @StateObject private var invoiceService = FirebaseInvoiceService.shared
    @State private var selectedSegment: InvoiceSegment = .active
    @State private var searchText = ""
    @State private var showingNewInvoice = false
    
    var invoices: [Invoice] {
        invoiceService.invoices
    }
    
    enum InvoiceSegment: String, CaseIterable {
        case active = "Active"
        case paid = "Paid"
    }
    
    var filteredInvoices: [Invoice] {
        var filtered = invoices
        
        // Filter by segment
        switch selectedSegment {
        case .active:
            filtered = filtered.filter { $0.status == .active }
        case .paid:
            filtered = filtered.filter { $0.status == .paid }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { invoice in
                invoice.clientName.localizedCaseInsensitiveContains(searchText) ||
                invoice.invoiceNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("Invoice Status", selection: $selectedSegment) {
                ForEach(InvoiceSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Invoice List
            List {
                if filteredInvoices.isEmpty {
                    ContentUnavailableView(
                        selectedSegment == .active ? "No Active Invoices" : "No Paid Invoices",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text(selectedSegment == .active ? "No active invoices match your search" : "No paid invoices match your search")
                    )
                } else {
                    ForEach(filteredInvoices) { invoice in
                        NavigationLink {
                            PDFInvoiceView(invoice: invoice) { updatedInvoice in
                                Task {
                                    if let userId = dataManager.userId {
                                        try? await invoiceService.updateInvoice(updatedInvoice, userId: userId)
                                    }
                                }
                            }
                        } label: {
                            InvoiceRow(invoice: invoice)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Invoices")
        .searchable(text: $searchText, prompt: "Search invoices")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewInvoice = true
                } label: {
                    Label("New Invoice", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewInvoice) {
            NewInvoiceView(existingInvoices: invoices) { invoice in
                Task {
                    if let userId = dataManager.userId {
                        try? await invoiceService.addInvoice(invoice, userId: userId)
                    }
                }
            }
        }
    }
}

struct InvoiceRow: View {
    let invoice: Invoice
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            Circle()
                .fill(invoice.status.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.clientName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Text(invoice.invoiceNumber)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(invoice.date, format: .dateTime.month().day().year())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(invoice.total, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(invoice.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(FirebaseDataManager.shared)
}
