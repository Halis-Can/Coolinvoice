//
//  ApplePayManager.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation
import PassKit
import Combine

class ApplePayManager: NSObject, ObservableObject {
    static let shared = ApplePayManager()
    
    @Published var canMakePayments: Bool = false
    @Published var paymentStatus: PKPaymentAuthorizationStatus?
    
    override init() {
        super.init()
        checkApplePayAvailability()
    }
    
    func checkApplePayAvailability() {
        canMakePayments = PKPaymentAuthorizationController.canMakePayments()
    }
    
    func canMakePaymentsUsingNetworks() -> Bool {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.cullinvoice" // Replace with your merchant ID
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        return PKPaymentAuthorizationController.canMakePayments(usingNetworks: request.supportedNetworks)
    }
    
    func createPaymentRequest(amount: Double, description: String) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.cullinvoice" // Replace with your merchant ID
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        // Payment summary
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: description, amount: NSDecimalNumber(value: amount))
        ]
        
        return request
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayManager: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Here you would process the payment with your payment processor
        // For now, we'll simulate a successful payment
        
        // In a real app, you would:
        // 1. Send the payment token to your backend
        // 2. Process the payment through your payment gateway
        // 3. Return success or failure
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }
}

