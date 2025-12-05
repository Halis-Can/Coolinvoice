//
//  BusinessProfileView.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI
import PhotosUI

struct BusinessProfileView: View {
    @StateObject private var businessManager = BusinessManager.shared
    @State private var businessName: String = ""
    @State private var businessAddress: String = ""
    @State private var businessPhoneNumber: String = ""
    @State private var licenseNumber: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingLogoutAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            // Logo Section
            Section {
                VStack(spacing: 16) {
                    if let logoImage = businessManager.business.logoImage {
                        logoImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 150, height: 150)
                            .overlay {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                            }
                    }
                    
                    HStack(spacing: 12) {
                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label("Upload Logo", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        if businessManager.business.logoImageData != nil {
                            Button {
                                businessManager.removeLogo()
                            } label: {
                                Label("Remove", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text("Logo will appear on the top left of your invoices")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } header: {
                Text("Business Logo")
            } footer: {
                Text("Upload your business logo. It will appear on all your invoices.")
            }
            
            // Business Information Section
            Section {
                TextField("Business Name", text: $businessName)
                    .textContentType(.organizationName)
                    .autocapitalization(.words)
                
                TextField("Business Address", text: $businessAddress, axis: .vertical)
                    .lineLimit(3...10)
                    .textContentType(.fullStreetAddress)
                    .autocapitalization(.words)
                
                TextField("Phone Number", text: $businessPhoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .onChange(of: businessPhoneNumber) { oldValue, newValue in
                        let formatted = PhoneNumberFormatter.formatPhoneNumber(newValue)
                        if formatted != newValue {
                            businessPhoneNumber = formatted
                        }
                    }
                
                TextField("License Number", text: $licenseNumber)
                    .textContentType(.none)
                    .autocapitalization(.allCharacters)
            } header: {
                Text("Business Information")
            } footer: {
                Text("This information will appear on all your invoices below the logo.")
            }
        }
        .navigationTitle("Business Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveBusinessInfo()
                }
                .disabled(!isFormValid)
            }
        }
        .onAppear {
            loadBusinessInfo()
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                await loadPhoto(from: newValue)
            }
        }
    }
    
    private var isFormValid: Bool {
        !businessName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func loadBusinessInfo() {
        businessName = businessManager.business.name
        businessAddress = businessManager.business.address
        businessPhoneNumber = businessManager.business.phoneNumber
        licenseNumber = businessManager.business.licenseNumber
    }
    
    private func saveBusinessInfo() {
        businessManager.business.name = businessName.trimmingCharacters(in: .whitespaces)
        businessManager.business.address = businessAddress.trimmingCharacters(in: .whitespaces)
        businessManager.business.phoneNumber = businessPhoneNumber.trimmingCharacters(in: .whitespaces)
        businessManager.business.licenseNumber = licenseNumber.trimmingCharacters(in: .whitespaces)
        dismiss()
    }
    
    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        if let data = try? await item.loadTransferable(type: Data.self) {
            await MainActor.run {
                businessManager.updateLogo(data)
            }
        }
    }
}

// MARK: - Logout View

struct LogoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.right.square.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("Sign Out")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Are you sure you want to sign out?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(role: .destructive) {
                showingAlert = true
            } label: {
                Text("Sign Out")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.primary)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Out")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Signed Out", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("You have been signed out successfully.")
        }
    }
}

#Preview {
    NavigationStack {
        BusinessProfileView()
    }
}

