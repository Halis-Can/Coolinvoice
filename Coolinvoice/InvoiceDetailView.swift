//
//  InvoiceDetailView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct InvoiceDetailView: View {
    @State private var invoice: Invoice
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingTemplateView = false
    @State private var showingAddItem = false
    
    init(invoice: Invoice) {
        _invoice = State(initialValue: invoice)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Invoice")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(invoice.invoiceNumber)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        StatusBadge(status: invoice.status)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Amount")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(invoice.total, format: .currency(code: "USD"))
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Client Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Client Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Name", value: invoice.clientName)
                        if !invoice.clientEmail.isEmpty {
                            InfoRow(label: "Email", value: invoice.clientEmail)
                        }
                        if !invoice.clientAddress.isEmpty {
                            InfoRow(label: "Address", value: invoice.clientAddress)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Invoice Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Invoice Details")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Issue Date", value: invoice.date.formatted(date: .abbreviated, time: .omitted))
                        InfoRow(label: "Due Date", value: invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                        if let paymentMethod = invoice.paymentMethod {
                            InfoRow(label: "Payment Method", value: paymentMethod.rawValue)
                        }
                        if let paidDate = invoice.paidDate {
                            InfoRow(label: "Paid Date", value: paidDate.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Items
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Items")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingAddItem = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if invoice.items.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No items yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Tap Add to add items to this invoice")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack(spacing: 0) {
                            ForEach(invoice.items) { item in
                                InvoiceItemRow(item: item)
                                if item.id != invoice.items.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Totals
                        VStack(spacing: 8) {
                            HStack {
                                Text("Subtotal")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(invoice.amount, format: .currency(code: "USD"))
                            }
                            
                            HStack {
                                Text("Tax")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(invoice.tax, format: .currency(code: "USD"))
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(invoice.total, format: .currency(code: "USD"))
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Notes
                if !invoice.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                        Text(invoice.notes)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Invoice Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingTemplateView = true
                    } label: {
                        Label("View Document", systemImage: "doc.text.fill")
                    }
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            // Edit invoice view would go here
            Text("Edit Invoice")
        }
        .sheet(isPresented: $showingTemplateView) {
            PrintReadyInvoiceView(invoice: invoice)
        }
        .sheet(isPresented: $showingAddItem) {
            AddInvoiceItemView { item in
                invoice.items.append(item)
                // Update invoice amount based on items
                let subtotal = invoice.items.reduce(0) { $0 + $1.total }
                invoice.amount = subtotal
                // Recalculate tax using configured tax rate
                invoice.tax = TaxSettingsManager.shared.calculateTax(for: subtotal)
            }
        }
    }
}

struct StatusBadge: View {
    let status: InvoiceStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.caption)
            Text(status.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(status.color.opacity(0.15))
        .foregroundStyle(status.color)
        .clipShape(Capsule())
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

struct InvoiceItemRow: View {
    let item: InvoiceItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
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
        .padding()
    }
}

#Preview {
    NavigationStack {
        InvoiceDetailView(invoice: Invoice.sampleInvoices[0])
    }
}

