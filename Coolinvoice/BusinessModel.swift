//
//  BusinessModel.swift
//  Coolinvoice
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
    var licenseNumber: String
    var logoImageData: Data?
    
    init(
        name: String = "",
        address: String = "",
        licenseNumber: String = "",
        logoImageData: Data? = nil
    ) {
        self.name = name
        self.address = address
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
            saveBusiness()
        }
    }
    
    private let businessKey = "savedBusiness"
    
    private init() {
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
    }
    
    private func saveBusiness() {
        if let encoded = try? JSONEncoder().encode(business) {
            UserDefaults.standard.set(encoded, forKey: businessKey)
        }
    }
    
    func updateLogo(_ imageData: Data) {
        business.logoImageData = imageData
    }
    
    func removeLogo() {
        business.logoImageData = nil
    }
}

