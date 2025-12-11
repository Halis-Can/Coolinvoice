//
//  FirebaseDataManager.swift
//  Cullinvoice
//
//  Created for Firebase integration - Unified data manager
//

import Foundation
import Combine
import FirebaseAuth

class FirebaseDataManager: ObservableObject {
    static let shared = FirebaseDataManager()
    
    @Published var isInitialized = false
    
    private let authManager = FirebaseAuthManager.shared
    private let invoiceService = FirebaseInvoiceService.shared
    private let estimateService = FirebaseEstimateService.shared
    private let clientService = FirebaseClientService.shared
    private let paymentService = FirebasePaymentService.shared
    private let businessService = FirebaseBusinessService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAuthObserver()
    }
    
    private func setupAuthObserver() {
        authManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated, let userId = self?.authManager.userId {
                    self?.initializeServices(userId: userId)
                } else {
                    self?.stopAllServices()
                }
            }
            .store(in: &cancellables)
    }
    
    func initializeServices(userId: String) {
        invoiceService.startListening(userId: userId)
        estimateService.startListening(userId: userId)
        clientService.startListening(userId: userId)
        paymentService.startListening(userId: userId)
        businessService.startListening(userId: userId)
        
        isInitialized = true
    }
    
    func stopAllServices() {
        invoiceService.stopListening()
        estimateService.stopListening()
        clientService.stopListening()
        paymentService.stopListening()
        businessService.stopListening()
        
        isInitialized = false
    }
    
    // MARK: - Convenience Accessors
    
    var invoices: [Invoice] {
        invoiceService.invoices
    }
    
    var estimates: [Estimate] {
        estimateService.estimates
    }
    
    var clients: [Client] {
        clientService.clients
    }
    
    var payments: [Payment] {
        paymentService.payments
    }
    
    var business: Business? {
        businessService.business
    }
    
    var userId: String? {
        authManager.userId
    }
    
    var isAuthenticated: Bool {
        authManager.isAuthenticated
    }
}

