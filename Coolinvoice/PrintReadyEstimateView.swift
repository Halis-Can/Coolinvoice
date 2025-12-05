//
//  PrintReadyEstimateView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct PrintReadyEstimateView: View {
    let estimate: Estimate
    @StateObject private var businessManager = BusinessManager.shared
    @State private var viewMode: ViewMode = .mobile
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingInvoiceView = false
    @State private var showingMoreOptions = false
    
    enum ViewMode: String, CaseIterable {
        case mobile = "Mobile"
        case web = "Web"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Action Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ActionButton(title: "PRINT", icon: "printer.fill") {
                            printEstimate()
                        }
                        
                        ActionButton(title: "SEND", icon: "square.and.arrow.up.fill") {
                            showingShareSheet = true
                        }
                        
                        ActionButton(title: "INVOICE", icon: "doc.text.fill") {
                            showingInvoiceView = true
                        }
                        
                        ActionButton(title: "MORE", icon: "ellipsis.circle.fill") {
                            showingMoreOptions = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(.systemGroupedBackground))
                
                // View Mode Selector
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Estimate Content
                ScrollView {
                    EstimateTemplateContentView(
                        estimate: estimate,
                        viewMode: viewMode
                    )
                    .padding(viewMode == .web ? 40 : 20)
                    .frame(maxWidth: viewMode == .web ? 850 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                .background(Color(.systemGray6))
            }
            .navigationTitle("Estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [generateEstimatePDF()])
            }
            .sheet(isPresented: $showingInvoiceView) {
                EstimateToInvoiceView(estimate: estimate) { invoice in
                    // Invoice created from estimate
                    showingInvoiceView = false
                }
            }
            .sheet(isPresented: $showingMoreOptions) {
                EstimateMoreOptionsView(estimate: estimate)
            }
        }
    }
    
    private func printEstimate() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = estimate.estimateNumber
        printController.printInfo = printInfo
        
        let pdfData = generateEstimatePDF()
        printController.printingItem = pdfData
        printController.present(animated: true)
    }
    
    private func generateEstimatePDF() -> Data {
        return Data()
    }
}

