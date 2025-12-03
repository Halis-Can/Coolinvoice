//
//  ActionButton.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(.primary)
            .frame(width: 80, height: 70)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}

#Preview {
    HStack {
        ActionButton(title: "PRINT", icon: "printer.fill") {
            print("Print")
        }
        ActionButton(title: "SEND", icon: "square.and.arrow.up.fill") {
            print("Send")
        }
    }
    .padding()
}

