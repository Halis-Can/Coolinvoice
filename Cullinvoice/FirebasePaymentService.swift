//
//  FirebasePaymentService.swift
//  Cullinvoice
//
//  Created for Firebase integration
//

import Foundation
import Combine
import FirebaseFirestore

class FirebasePaymentService: ObservableObject {
    static let shared = FirebasePaymentService()
    
    @Published var payments: [Payment] = []
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
            .collection("payments")
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
                        self.payments = []
                        return
                    }
                    
                    self.payments = documents.compactMap { document in
                        try? document.data(as: Payment.self)
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - CRUD Operations
    
    func addPayment(_ payment: Payment, userId: String) async throws {
        let paymentRef = db.collection("users")
            .document(userId)
            .collection("payments")
            .document(payment.id.uuidString)
        
        try paymentRef.setData(from: payment)
    }
    
    func updatePayment(_ payment: Payment, userId: String) async throws {
        let paymentRef = db.collection("users")
            .document(userId)
            .collection("payments")
            .document(payment.id.uuidString)
        
        try paymentRef.setData(from: payment, merge: true)
    }
    
    func deletePayment(_ payment: Payment, userId: String) async throws {
        let paymentRef = db.collection("users")
            .document(userId)
            .collection("payments")
            .document(payment.id.uuidString)
        
        try await paymentRef.delete()
    }
}

