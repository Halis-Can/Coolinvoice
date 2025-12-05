//
//  Models.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation
import SwiftUI

// MARK: - Invoice Model

struct Invoice: Identifiable, Codable, Equatable {
    let id: UUID
    var invoiceNumber: String
    var clientName: String
    var clientPhone: String
    var clientEmail: String
    var clientAddress: String
    var amount: Double
    var tax: Double
    var total: Double {
        amount + tax
    }
    var date: Date
    var dueDate: Date
    var status: InvoiceStatus
    var items: [InvoiceItem]
    var notes: String
    var paymentMethod: PaymentMethod?
    var paidDate: Date?
    var paymentAmount: Double?
    
    var remainingAmount: Double {
        guard let paymentAmount = paymentAmount else {
            return total
        }
        return max(0, total - paymentAmount)
    }
    
    init(
        id: UUID = UUID(),
        invoiceNumber: String,
        clientName: String,
        clientPhone: String = "",
        clientEmail: String = "",
        clientAddress: String = "",
        amount: Double,
        tax: Double = 0.0,
        date: Date = Date(),
        dueDate: Date? = nil,
        status: InvoiceStatus = .active,
        items: [InvoiceItem] = [],
        notes: String = "",
        paymentMethod: PaymentMethod? = nil,
        paidDate: Date? = nil,
        paymentAmount: Double? = nil
    ) {
        self.id = id
        self.invoiceNumber = invoiceNumber
        self.clientName = clientName
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.clientAddress = clientAddress
        self.amount = amount
        self.tax = tax
        self.date = date
        self.dueDate = dueDate ?? Calendar.current.date(byAdding: .day, value: 30, to: date) ?? date
        self.status = status
        self.items = items
        self.notes = notes
        self.paymentMethod = paymentMethod
        self.paidDate = paidDate
        self.paymentAmount = paymentAmount
    }
    
    static func == (lhs: Invoice, rhs: Invoice) -> Bool {
        lhs.id == rhs.id &&
        lhs.invoiceNumber == rhs.invoiceNumber &&
        lhs.clientName == rhs.clientName &&
        lhs.clientPhone == rhs.clientPhone &&
        lhs.clientEmail == rhs.clientEmail &&
        lhs.clientAddress == rhs.clientAddress &&
        lhs.amount == rhs.amount &&
        lhs.tax == rhs.tax &&
        lhs.date == rhs.date &&
        lhs.dueDate == rhs.dueDate &&
        lhs.status == rhs.status &&
        lhs.items == rhs.items &&
        lhs.notes == rhs.notes &&
        lhs.paymentMethod == rhs.paymentMethod &&
        lhs.paidDate == rhs.paidDate &&
        lhs.paymentAmount == rhs.paymentAmount
    }
}

// MARK: - Invoice Item

struct InvoiceItem: Identifiable, Codable, Equatable {
    let id: UUID
    var description: String
    var quantity: Double
    var unitPrice: Double
    var total: Double {
        quantity * unitPrice
    }
    
    init(
        id: UUID = UUID(),
        description: String,
        quantity: Double = 1.0,
        unitPrice: Double
    ) {
        self.id = id
        self.description = description
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

// MARK: - Invoice Status

enum InvoiceStatus: String, Codable, CaseIterable {
    case active = "Active"
    case paid = "Paid"
    
    var color: Color {
        switch self {
        case .active:
            return .blue
        case .paid:
            return .green
        }
    }
    
    var icon: String {
        switch self {
        case .active:
            return "doc.text.fill"
        case .paid:
            return "checkmark.circle.fill"
        }
    }
}

// MARK: - Payment Method

enum PaymentMethod: String, Codable, CaseIterable {
    case cash = "Cash"
    case check = "Check"
    case bankTransfer = "Bank Transfer"
    case creditCard = "Credit Card"
    case online = "Online Payment"
    case applePay = "Apple Pay"
    case tapToPay = "Tap to Pay"
}

// MARK: - Estimate Model

struct Estimate: Identifiable, Codable, Equatable {
    let id: UUID
    var estimateNumber: String
    var clientName: String
    var clientPhone: String
    var clientEmail: String
    var clientAddress: String
    var amount: Double
    var tax: Double
    var total: Double {
        amount + tax
    }
    var date: Date
    var expiryDate: Date
    var status: EstimateStatus
    var items: [InvoiceItem]
    var notes: String
    
    init(
        id: UUID = UUID(),
        estimateNumber: String,
        clientName: String,
        clientPhone: String = "",
        clientEmail: String = "",
        clientAddress: String = "",
        amount: Double,
        tax: Double = 0.0,
        date: Date = Date(),
        expiryDate: Date? = nil,
        status: EstimateStatus = .pending,
        items: [InvoiceItem] = [],
        notes: String = ""
    ) {
        self.id = id
        self.estimateNumber = estimateNumber
        self.clientName = clientName
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.clientAddress = clientAddress
        self.amount = amount
        self.tax = tax
        self.date = date
        self.expiryDate = expiryDate ?? Calendar.current.date(byAdding: .day, value: 30, to: date) ?? date
        self.status = status
        self.items = items
        self.notes = notes
    }
    
    static func == (lhs: Estimate, rhs: Estimate) -> Bool {
        lhs.id == rhs.id &&
        lhs.estimateNumber == rhs.estimateNumber &&
        lhs.clientName == rhs.clientName &&
        lhs.clientPhone == rhs.clientPhone &&
        lhs.clientEmail == rhs.clientEmail &&
        lhs.clientAddress == rhs.clientAddress &&
        lhs.amount == rhs.amount &&
        lhs.tax == rhs.tax &&
        lhs.date == rhs.date &&
        lhs.expiryDate == rhs.expiryDate &&
        lhs.status == rhs.status &&
        lhs.items == rhs.items &&
        lhs.notes == rhs.notes
    }
}

// MARK: - Estimate Status

enum EstimateStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case declined = "Declined"
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .declined:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .approved:
            return "checkmark.circle.fill"
        case .declined:
            return "xmark.circle.fill"
        }
    }
}

