//
//  DashboardView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct DashboardView: View {
    let invoices: [Invoice]
    
    var totalRevenue: Double {
        invoices.filter { $0.status == .paid }.reduce(0) { $0 + $1.total }
    }
    
    var activeAmount: Double {
        invoices.filter { $0.status == .active }.reduce(0) { $0 + $1.total }
    }
    
    var paidCount: Int {
        invoices.filter { $0.status == .paid }.count
    }
    
    var activeCount: Int {
        invoices.filter { $0.status == .active }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Overview of your business")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Statistics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Total Revenue",
                        value: totalRevenue,
                        icon: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Active",
                        value: activeAmount,
                        icon: "doc.text.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Total Invoices",
                        value: Double(invoices.count),
                        icon: "doc.text.fill",
                        color: .blue,
                        isCount: true
                    )
                }
                .padding(.horizontal)
                
                // Status Summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Status Summary")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        StatusRow(
                            status: .paid,
                            count: paidCount,
                            amount: totalRevenue
                        )
                        StatusRow(
                            status: .active,
                            count: activeCount,
                            amount: activeAmount
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct StatCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    var isCount: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if isCount {
                    Text("\(Int(value))")
                        .font(.title2)
                        .fontWeight(.semibold)
                } else {
                    Text(value, format: .currency(code: "USD"))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatusRow: View {
    let status: InvoiceStatus
    let count: Int
    let amount: Double
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: status.icon)
                    .foregroundStyle(status.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(status.rawValue)
                        .font(.headline)
                    Text("\(count) invoice\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(amount, format: .currency(code: "USD"))
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView(invoices: Invoice.sampleInvoices)
}

