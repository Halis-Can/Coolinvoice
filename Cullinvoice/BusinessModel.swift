//
//  BusinessModel.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - Business Model

struct Business: Codable {
    var name: String
    var address: String
    var phoneNumber: String
    var licenseNumber: String
    var logoImageData: Data?
    
    init(
        name: String = "",
        address: String = "",
        phoneNumber: String = "",
        licenseNumber: String = "",
        logoImageData: Data? = nil
    ) {
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.licenseNumber = licenseNumber
        self.logoImageData = logoImageData
    }
    
    var logoImage: Image? {
        guard let data = logoImageData,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

// MARK: - Business Manager

class BusinessManager: ObservableObject {
    static let shared = BusinessManager()
    
    @Published var business: Business {
        didSet {
            saveBusinessLocally()
            saveBusinessToFirebase()
        }
    }
    
    private let businessKey = "savedBusiness"
    private let businessService = FirebaseBusinessService.shared
    
    private init() {
        // Load from UserDefaults first (for offline support)
        if let data = UserDefaults.standard.data(forKey: businessKey),
           let decoded = try? JSONDecoder().decode(Business.self, from: data) {
            self.business = decoded
        } else {
            self.business = Business(
                name: "Your Business Name",
                address: "123 Business Street, City, State 12345",
                licenseNumber: ""
            )
        }
        
        // Sync with Firebase if available
        if let firebaseBusiness = businessService.business {
            self.business = firebaseBusiness
        }
    }
    
    private func saveBusinessLocally() {
        if let encoded = try? JSONEncoder().encode(business) {
            UserDefaults.standard.set(encoded, forKey: businessKey)
        }
    }
    
    private func saveBusinessToFirebase() {
        if let userId = FirebaseAuthManager.shared.userId {
            Task {
                try? await businessService.saveBusiness(business, userId: userId)
            }
        }
    }
    
    func updateLogo(_ imageData: Data) {
        business.logoImageData = imageData
    }
    
    func removeLogo() {
        business.logoImageData = nil
    }
}

