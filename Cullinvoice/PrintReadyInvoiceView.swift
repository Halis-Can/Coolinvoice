//
//  PrintReadyInvoiceView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct PrintReadyInvoiceView: View {
    @State private var invoice: Invoice
    @StateObject private var businessManager = BusinessManager.shared
    @State private var viewMode: ViewMode = .mobile
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingTapToPay = false
    @State private var showingPaymentView = false
    @State private var showingMoreOptions = false
    @State private var showingEditView = false
    
    let onUpdate: ((Invoice) -> Void)?
    
    init(invoice: Invoice, onUpdate: ((Invoice) -> Void)? = nil) {
        _invoice = State(initialValue: invoice)
        self.onUpdate = onUpdate
    }
    
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
                            printInvoice()
                        }
                        
                        ActionButton(title: "SEND", icon: "square.and.arrow.up.fill") {
                            showingShareSheet = true
                        }
                        
                        ActionButton(title: "TAP TO PAY", icon: "waveform.circle.fill") {
                            showingTapToPay = true
                        }
                        
                        ActionButton(title: "PAYMENT", icon: "creditcard.fill") {
                            showingPaymentView = true
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
                
                // Invoice Content
                ScrollView {
                    InvoiceTemplateContentView(
                        invoice: invoice,
                        viewMode: viewMode
                    )
                    .padding(viewMode == .web ? 40 : 20)
                    .frame(maxWidth: viewMode == .web ? 850 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                .background(Color(.systemGray6))
            }
            .navigationTitle("Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [generateInvoicePDF()])
            }
            .sheet(isPresented: $showingTapToPay) {
                TapToPaySheet()
            }
            .sheet(isPresented: $showingPaymentView) {
                InvoicePaymentView(invoice: invoice)
            }
            .sheet(isPresented: $showingMoreOptions) {
                InvoiceMoreOptionsView(invoice: invoice)
            }
            .sheet(isPresented: $showingEditView) {
                EditInvoiceView(invoice: $invoice) {
                    // Invoice updated, notify parent
                    onUpdate?(invoice)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
    }
    
    private func printInvoice() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = invoice.invoiceNumber
        printController.printInfo = printInfo
        
        // Create PDF representation
        let pdfData = generateInvoicePDF()
        printController.printingItem = pdfData
        printController.present(animated: true)
    }
    
    private func generateInvoicePDF() -> Data {
        // In a real app, you would generate a proper PDF here
        // For now, we'll return empty data as placeholder
        return Data()
    }
}

struct InvoiceTemplateContentView: View {
    let invoice: Invoice
    let viewMode: PrintReadyInvoiceView.ViewMode
    @StateObject private var businessManager = BusinessManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: viewMode == .web ? 40 : 24) {
            // Invoice Header - At the top
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("INVOICE")
                        .font(viewMode == .web ? .system(size: 38.4, weight: .bold) : .system(size: 27.2, weight: .bold))
                        .fontWeight(.bold)
                    Text(invoice.invoiceNumber)
                        .font(viewMode == .web ? .title2 : .title3)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
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
                .font(viewMode == .web ? .body : .subheadline)
            }
            
            Divider()
                .padding(.vertical, viewMode == .web ? 16 : 8)
            
            // Header with Logo and Business Info
            VStack(alignment: .leading, spacing: 16) {
                // Logo Section - Top Left
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
                
                // Business Information - Below Logo
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
            
            Divider()
                .padding(.vertical, viewMode == .web ? 16 : 8)
            
            // Client Information
            VStack(alignment: .leading, spacing: 12) {
                Text("Bill To:")
                    .font(viewMode == .web ? .title3 : .headline)
                    .foregroundStyle(.secondary)
                
                Text(invoice.clientName)
                    .font(viewMode == .web ? .title3 : .headline)
                    .fontWeight(.semibold)
                
                if !invoice.clientEmail.isEmpty {
                    Text(invoice.clientEmail)
                        .font(viewMode == .web ? .body : .subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !invoice.clientAddress.isEmpty {
                    Text(invoice.clientAddress)
                        .font(viewMode == .web ? .body : .subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(viewMode == .web ? 20 : 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Items Table
            if !invoice.items.isEmpty {
                VStack(spacing: 0) {
                    // Table Header
                    HStack {
                        Text("Description")
                            .font(viewMode == .web ? .title3 : .headline)
                            .fontWeight(.semibold)
                        Spacer()
                        if invoice.showQuantity {
                            Text("Qty")
                                .font(viewMode == .web ? .title3 : .headline)
                                .fontWeight(.semibold)
                                .frame(width: viewMode == .web ? 80 : 60)
                        }
                        if invoice.showPrice {
                            Text("Price")
                                .font(viewMode == .web ? .title3 : .headline)
                                .fontWeight(.semibold)
                                .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                        }
                        if invoice.showTotal {
                            Text("Total")
                                .font(viewMode == .web ? .title3 : .headline)
                                .fontWeight(.semibold)
                                .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                        }
                    }
                    .padding(viewMode == .web ? 16 : 12)
                    .background(Color(.systemGray6))
                    
                    Divider()
                    
                    // Table Rows
                    ForEach(invoice.items) { item in
                        HStack {
                            Text(item.description)
                                .font(viewMode == .web ? .body : .subheadline)
                            Spacer()
                            if invoice.showQuantity {
                                Text(item.quantity, format: .number)
                                    .font(viewMode == .web ? .body : .subheadline)
                                    .frame(width: viewMode == .web ? 80 : 60)
                            }
                            if invoice.showPrice {
                                Text(item.unitPrice, format: .currency(code: "USD"))
                                    .font(viewMode == .web ? .body : .subheadline)
                                    .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                            }
                            if invoice.showTotal {
                                Text(item.total, format: .currency(code: "USD"))
                                    .font(viewMode == .web ? .body : .subheadline)
                                    .fontWeight(.semibold)
                                    .frame(width: viewMode == .web ? 120 : 100, alignment: .trailing)
                            }
                        }
                        .padding(viewMode == .web ? 16 : 12)
                        
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
                VStack(alignment: .trailing, spacing: 12) {
                    HStack {
                        Text("Subtotal:")
                            .foregroundStyle(.secondary)
                            .font(viewMode == .web ? .body : .subheadline)
                        Text(invoice.amount, format: .currency(code: "USD"))
                            .font(viewMode == .web ? .body : .subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Tax:")
                            .foregroundStyle(.secondary)
                            .font(viewMode == .web ? .body : .subheadline)
                        Text(invoice.tax, format: .currency(code: "USD"))
                            .font(viewMode == .web ? .body : .subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total:")
                            .font(viewMode == .web ? .title3 : .headline)
                        Text(invoice.total, format: .currency(code: "USD"))
                            .font(viewMode == .web ? .title3 : .headline)
                            .fontWeight(.bold)
                    }
                }
                .frame(width: viewMode == .web ? 250 : 200)
            }
            
            // Notes
            if !invoice.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes:")
                        .font(viewMode == .web ? .title3 : .headline)
                        .foregroundStyle(.secondary)
                    Text(invoice.notes)
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

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PrintReadyInvoiceView(invoice: Invoice.sampleInvoices[0])
}

