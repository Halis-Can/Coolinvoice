//
//  FirebaseClientService.swift
//  Cullinvoice
//
//  Created for Firebase integration
//

import Foundation
import Combine
import FirebaseFirestore

class FirebaseClientService: ObservableObject {
    static let shared = FirebaseClientService()
    
    @Published var clients: [Client] = []
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
            .collection("clients")
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.clients = []
                        return
                    }
                    
                    self.clients = documents.compactMap { document in
                        try? document.data(as: Client.self)
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - CRUD Operations
    
    func addClient(_ client: Client, userId: String) async throws {
        let clientRef = db.collection("users")
            .document(userId)
            .collection("clients")
            .document(client.id.uuidString)
        
        try clientRef.setData(from: client)
    }
    
    func updateClient(_ client: Client, userId: String) async throws {
        let clientRef = db.collection("users")
            .document(userId)
            .collection("clients")
            .document(client.id.uuidString)
        
        try clientRef.setData(from: client, merge: true)
    }
    
    func deleteClient(_ client: Client, userId: String) async throws {
        let clientRef = db.collection("users")
            .document(userId)
            .collection("clients")
            .document(client.id.uuidString)
        
        try await clientRef.delete()
    }
}