// MARK: - Client Model

struct Client: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phone: String
    var company: String
    var address: String
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String = "",
        phone: String = "",
        company: String = "",
        address: String = ""
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.company = company
        self.address = address
    }
}

// MARK: - Payment Model

struct Payment: Identifiable, Codable {
    let id: UUID
    var invoiceNumber: String
    var clientName: String
    var amount: Double
    var method: PaymentMethod
    var date: Date
    var reference: String
    
    init(
        id: UUID = UUID(),
        invoiceNumber: String,
        clientName: String,
        amount: Double,
        method: PaymentMethod,
        date: Date = Date(),
        reference: String = ""
    ) {
        self.id = id
        self.invoiceNumber = invoiceNumber
        self.clientName = clientName
        self.amount = amount
        self.method = method
        self.date = date
        self.reference = reference
    }
}

// MARK: - Sample Data

extension Invoice {
    static let sampleInvoices: [Invoice] = [
        Invoice(
            invoiceNumber: "INV-2025-001",
            clientName: "Acme Corporation",
            clientPhone: "+1 (555) 123-4567",
            clientEmail: "billing@acme.com",
            clientAddress: "123 Business St, New York, NY 10001",
            amount: 12500.00,
            tax: 1125.00,
            date: Date().addingTimeInterval(-86400 * 5),
            dueDate: Date().addingTimeInterval(-86400 * 5 + 86400 * 30),
            status: .paid,
            items: [
                InvoiceItem(description: "Web Development Services", quantity: 40, unitPrice: 250.00),
                InvoiceItem(description: "UI/UX Design", quantity: 20, unitPrice: 125.00)
            ],
            notes: "Thank you for your business!",
            paymentMethod: .bankTransfer,
            paidDate: Date().addingTimeInterval(-86400 * 2)
        ),
        Invoice(
            invoiceNumber: "INV-2025-002",
            clientName: "Tech Solutions Inc",
            clientPhone: "+1 (555) 234-5678",
            clientEmail: "finance@techsolutions.com",
            clientAddress: "456 Tech Ave, San Francisco, CA 94102",
            amount: 8750.50,
            tax: 787.55,
            date: Date().addingTimeInterval(-86400 * 2),
            dueDate: Date().addingTimeInterval(-86400 * 2 + 86400 * 30),
            status: .active,
            items: [
                InvoiceItem(description: "Mobile App Development", quantity: 35, unitPrice: 200.00),
                InvoiceItem(description: "API Integration", quantity: 15, unitPrice: 150.00)
            ],
            notes: "Payment due within 30 days."
        ),
        Invoice(
            invoiceNumber: "INV-2025-003",
            clientName: "Design Studio",
            clientPhone: "+1 (555) 345-6789",
            clientEmail: "hello@designstudio.com",
            clientAddress: "789 Creative Blvd, Los Angeles, CA 90001",
            amount: 3200.00,
            tax: 288.00,
            date: Date().addingTimeInterval(-86400 * 15),
            dueDate: Date().addingTimeInterval(-86400 * 15 + 86400 * 30),
            status: .active,
            items: [
                InvoiceItem(description: "Brand Identity Design", quantity: 1, unitPrice: 2000.00),
                InvoiceItem(description: "Logo Design", quantity: 1, unitPrice: 1200.00)
            ],
            notes: "Please contact us if you have any questions."
        ),
        Invoice(
            invoiceNumber: "INV-2025-004",
            clientName: "Global Enterprises",
            clientPhone: "+1 (555) 456-7890",
            clientEmail: "accounting@globalent.com",
            clientAddress: "321 Corporate Dr, Chicago, IL 60601",
            amount: 15200.75,
            tax: 1368.07,
            date: Date().addingTimeInterval(-86400 * 1),
            dueDate: Date().addingTimeInterval(-86400 * 1 + 86400 * 30),
            status: .active,
            items: [
                InvoiceItem(description: "Enterprise Software Development", quantity: 60, unitPrice: 200.00),
                InvoiceItem(description: "Consulting Services", quantity: 20, unitPrice: 160.00)
            ],
            notes: "Monthly retainer invoice."
        ),
        Invoice(
            invoiceNumber: "INV-2025-005",
            clientName: "Startup Labs",
            clientPhone: "+1 (555) 567-8901",
            clientEmail: "info@startuplabs.com",
            clientAddress: "555 Innovation Way, Austin, TX 78701",
            amount: 4500.00,
            tax: 405.00,
            date: Date(),
            status: .active,
            items: [
                InvoiceItem(description: "MVP Development", quantity: 30, unitPrice: 150.00)
            ],
            notes: "Draft invoice - pending approval."
        )
    ]
}

