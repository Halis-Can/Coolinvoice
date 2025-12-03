//
//  PDFInvoiceView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI
import PDFKit

struct PDFInvoiceView: View {
    @State private var invoice: Invoice
    @StateObject private var businessManager = BusinessManager.shared
    @State private var pdfDocument: PDFDocument?
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingSendOptions = false
    @State private var showingTapToPay = false
    @State private var showingPaymentView = false
    @State private var showingMoreOptions = false
    @State private var showingEditView = false
    
    let onUpdate: ((Invoice) -> Void)?
    
    init(invoice: Invoice, onUpdate: ((Invoice) -> Void)? = nil) {
        _invoice = State(initialValue: invoice)
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Action Buttons Toolbar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ActionButton(title: "SEND", icon: "square.and.arrow.up.fill") {
                            showingSendOptions = true
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
                
                // PDF Content
                if let pdfDocument = pdfDocument {
                    PDFViewer(document: pdfDocument)
                } else {
                    ProgressView("Generating PDF...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Invoice PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .onAppear {
                generatePDF()
            }
            .onChange(of: invoice) {
                generatePDF()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfDocument = pdfDocument,
                   let pdfData = pdfDocument.dataRepresentation() {
                    ShareSheet(items: [pdfData])
                }
            }
            .sheet(isPresented: $showingSendOptions) {
                if let pdfDocument = pdfDocument,
                   let pdfData = pdfDocument.dataRepresentation() {
                    SendOptionsView(invoice: invoice, pdfData: pdfData)
                }
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
                    onUpdate?($invoice.wrappedValue)
                    generatePDF()
                    showingEditView = false
                }
            }
        }
    }
    
    private func generatePDF() {
        let pdfRenderer = PDFRenderer()
        pdfDocument = pdfRenderer.createInvoicePDF(invoice: invoice, business: businessManager.business)
    }
    
    private func sharePDF() {
        showingShareSheet = true
    }
    
    private func printPDF() {
        guard let pdfDocument = pdfDocument,
              let pdfData = pdfDocument.dataRepresentation() else { return }
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = invoice.invoiceNumber
        printController.printInfo = printInfo
        printController.printingItem = pdfData
        printController.present(animated: true)
    }
}

struct PDFEstimateView: View {
    @State private var estimate: Estimate
    @StateObject private var businessManager = BusinessManager.shared
    @State private var pdfDocument: PDFDocument?
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingSendOptions = false
    @State private var showingInvoiceView = false
    @State private var showingEditView = false
    
    let onUpdate: ((Estimate) -> Void)?
    
    init(estimate: Estimate, onUpdate: ((Estimate) -> Void)? = nil) {
        _estimate = State(initialValue: estimate)
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Action Buttons Toolbar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ActionButton(title: "SEND", icon: "square.and.arrow.up.fill") {
                            showingSendOptions = true
                        }
                        
                        ActionButton(title: "PRINT", icon: "printer.fill") {
                            printPDF()
                        }
                        
                        ActionButton(title: "INVOICE", icon: "doc.text.fill") {
                            showingInvoiceView = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(.systemGroupedBackground))
                
                // PDF Content
                if let pdfDocument = pdfDocument {
                    PDFViewer(document: pdfDocument)
                } else {
                    ProgressView("Generating PDF...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Estimate PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .onAppear {
                generatePDF()
            }
            .onChange(of: estimate) {
                generatePDF()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfDocument = pdfDocument,
                   let pdfData = pdfDocument.dataRepresentation() {
                    ShareSheet(items: [pdfData])
                }
            }
            .sheet(isPresented: $showingSendOptions) {
                if let pdfDocument = pdfDocument,
                   let pdfData = pdfDocument.dataRepresentation() {
                    SendOptionsView(estimate: estimate, pdfData: pdfData)
                }
            }
            .sheet(isPresented: $showingInvoiceView) {
                EstimateToInvoiceView(estimate: estimate) { invoice in
                    showingInvoiceView = false
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditEstimateView(estimate: $estimate) {
                    onUpdate?($estimate.wrappedValue)
                    generatePDF()
                    showingEditView = false
                }
            }
        }
    }
    
    private func generatePDF() {
        let pdfRenderer = PDFRenderer()
        pdfDocument = pdfRenderer.createEstimatePDF(estimate: estimate, business: businessManager.business)
    }
    
    private func sharePDF() {
        showingShareSheet = true
    }
    
    private func printPDF() {
        guard let pdfDocument = pdfDocument,
              let pdfData = pdfDocument.dataRepresentation() else { return }
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = estimate.estimateNumber
        printController.printInfo = printInfo
        printController.printingItem = pdfData
        printController.present(animated: true)
    }
}

// MARK: - PDF Viewer

struct PDFViewer: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = document
    }
}

