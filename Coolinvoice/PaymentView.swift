//
//  PaymentView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI
import PassKit

struct PaymentView: View {
    @State private var payments: [Payment] = Payment.samplePayments
    @State private var searchText = ""
    @State private var selectedMethod: PaymentMethod?
    @State private var showingNewPayment = false
    @State private var showingApplePay = false
    @State private var showingTapToPay = false
    @State private var selectedInvoice: Invoice?
    @StateObject private var applePayManager = ApplePayManager.shared
    @StateObject private var tapToPayManager = TapToPayManager.shared
    @State private var paymentAmount: Double = 0.0
    
    var filteredPayments: [Payment] {
        var filtered = payments
        
        if !searchText.isEmpty {
            filtered = filtered.filter { payment in
                payment.invoiceNumber.localizedCaseInsensitiveContains(searchText) ||
                payment.clientName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let method = selectedMethod {
            filtered = filtered.filter { $0.method == method }
        }
        
        return filtered
    }
    
    var totalReceived: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Received")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(totalReceived, format: .currency(code: "USD"))
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.green)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Quick Payment Methods
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Payment")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        // Apple Pay Button
                        if applePayManager.canMakePayments {
                            ApplePayButton {
                                showingApplePay = true
                            }
                            .padding(.horizontal)
                        }
                        
                        // Tap to Pay Button
                        if tapToPayManager.isReady {
                            TapToPayButton {
                                showingTapToPay = true
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Payments List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Payments")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if filteredPayments.isEmpty {
                        ContentUnavailableView(
                            "No Payments",
                            systemImage: "creditcard.magnifyingglass",
                            description: Text("No payments match your search")
                        )
                        .frame(height: 200)
                    } else {
                        ForEach(filteredPayments) { payment in
                            PaymentRow(payment: payment)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Payments")
        .searchable(text: $searchText, prompt: "Search payments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewPayment = true
                } label: {
                    Label("New Payment", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Button {
                        selectedMethod = nil
                    } label: {
                        Label("All Methods", systemImage: "list.bullet")
                    }
                    
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Button {
                            selectedMethod = method
                        } label: {
                            Label(method.rawValue, systemImage: paymentMethodIcon(method))
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showingNewPayment) {
            NewPaymentView(
                onSelectInvoice: { invoice in
                    selectedInvoice = invoice
                    paymentAmount = invoice.total
                    showingNewPayment = false
                    showingApplePay = true
                }
            )
        }
        .sheet(isPresented: $showingApplePay) {
            ApplePaySheet(amount: paymentAmount > 0 ? paymentAmount : 100.0)
        }
        .sheet(isPresented: $showingTapToPay) {
            TapToPaySheet()
        }
    }
    
    private func paymentMethodIcon(_ method: PaymentMethod) -> String {
        switch method {
        case .cash:
            return "dollarsign.circle.fill"
        case .check:
            return "checkmark.circle.fill"
        case .bankTransfer:
            return "building.columns.fill"
        case .creditCard:
            return "creditcard.fill"
        case .online:
            return "globe"
        case .applePay:
            return "applelogo"
        case .tapToPay:
            return "waveform.circle.fill"
        }
    }
}

struct PaymentRow: View {
    let payment: Payment
    
    var body: some View {
        HStack(spacing: 16) {
            // Payment method icon
            Image(systemName: paymentMethodIcon(for: payment.method))
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.clientName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(payment.invoiceNumber)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(payment.amount, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(payment.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func paymentMethodIcon(for method: PaymentMethod) -> String {
        switch method {
        case .cash:
            return "dollarsign.circle.fill"
        case .check:
            return "checkmark.circle.fill"
        case .bankTransfer:
            return "building.columns.fill"
        case .creditCard:
            return "creditcard.fill"
        case .online:
            return "globe"
        case .applePay:
            return "applelogo"
        case .tapToPay:
            return "waveform.circle.fill"
        }
    }
}

// MARK: - Apple Pay Button

struct ApplePayButton: UIViewRepresentable {
    let action: () -> Void
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.cornerRadius = 12
        return button
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
    }
}

// MARK: - Tap to Pay Button

struct TapToPayButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .font(.title3)
                Text("Tap to Pay")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Apple Pay Sheet

struct ApplePaySheet: View {
    let amount: Double
    @Environment(\.dismiss) private var dismiss
    @StateObject private var applePayManager = ApplePayManager.shared
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 60))
                        .foregroundStyle(.primary)
                    
                    Text("Apple Pay")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(amount, format: .currency(code: "USD"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                }
                .padding(.vertical, 40)
                
                VStack(spacing: 16) {
                    if applePayManager.canMakePayments {
                        ApplePayButton {
                            processApplePay()
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            Text("Apple Pay is not available")
                                .font(.headline)
                            Text("Please set up Apple Pay in Settings")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Payment Successful", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your payment of \(amount, format: .currency(code: "USD")) was processed successfully.")
            }
        }
    }
    
    private func processApplePay() {
        let request = applePayManager.createPaymentRequest(
            amount: amount,
            description: "Invoice Payment"
        )
        
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = applePayManager
        controller.present { success in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showingSuccess = true
                }
            }
        }
    }
}

// MARK: - Tap to Pay Sheet

struct TapToPaySheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tapToPayManager = TapToPayManager.shared
    @State private var amount: Double = 100.0
    @State private var showingSuccess = false
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .symbolEffect(.pulse)
                    
                    Text("Tap to Pay")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if tapToPayManager.isProcessing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Waiting for card...")
                                .font(.headline)
                            Text("Tap your card or device")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 20)
                    } else {
                        VStack(spacing: 8) {
                            Text("Amount")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(amount, format: .currency(code: "USD"))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.vertical, 40)
                
                if !tapToPayManager.isProcessing {
                    VStack(spacing: 16) {
                        Stepper(
                            "Amount: \(amount, format: .currency(code: "USD"))",
                            value: $amount,
                            in: 1...10000,
                            step: 1
                        )
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            startPayment()
                        } label: {
                            Text("Start Payment")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Tap to Pay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(tapToPayManager.isProcessing)
                }
            }
            .alert("Payment Successful", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                if let transaction = tapToPayManager.lastTransaction {
                    Text("Payment of \(transaction.amount, format: .currency(code: "USD")) was processed successfully.\nReference: \(transaction.reference)")
                }
            }
            .alert("Payment Failed", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text("Payment could not be processed. Please try again.")
            }
        }
    }
    
    private func startPayment() {
        Task {
            let transaction = await tapToPayManager.processPayment(
                amount: amount,
                description: "Invoice Payment"
            )
            
            await MainActor.run {
                if transaction?.status == .success {
                    showingSuccess = true
                } else {
                    showingError = true
                }
            }
        }
    }
}

// MARK: - New Payment View

struct NewPaymentView: View {
    let onSelectInvoice: (Invoice) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var invoices: [Invoice] = Invoice.sampleInvoices
        .filter { $0.status == .active }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(invoices) { invoice in
                    Button {
                        onSelectInvoice(invoice)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(invoice.clientName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(invoice.invoiceNumber)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(invoice.total, format: .currency(code: "USD"))
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Select Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PaymentView()
    }
}

