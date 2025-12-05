//
//  SendOptionsView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI
import MessageUI

struct SendOptionsView: View {
    let invoice: Invoice?
    let estimate: Estimate?
    let pdfData: Data
    @Environment(\.dismiss) private var dismiss
    @State private var showingTextComposer = false
    @State private var showingEmailComposer = false
    @State private var canSendText = false
    @State private var canSendEmail = false
    
    init(invoice: Invoice? = nil, estimate: Estimate? = nil, pdfData: Data) {
        self.invoice = invoice
        self.estimate = estimate
        self.pdfData = pdfData
    }
    
    var clientPhone: String {
        if let invoice = invoice {
            return invoice.clientPhone
        } else if let estimate = estimate {
            return estimate.clientPhone
        }
        return ""
    }
    
    var clientEmail: String {
        if let invoice = invoice {
            return invoice.clientEmail
        } else if let estimate = estimate {
            return estimate.clientEmail
        }
        return ""
    }
    
    var documentName: String {
        if let invoice = invoice {
            return invoice.invoiceNumber
        } else if let estimate = estimate {
            return estimate.estimateNumber
        }
        return "Document"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showingTextComposer = true
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Text Message")
                                    .font(.headline)
                                if !clientPhone.isEmpty {
                                    Text(clientPhone)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Phone number not available")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            Spacer()
                        }
                    }
                    .disabled(!canSendText || clientPhone.isEmpty)
                    
                    Button {
                        showingEmailComposer = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email")
                                    .font(.headline)
                                if !clientEmail.isEmpty {
                                    Text(clientEmail)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Email address not available")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            Spacer()
                        }
                    }
                    .disabled(!canSendEmail || clientEmail.isEmpty)
                } header: {
                    Text("Send Options")
                } footer: {
                    Text("Send \(documentName) as PDF")
                }
            }
            .navigationTitle("Send Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                canSendText = MFMessageComposeViewController.canSendText()
                canSendEmail = MFMailComposeViewController.canSendMail()
            }
            .sheet(isPresented: $showingTextComposer) {
                if canSendText && !clientPhone.isEmpty {
                    MessageComposeView(
                        recipients: [clientPhone],
                        body: "Please find attached \(documentName) PDF.",
                        pdfData: pdfData,
                        pdfName: "\(documentName).pdf"
                    )
                }
            }
            .sheet(isPresented: $showingEmailComposer) {
                if canSendEmail && !clientEmail.isEmpty {
                    MailComposeView(
                        recipients: [clientEmail],
                        subject: documentName,
                        body: "Please find attached \(documentName) PDF.",
                        pdfData: pdfData,
                        pdfName: "\(documentName).pdf"
                    )
                }
            }
        }
    }
}

// MARK: - Message Compose View

struct MessageComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let body: String
    let pdfData: Data
    let pdfName: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        controller.addAttachmentData(pdfData, typeIdentifier: "com.adobe.pdf", filename: pdfName)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            dismiss()
        }
    }
}

// MARK: - Mail Compose View

struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String
    let pdfData: Data
    let pdfName: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(recipients)
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        controller.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: pdfName)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss()
        }
    }
}

