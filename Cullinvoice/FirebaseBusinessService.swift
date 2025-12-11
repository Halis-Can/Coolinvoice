//
//  FirebaseBusinessService.swift
//  Cullinvoice
//
//  Created for Firebase integration
//

import Foundation
import Combine
import FirebaseFirestore

class FirebaseBusinessService: ObservableObject {
    static let shared = FirebaseBusinessService()
    
    @Published var business: Business?
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
            .collection("settings")
            .document("business")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    if let document = snapshot, document.exists {
                        self.business = try? document.data(as: Business.self)
                    } else {
                        // Create default business if doesn't exist
                        let defaultBusiness = Business()
                        self.business = defaultBusiness
                        Task {
                            try? await self.saveBusiness(defaultBusiness, userId: userId)
                        }
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - CRUD Operations
    
    func saveBusiness(_ business: Business, userId: String) async throws {
        let businessRef = db.collection("users")
            .document(userId)
            .collection("settings")
            .document("business")
        
        try businessRef.setData(from: business, merge: true)
    }
}