// MARK: - Sample Data Extensions

extension Estimate {
    static let sampleEstimates: [Estimate] = [
        Estimate(
            estimateNumber: "EST-2025-001",
            clientName: "New Client Corp",
            clientPhone: "+1 (555) 111-2222",
            clientEmail: "contact@newclient.com",
            clientAddress: "100 New Street, Boston, MA 02101",
            amount: 8500.00,
            tax: 765.00,
            date: Date().addingTimeInterval(-86400 * 3),
            expiryDate: Date().addingTimeInterval(-86400 * 3 + 86400 * 30),
            status: .pending,
            items: [
                InvoiceItem(description: "Website Development", quantity: 30, unitPrice: 250.00),
                InvoiceItem(description: "SEO Services", quantity: 10, unitPrice: 100.00)
            ],
            notes: "Valid for 30 days"
        ),
        Estimate(
            estimateNumber: "EST-2025-002",
            clientName: "Small Business LLC",
            clientPhone: "+1 (555) 222-3333",
            clientEmail: "info@smallbiz.com",
            clientAddress: "200 Small Ave, Seattle, WA 98101",
            amount: 3200.00,
            tax: 288.00,
            date: Date().addingTimeInterval(-86400 * 10),
            expiryDate: Date().addingTimeInterval(-86400 * 10 + 86400 * 30),
            status: .approved,
            items: [
                InvoiceItem(description: "Logo Design", quantity: 1, unitPrice: 1500.00),
                InvoiceItem(description: "Brand Guidelines", quantity: 1, unitPrice: 1700.00)
            ]
        ),
        Estimate(
            estimateNumber: "EST-2025-003",
            clientName: "Local Restaurant",
            clientPhone: "+1 (555) 333-4444",
            clientEmail: "owner@localrest.com",
            clientAddress: "300 Main St, Portland, OR 97201",
            amount: 1200.00,
            tax: 108.00,
            date: Date().addingTimeInterval(-86400 * 45),
            expiryDate: Date().addingTimeInterval(-86400 * 45 + 86400 * 30),
            status: .declined,
            items: [
                InvoiceItem(description: "Menu Design", quantity: 1, unitPrice: 1200.00)
            ]
        )
    ]
}

extension Client {
    static let sampleClients: [Client] = [
        Client(
            name: "John Smith",
            email: "john.smith@acme.com",
            phone: "+1 (555) 123-4567",
            company: "Acme Corporation",
            address: "123 Business St, New York, NY 10001"
        ),
        Client(
            name: "Sarah Johnson",
            email: "sarah@techsolutions.com",
            phone: "+1 (555) 234-5678",
            company: "Tech Solutions Inc",
            address: "456 Tech Ave, San Francisco, CA 94102"
        ),
        Client(
            name: "Michael Chen",
            email: "michael@designstudio.com",
            phone: "+1 (555) 345-6789",
            company: "Design Studio",
            address: "789 Creative Blvd, Los Angeles, CA 90001"
        ),
        Client(
            name: "Emily Davis",
            email: "emily@globalent.com",
            phone: "+1 (555) 456-7890",
            company: "Global Enterprises",
            address: "321 Corporate Dr, Chicago, IL 60601"
        ),
        Client(
            name: "David Wilson",
            email: "david@startuplabs.com",
            phone: "+1 (555) 567-8901",
            company: "Startup Labs",
            address: "555 Innovation Way, Austin, TX 78701"
        )
    ]
}

extension Payment {
    static let samplePayments: [Payment] = [
        Payment(
            invoiceNumber: "INV-2025-001",
            clientName: "Acme Corporation",
            amount: 13625.00,
            method: .bankTransfer,
            date: Date().addingTimeInterval(-86400 * 2),
            reference: "TXN-2025-001"
        ),
        Payment(
            invoiceNumber: "INV-2025-002",
            clientName: "Tech Solutions Inc",
            amount: 5000.00,
            method: .creditCard,
            date: Date().addingTimeInterval(-86400 * 5),
            reference: "CC-2025-045"
        ),
        Payment(
            invoiceNumber: "INV-2024-120",
            clientName: "Design Studio",
            amount: 3200.00,
            method: .check,
            date: Date().addingTimeInterval(-86400 * 10),
            reference: "CHK-2025-012"
        ),
        Payment(
            invoiceNumber: "INV-2024-115",
            clientName: "Global Enterprises",
            amount: 8500.00,
            method: .online,
            date: Date().addingTimeInterval(-86400 * 15),
            reference: "ONL-2025-078"
        )
    ]
}

