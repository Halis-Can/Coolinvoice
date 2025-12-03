//
//  EstimateMoreOptionsView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct EstimateMoreOptionsView: View {
    let estimate: Estimate
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        // Edit estimate
                    } label: {
                        Label("Edit Estimate", systemImage: "pencil")
                    }
                    
                    Button {
                        // Duplicate estimate
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        // Delete estimate
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Button {
                        // Convert to invoice
                    } label: {
                        Label("Convert to Invoice", systemImage: "doc.text.fill")
                    }
                    
                    Button {
                        // Mark as approved
                    } label: {
                        Label("Mark as Approved", systemImage: "checkmark.circle")
                    }
                    
                    Button {
                        // Mark as declined
                    } label: {
                        Label("Mark as Declined", systemImage: "xmark.circle")
                    }
                }
            }
            .navigationTitle("More Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EstimateMoreOptionsView(estimate: Estimate.sampleEstimates[0])
}

