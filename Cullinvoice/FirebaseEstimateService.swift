//
//  FirebaseEstimateService.swift
//  Cullinvoice
//
//  Created for Firebase integration
//

import Foundation
import Combine
import FirebaseFirestore

class FirebaseEstimateService: ObservableObject {
    static let shared = FirebaseEstimateService()
    
    @Published var estimates: [Estimate] = []
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
            .collection("estimates")
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
                        self.estimates = []
                        return
                    }
                    
                    self.estimates = documents.compactMap { document in
                        try? document.data(as: Estimate.self)
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - CRUD Operations
    
    func addEstimate(_ estimate: Estimate, userId: String) async throws {
        let estimateRef = db.collection("users")
            .document(userId)
            .collection("estimates")
            .document(estimate.id.uuidString)
        
        try estimateRef.setData(from: estimate)
    }
    
    func updateEstimate(_ estimate: Estimate, userId: String) async throws {
        let estimateRef = db.collection("users")
            .document(userId)
            .collection("estimates")
            .document(estimate.id.uuidString)
        
        try estimateRef.setData(from: estimate, merge: true)
    }
    
    func deleteEstimate(_ estimate: Estimate, userId: String) async throws {
        let estimateRef = db.collection("users")
            .document(userId)
            .collection("estimates")
            .document(estimate.id.uuidString)
        
        try await estimateRef.delete()
    }
    
    // MARK: - Batch Operations
    
    func syncEstimates(_ estimates: [Estimate], userId: String) async throws {
        let batch = db.batch()
        
        for estimate in estimates {
            let estimateRef = db.collection("users")
                .document(userId)
                .collection("estimates")
                .document(estimate.id.uuidString)
            
            try batch.setData(from: estimate, forDocument: estimateRef)
        }
        
        try await batch.commit()
    }
}