struct EstimateTemplateContentView: View {
    let estimate: Estimate
    let viewMode: PrintReadyEstimateView.ViewMode
    @StateObject private var businessManager = BusinessManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: viewMode == .web ? 40 : 24) {
            // Header with Logo and Business Info
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 20) {
                    if let logoImage = businessManager.business.logoImage {
                        logoImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: viewMode == .web ? 150 : 100, height: viewMode == .web ? 150 : 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: viewMode == .web ? 150 : 100, height: viewMode == .web ? 150 : 100)
                            .overlay {
                                Image(systemName: "building.2")
                                    .font(.system(size: viewMode == .web ? 40 : 30))
                                    .foregroundStyle(.gray)
                            }
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    if !businessManager.business.name.isEmpty {
                        Text(businessManager.business.name)
                            .font(viewMode == .web ? .title : .title2)
                            .fontWeight(.bold)
                    }
                    
                    if !businessManager.business.address.isEmpty {
                        Text(businessManager.business.address)
                            .font(viewMode == .web ? .body : .subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !businessManager.business.licenseNumber.isEmpty {
                        Text("License: \(businessManager.business.licenseNumber)")
                            .font(viewMode == .web ? .subheadline : .caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
            
            Divider()
                .padding(.vertical, viewMode == .web ? 16 : 8)
            
            // Estimate Header
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("ESTIMATE")
                        .font(viewMode == .web ? .system(size: 48, weight: .bold) : .largeTitle)
                        .fontWeight(.bold)
                    Text(estimate.estimateNumber)
                        .font(viewMode == .web ? .title2 : .title3)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    HStack {
                        Text("Status:")
                            .foregroundStyle(.secondary)
                        EstimateStatusBadge(status: estimate.status)
                    }
                    
                    HStack {
                        Text("Date:")
                            .foregroundStyle(.secondary)
                        Text(estimate.date, format: .dateTime.month().day().year())
                    }
                    
                    HStack {
                        Text("Expiry:")
                            .foregroundStyle(.secondary)
                        Text(estimate.expiryDate, format: .dateTime.month().day().year())
                    }
                }
                .font(viewMode == .web ? .body : .subheadline)
            }
            
            Divider()
                .padding(.vertical, viewMode == .web ? 16 : 8)
            
            // Client Information
            VStack(alignment: .leading, spacing: 12) {
                Text("Estimate For:")
                    .font(viewMode == .web ? .title3 : .headline)
                    .foregroundStyle(.secondary)
                
                Text(estimate.clientName)
                    .font(viewMode == .web ? .title3 : .headline)
                    .fontWeight(.semibold)
                
                if !estimate.clientEmail.isEmpty {
                    Text(estimate.clientEmail)
                        .font(viewMode == .web ? .body : .subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(viewMode == .web ? 20 : 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Items Table
            if !estimate.items.isEmpty {
                VStack(spacing: 0) {
                    HStack {
                        Text("Description")
                            .font(viewMode == .web ? .title3 : .headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("Qty")
                            .font(viewMode == .web ? .title3 : .headline)
                            .fontWeight(.semibold)
                            .frame(width: viewMode == .web ? 80 : 60)
                        Text("Price")
                            .font(viewMode == .web ? .title3 : .headline)
                            .fontWeight(.semibold)
                            .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                        Text("Total")
                            .font(viewMode == .web ? .title3 : .headline)
                            .fontWeight(.semibold)
                            .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                    }
                    .padding(viewMode == .web ? 16 : 12)
                    .background(Color(.systemGray6))
                    
                    Divider()
                    
                    ForEach(estimate.items) { item in
                        HStack {
                            Text(item.description)
                                .font(viewMode == .web ? .body : .subheadline)
                            Spacer()
                            Text(item.quantity, format: .number)
                                .font(viewMode == .web ? .body : .subheadline)
                                .frame(width: viewMode == .web ? 80 : 60)
                            Text(item.unitPrice, format: .currency(code: "USD"))
                                .font(viewMode == .web ? .body : .subheadline)
                                .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                            Text(item.total, format: .currency(code: "USD"))
                                .font(viewMode == .web ? .body : .subheadline)
                                .fontWeight(.semibold)
                                .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                        }
                        .padding(viewMode == .web ? 16 : 12)
                        
                        if item.id != estimate.items.last?.id {
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
                VStack(alignment: .trailing, spacing: 12) {
                    HStack {
                        Text("Subtotal:")
                            .foregroundStyle(.secondary)
                            .font(viewMode == .web ? .body : .subheadline)
                        Text(estimate.amount, format: .currency(code: "USD"))
                            .font(viewMode == .web ? .body : .subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Tax:")
                            .foregroundStyle(.secondary)
                            .font(viewMode == .web ? .body : .subheadline)
                        Text(estimate.tax, format: .currency(code: "USD"))
                            .font(viewMode == .web ? .body : .subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total:")
                            .font(viewMode == .web ? .title3 : .headline)
                        Text(estimate.total, format: .currency(code: "USD"))
                            .font(viewMode == .web ? .title3 : .headline)
                            .fontWeight(.bold)
                    }
                }
                .frame(width: viewMode == .web ? 250 : 200)
            }
            
            // Notes
            if !estimate.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes:")
                        .font(viewMode == .web ? .title3 : .headline)
                        .foregroundStyle(.secondary)
                    Text(estimate.notes)
                        .font(viewMode == .web ? .body : .subheadline)
                }
                .padding(viewMode == .web ? 20 : 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(viewMode == .web ? 40 : 20)
        .frame(maxWidth: viewMode == .web ? 850 : .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    PrintReadyEstimateView(estimate: Estimate.sampleEstimates[0])
}

