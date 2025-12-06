//
//  InvoiceTemplateView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct InvoiceTemplateView: View {
    let invoice: Invoice
    @StateObject private var businessManager = BusinessManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header with Logo and Business Info
                VStack(alignment: .leading, spacing: 12) {
                    // Logo Section - Top Left
                    HStack(alignment: .top, spacing: 20) {
                        // Logo Section
                        if let logoImage = businessManager.business.logoImage {
                            logoImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay {
                                    Image(systemName: "building.2")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.gray)
                                }
                        }
                        
                        Spacer()
                    }
                    
                    // Business Information - Below Logo
                    VStack(alignment: .leading, spacing: 4) {
                        if !businessManager.business.name.isEmpty {
                            Text(businessManager.business.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        if !businessManager.business.address.isEmpty {
                            Text(businessManager.business.address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if !businessManager.business.licenseNumber.isEmpty {
                            Text("License: \(businessManager.business.licenseNumber)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Invoice Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("INVOICE")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(invoice.invoiceNumber)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack {
                            Text("Status:")
                                .foregroundStyle(.secondary)
                            StatusBadge(status: invoice.status)
                        }
                        
                        HStack {
                            Text("Date:")
                                .foregroundStyle(.secondary)
                            Text(invoice.date, format: .dateTime.month().day().year())
                        }
                        
                        HStack {
                            Text("Due Date:")
                                .foregroundStyle(.secondary)
                            Text(invoice.dueDate, format: .dateTime.month().day().year())
                        }
                    }
                    .font(.subheadline)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Client Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bill To:")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(invoice.clientName)
                        .font(.headline)
                    
                    if !invoice.clientEmail.isEmpty {
                        Text(invoice.clientEmail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !invoice.clientAddress.isEmpty {
                        Text(invoice.clientAddress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Items Table
                if !invoice.items.isEmpty {
                    VStack(spacing: 0) {
                        // Table Header
                        HStack {
                            Text("Description")
                                .font(.headline)
                            Spacer()
                            Text("Qty")
                                .font(.headline)
                                .frame(width: 60)
                            Text("Price")
                                .font(.headline)
                                .frame(width: 100, alignment: .trailing)
                            Text("Total")
                                .font(.headline)
                                .frame(width: 100, alignment: .trailing)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        
                        Divider()
                        
                        // Table Rows
                        ForEach(invoice.items) { item in
                            HStack {
                                Text(item.description)
                                    .font(.subheadline)
                                Spacer()
                                Text(item.quantity, format: .number)
                                    .font(.subheadline)
                                    .frame(width: 60)
                                Text(item.unitPrice, format: .currency(code: "USD"))
                                    .font(.subheadline)
                                    .frame(width: 100, alignment: .trailing)
                                Text(item.total, format: .currency(code: "USD"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(width: 100, alignment: .trailing)
                            }
                            .padding()
                            
                            if item.id != invoice.items.last?.id {
                                Divider()
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    }
                }
                
                // Totals
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack {
                            Text("Subtotal:")
                                .foregroundStyle(.secondary)
                            Text(invoice.amount, format: .currency(code: "USD"))
                        }
                        
                        HStack {
                            Text("Tax:")
                                .foregroundStyle(.secondary)
                            Text(invoice.tax, format: .currency(code: "USD"))
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Text(invoice.total, format: .currency(code: "USD"))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(width: 200)
                }
                
                // Notes
                if !invoice.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes:")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(invoice.notes)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .background(Color.white)
    }
}

#Preview {
    InvoiceTemplateView(invoice: Invoice.sampleInvoices[0])
}

