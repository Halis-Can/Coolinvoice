//
//  EstimateView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct EstimateView: View {
    @State private var estimates: [Estimate] = Estimate.sampleEstimates
    @State private var selectedSegment: EstimateSegment = .pending
    @State private var searchText = ""
    @State private var showingNewEstimate = false
    
    enum EstimateSegment: String, CaseIterable {
        case pending = "Pending"
        case approved = "Approved"
        case declined = "Declined"
    }
    
    var filteredEstimates: [Estimate] {
        var filtered = estimates
        
        // Filter by segment
        switch selectedSegment {
        case .pending:
            filtered = filtered.filter { $0.status == .pending }
        case .approved:
            filtered = filtered.filter { $0.status == .approved }
        case .declined:
            filtered = filtered.filter { $0.status == .declined }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { estimate in
                estimate.clientName.localizedCaseInsensitiveContains(searchText) ||
                estimate.estimateNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("Estimate Status", selection: $selectedSegment) {
                ForEach(EstimateSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Estimate List
            List {
                if filteredEstimates.isEmpty {
                    ContentUnavailableView(
                        getEmptyStateTitle(),
                        systemImage: "doc.text.magnifyingglass",
                        description: Text(getEmptyStateDescription())
                    )
                } else {
                    ForEach(filteredEstimates) { estimate in
                        NavigationLink {
                            PDFEstimateView(estimate: estimate)
                        } label: {
                            EstimateRow(estimate: estimate)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Estimates")
        .searchable(text: $searchText, prompt: "Search estimates")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewEstimate = true
                } label: {
                    Label("New Estimate", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewEstimate) {
            NewEstimateView { estimate in
                estimates.append(estimate)
            }
        }
    }
    
    private func getEmptyStateTitle() -> String {
        switch selectedSegment {
        case .pending:
            return "No Pending Estimates"
        case .approved:
            return "No Approved Estimates"
        case .declined:
            return "No Declined Estimates"
        }
    }
    
    private func getEmptyStateDescription() -> String {
        switch selectedSegment {
        case .pending:
            return "No pending estimates match your search"
        case .approved:
            return "No approved estimates match your search"
        case .declined:
            return "No declined estimates match your search"
        }
    }
}

struct EstimateRow: View {
    let estimate: Estimate
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(estimate.status.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(estimate.clientName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(estimate.estimateNumber)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(estimate.total, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(estimate.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EstimateDetailView: View {
    let estimate: Estimate
    @Environment(\.dismiss) private var dismiss
    @State private var showingTemplateView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estimate")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(estimate.estimateNumber)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        EstimateStatusBadge(status: estimate.status)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Amount")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(estimate.total, format: .currency(code: "USD"))
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
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Client Information")
                        .font(.headline)
                    
                        VStack(alignment: .leading, spacing: 12) {
                            EstimateInfoRow(label: "Name", value: estimate.clientName)
                            if !estimate.clientEmail.isEmpty {
                                EstimateInfoRow(label: "Email", value: estimate.clientEmail)
                            }
                        }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                if !estimate.items.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Items")
                            .font(.headline)
                        
                        VStack(spacing: 0) {
                            ForEach(estimate.items) { item in
                                InvoiceItemRow(item: item)
                                if item.id != estimate.items.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Subtotal")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(estimate.amount, format: .currency(code: "USD"))
                            }
                            
                            HStack {
                                Text("Tax")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(estimate.tax, format: .currency(code: "USD"))
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(estimate.total, format: .currency(code: "USD"))
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Estimate Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingTemplateView = true
                } label: {
                    Label("View Document", systemImage: "doc.text.fill")
                }
            }
        }
        .sheet(isPresented: $showingTemplateView) {
            PrintReadyEstimateView(estimate: estimate)
        }
    }
}

struct EstimateStatusBadge: View {
    let status: EstimateStatus
    
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

struct EstimateInfoRow: View {
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

#Preview {
    NavigationStack {
        EstimateView()
    }
}

