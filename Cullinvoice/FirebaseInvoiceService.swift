//
//  FirebaseInvoiceService.swift
//  Cullinvoice
//
//  Created for Firebase integration
//

import Foundation
import Combine
import FirebaseFirestore

class FirebaseInvoiceService: ObservableObject {
    static let shared = FirebaseInvoiceService()
    
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private init() {}
    
    // MARK: - Real-time Listener
    
    func startListening(userId: String) {
        stopListening()
        
        isLoading = true
        
        listener = db.collection("users")
            .document(userId)
            .collection("invoices")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.invoices = []
                        return
                    }
                    
                    self.invoices = documents.compactMap { document in
                        try? document.data(as: Invoice.self)
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - CRUD Operations
    
    func addInvoice(_ invoice: Invoice, userId: String) async throws {
        let invoiceRef = db.collection("users")
            .document(userId)
            .collection("invoices")
            .document(invoice.id.uuidString)
        
        try invoiceRef.setData(from: invoice)
    }
    
    func updateInvoice(_ invoice: Invoice, userId: String) async throws {
        let invoiceRef = db.collection("users")
            .document(userId)
            .collection("invoices")
            .document(invoice.id.uuidString)
        
        try invoiceRef.setData(from: invoice, merge: true)
    }
    
    func deleteInvoice(_ invoice: Invoice, userId: String) async throws {
        let invoiceRef = db.collection("users")
            .document(userId)
            .collection("invoices")
            .document(invoice.id.uuidString)
        
        try await invoiceRef.delete()
    }
    
    // MARK: - Batch Operations
    
    func syncInvoices(_ invoices: [Invoice], userId: String) async throws {
        let batch = db.batch()
        
        for invoice in invoices {
            let invoiceRef = db.collection("users")
                .document(userId)
                .collection("invoices")
                .document(invoice.id.uuidString)
            
            try batch.setData(from: invoice, forDocument: invoiceRef)
        }
        
        try await batch.commit()
    }
}

