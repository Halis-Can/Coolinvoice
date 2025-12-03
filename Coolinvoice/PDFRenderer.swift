//
//  PDFRenderer.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import Foundation
import PDFKit
import UIKit

class PDFRenderer {
    // A4 size in points (72 points = 1 inch)
    let a4Width: CGFloat = 595.2  // 8.27 inches
    let a4Height: CGFloat = 841.8 // 11.69 inches
    let pageMargin: CGFloat = 40
    
    func createInvoicePDF(invoice: Invoice, business: Business) -> PDFDocument {
        let pdfMetaData = [
            kCGPDFContextCreator: "CoolInvoice",
            kCGPDFContextAuthor: business.name.isEmpty ? "Business" : business.name,
            kCGPDFContextTitle: invoice.invoiceNumber
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: a4Width, height: a4Height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = pageMargin
            
            // Logo and Business Info (left side) and Invoice Info (right side)
            let businessInfoHeight = drawLogoAndBusinessInfoWithInvoiceInfo(
                context: context,
                business: business,
                invoice: invoice,
                yPosition: yPosition
            )
            yPosition = businessInfoHeight
            
            yPosition += 20
            
            // Invoice Header
            yPosition = drawInvoiceHeader(
                context: context,
                invoice: invoice,
                yPosition: yPosition
            )
            
            yPosition += 20
            
            // Items Table
            yPosition = drawInvoiceItems(
                context: context,
                invoice: invoice,
                yPosition: yPosition
            )
            
            yPosition += 20
            
            // Totals
            yPosition = drawTotals(
                context: context,
                invoice: invoice,
                yPosition: yPosition
            )
            
            yPosition += 20
            
            // Notes
            if !invoice.notes.isEmpty {
                drawNotes(
                    context: context,
                    notes: invoice.notes,
                    yPosition: yPosition
                )
            }
        }
        
        return PDFDocument(data: data) ?? PDFDocument()
    }
    
    func createEstimatePDF(estimate: Estimate, business: Business) -> PDFDocument {
        let pdfMetaData = [
            kCGPDFContextCreator: "CoolInvoice",
            kCGPDFContextAuthor: business.name.isEmpty ? "Business" : business.name,
            kCGPDFContextTitle: estimate.estimateNumber
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: a4Width, height: a4Height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = pageMargin
            
            // Logo and Business Info (left side) and Estimate Info (right side)
            let businessInfoHeight = drawLogoAndBusinessInfoWithEstimateInfo(
                context: context,
                business: business,
                estimate: estimate,
                yPosition: yPosition
            )
            yPosition = businessInfoHeight
            
            yPosition += 20
            
            // Estimate Header
            yPosition = drawEstimateHeader(
                context: context,
                estimate: estimate,
                yPosition: yPosition
            )
            
            yPosition += 20
            
            // Items Table
            yPosition = drawEstimateItems(
                context: context,
                estimate: estimate,
                yPosition: yPosition
            )
            
            yPosition += 30 // Increased spacing before totals
            
            // Totals
            yPosition = drawEstimateTotals(
                context: context,
                estimate: estimate,
                yPosition: yPosition
            )
            
            yPosition += 20
            
            // Notes
            if !estimate.notes.isEmpty {
                drawNotes(
                    context: context,
                    notes: estimate.notes,
                    yPosition: yPosition
                )
            }
        }
        
        return PDFDocument(data: data) ?? PDFDocument()
    }
    
    // MARK: - Drawing Helper Methods
    
    private func drawLogoAndBusinessInfoWithEstimateInfo(context: UIGraphicsPDFRendererContext, business: Business, estimate: Estimate, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        let rightBoxWidth: CGFloat = 200
        let rightBoxX = a4Width - pageMargin - rightBoxWidth
        
        // Draw Logo (if available)
        if let logoData = business.logoImageData,
           let logoImage = UIImage(data: logoData) {
            let logoSize: CGFloat = 80
            let logoRect = CGRect(x: pageMargin, y: currentY, width: logoSize, height: logoSize)
            logoImage.draw(in: logoRect)
            currentY += logoSize + 10
        }
        
        // Draw Business Name
        if !business.name.isEmpty {
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let nameRect = CGRect(x: pageMargin, y: currentY, width: contentWidth - rightBoxWidth - 20, height: 18)
            business.name.draw(in: nameRect, withAttributes: nameAttributes)
        }
        
        // Draw Estimate Info Box on the right side (with client info and dates)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let dateText = "Date: \(dateFormatter.string(from: estimate.date))"
        let expiryText = "Expiry: \(dateFormatter.string(from: estimate.expiryDate))"
        let estimateNumberText = "Estimate #: \(estimate.estimateNumber)"
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.gray
        ]
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        
        // Calculate box height
        var boxHeight: CGFloat = 20 // Padding
        boxHeight += 15 // "Estimate For:" label
        boxHeight += 18 // Client Name
        if !estimate.clientAddress.isEmpty {
            boxHeight += 30 // Address (multi-line)
        }
        if !estimate.clientPhone.isEmpty {
            boxHeight += 15 // Phone
        }
        if !estimate.clientEmail.isEmpty {
            boxHeight += 15 // Email
        }
        boxHeight += 10 // Spacing before dates
        boxHeight += 15 // Date
        boxHeight += 15 // Expiry
        boxHeight += 15 // Estimate Number
        
        // Draw gray background box
        let boxRect = CGRect(x: rightBoxX, y: yPosition, width: rightBoxWidth, height: boxHeight)
        UIColor.systemGray6.setFill()
        context.fill(boxRect)
        
        var rightBoxY = yPosition + 10
        
        // Draw "Estimate For:" label
        "Estimate For:".draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: labelAttributes)
        rightBoxY += 18
        
        // Draw client name
        estimate.clientName.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 18), withAttributes: nameAttributes)
        rightBoxY += 18
        
        // Draw client address
        if !estimate.clientAddress.isEmpty {
            let addressAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            estimate.clientAddress.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 30), withAttributes: addressAttributes)
            rightBoxY += 30
        }
        
        // Draw client phone
        if !estimate.clientPhone.isEmpty {
            let phoneText = "Phone: \(estimate.clientPhone)"
            phoneText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
            rightBoxY += 15
        }
        
        // Draw client email
        if !estimate.clientEmail.isEmpty {
            let emailText = "Email: \(estimate.clientEmail)"
            emailText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
            rightBoxY += 15
        }
        
        rightBoxY += 10 // Spacing before dates
        
        // Draw Date
        dateText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
        rightBoxY += 15
        
        // Draw Expiry Date
        expiryText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
        rightBoxY += 15
        
        // Draw Estimate Number
        estimateNumberText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
        
        // Continue with business info on left
        if !business.name.isEmpty {
            currentY += 18
        }
        
        // Draw Business Address
        if !business.address.isEmpty {
            let addressAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let addressRect = CGRect(x: pageMargin, y: currentY, width: contentWidth - rightBoxWidth - 20, height: 40)
            business.address.draw(in: addressRect, withAttributes: addressAttributes)
            currentY += 40
        }
        
        // Draw License Number
        if !business.licenseNumber.isEmpty {
            let licenseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let licenseText = "License: \(business.licenseNumber)"
            let licenseRect = CGRect(x: pageMargin, y: currentY, width: contentWidth - rightBoxWidth - 20, height: 15)
            licenseText.draw(in: licenseRect, withAttributes: licenseAttributes)
            currentY += 15
        }
        
        // Return the maximum height (business info or estimate info box)
        return max(currentY, yPosition + boxHeight)
    }
    
    private func drawLogoAndBusinessInfoWithInvoiceInfo(context: UIGraphicsPDFRendererContext, business: Business, invoice: Invoice, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        let rightBoxWidth: CGFloat = 200
        let rightBoxX = a4Width - pageMargin - rightBoxWidth
        
        // Draw Logo (if available)
        if let logoData = business.logoImageData,
           let logoImage = UIImage(data: logoData) {
            let logoSize: CGFloat = 80
            let logoRect = CGRect(x: pageMargin, y: currentY, width: logoSize, height: logoSize)
            logoImage.draw(in: logoRect)
            currentY += logoSize + 10
        }
        
        // Draw Business Name
        if !business.name.isEmpty {
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let nameRect = CGRect(x: pageMargin, y: currentY, width: contentWidth - rightBoxWidth - 20, height: 18)
            business.name.draw(in: nameRect, withAttributes: nameAttributes)
        }
        
        // Draw Invoice Info Box on the right side (with client info and dates)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let dateText = "Date: \(dateFormatter.string(from: invoice.date))"
        let dueDateText = "Due Date: \(dateFormatter.string(from: invoice.dueDate))"
        let invoiceNumberText = "Invoice #: \(invoice.invoiceNumber)"
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.gray
        ]
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        
        // Calculate box height
        var boxHeight: CGFloat = 20 // Padding
        boxHeight += 15 // "Bill To:" label
        boxHeight += 18 // Client Name
        if !invoice.clientAddress.isEmpty {
            boxHeight += 30 // Address (multi-line)
        }
        if !invoice.clientPhone.isEmpty {
            boxHeight += 15 // Phone
        }
        if !invoice.clientEmail.isEmpty {
            boxHeight += 15 // Email
        }
        boxHeight += 10 // Spacing before dates
        boxHeight += 15 // Date
        boxHeight += 15 // Due Date
        boxHeight += 15 // Invoice Number
        
        // Draw gray background box
        let boxRect = CGRect(x: rightBoxX, y: yPosition, width: rightBoxWidth, height: boxHeight)
        UIColor.systemGray6.setFill()
        context.fill(boxRect)
        
        var rightBoxY = yPosition + 10
        
        // Draw "Bill To:" label
        "Bill To:".draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: labelAttributes)
        rightBoxY += 18
        
        // Draw client name
        invoice.clientName.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 18), withAttributes: nameAttributes)
        rightBoxY += 18
        
        // Draw client address
        if !invoice.clientAddress.isEmpty {
            let addressAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            invoice.clientAddress.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 30), withAttributes: addressAttributes)
            rightBoxY += 30
        }
        
        // Draw client phone
        if !invoice.clientPhone.isEmpty {
            let phoneText = "Phone: \(invoice.clientPhone)"
            phoneText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
            rightBoxY += 15
        }
        
        // Draw client email
        if !invoice.clientEmail.isEmpty {
            let emailText = "Email: \(invoice.clientEmail)"
            emailText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
            rightBoxY += 15
        }
        
        rightBoxY += 10 // Spacing before dates
        
        // Draw Date
        dateText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
        rightBoxY += 15
        
        // Draw Due Date
        dueDateText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
        rightBoxY += 15
        
        // Draw Invoice Number
        invoiceNumberText.draw(in: CGRect(x: rightBoxX + 10, y: rightBoxY, width: rightBoxWidth - 20, height: 15), withAttributes: dateAttributes)
        
        // Continue with business info on left
        if !business.name.isEmpty {
            currentY += 18
        }
        
        // Draw Business Address
        if !business.address.isEmpty {
            let addressAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let addressRect = CGRect(x: pageMargin, y: currentY, width: contentWidth - rightBoxWidth - 20, height: 40)
            business.address.draw(in: addressRect, withAttributes: addressAttributes)
            currentY += 40
        }
        
        // Draw License Number
        if !business.licenseNumber.isEmpty {
            let licenseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let licenseText = "License: \(business.licenseNumber)"
            let licenseRect = CGRect(x: pageMargin, y: currentY, width: contentWidth - rightBoxWidth - 20, height: 15)
            licenseText.draw(in: licenseRect, withAttributes: licenseAttributes)
            currentY += 15
        }
        
        // Return the maximum height (business info or invoice info box)
        return max(currentY, yPosition + boxHeight)
    }
    
    private func drawLogoAndBusinessInfo(context: UIGraphicsPDFRendererContext, business: Business, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        
        // Draw Logo (if available)
        if let logoData = business.logoImageData,
           let logoImage = UIImage(data: logoData) {
            let logoSize: CGFloat = 80
            let logoRect = CGRect(x: pageMargin, y: currentY, width: logoSize, height: logoSize)
            logoImage.draw(in: logoRect)
            currentY += logoSize + 10
        }
        
        // Draw Business Name
        if !business.name.isEmpty {
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let nameRect = CGRect(x: pageMargin, y: currentY, width: contentWidth, height: 18)
            business.name.draw(in: nameRect, withAttributes: nameAttributes)
            currentY += 18
        }
        
        // Draw Business Address
        if !business.address.isEmpty {
            let addressAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let addressRect = CGRect(x: pageMargin, y: currentY, width: contentWidth, height: 40)
            business.address.draw(in: addressRect, withAttributes: addressAttributes)
            currentY += 40
        }
        
        // Draw License Number
        if !business.licenseNumber.isEmpty {
            let licenseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let licenseText = "License: \(business.licenseNumber)"
            let licenseRect = CGRect(x: pageMargin, y: currentY, width: contentWidth, height: 15)
            licenseText.draw(in: licenseRect, withAttributes: licenseAttributes)
            currentY += 15
        }
        
        return currentY
    }
    
    private func drawInvoiceHeader(context: UIGraphicsPDFRendererContext, invoice: Invoice, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        
        // Draw "INVOICE" title - centered and light gray
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 32),
            .foregroundColor: UIColor.lightGray.withAlphaComponent(0.6)
        ]
        let titleText = "INVOICE"
        let titleSize = titleText.size(withAttributes: titleAttributes)
        let titleX = (a4Width - titleSize.width) / 2 // Center horizontally
        let titleRect = CGRect(x: titleX, y: currentY, width: titleSize.width, height: 35)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += 35
        
        return currentY
    }
    
    private func drawEstimateHeader(context: UIGraphicsPDFRendererContext, estimate: Estimate, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        
        // Draw "ESTIMATE" title - centered and light gray
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 32),
            .foregroundColor: UIColor.lightGray.withAlphaComponent(0.6)
        ]
        let titleText = "ESTIMATE"
        let titleSize = titleText.size(withAttributes: titleAttributes)
        let titleX = (a4Width - titleSize.width) / 2 // Center horizontally
        let titleRect = CGRect(x: titleX, y: currentY, width: titleSize.width, height: 35)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += 35
        
        return currentY
    }
    
    private func drawClientInfo(context: UIGraphicsPDFRendererContext, invoice: Invoice, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        var boxHeight: CGFloat = 20 // Start with label height
        
        // Calculate box height based on available fields
        boxHeight += 18 // Name
        if !invoice.clientAddress.isEmpty {
            boxHeight += 30 // Address (multi-line)
        }
        if !invoice.clientPhone.isEmpty {
            boxHeight += 15 // Phone
        }
        if !invoice.clientEmail.isEmpty {
            boxHeight += 15 // Email
        }
        boxHeight += 10 // Padding
        
        // Draw background box
        let boxRect = CGRect(x: pageMargin, y: currentY, width: contentWidth, height: boxHeight)
        UIColor.systemGray6.setFill()
        context.fill(boxRect)
        
        currentY += 10
        
        // Draw "Bill To:" label
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let labelRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 15)
        "Bill To:".draw(in: labelRect, withAttributes: labelAttributes)
        
        currentY += 18
        
        // Draw client name
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        let nameRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 18)
        invoice.clientName.draw(in: nameRect, withAttributes: nameAttributes)
        
        currentY += 18
        
        // Draw client address
        if !invoice.clientAddress.isEmpty {
            let addressAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let addressRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth - 20, height: 30)
            invoice.clientAddress.draw(in: addressRect, withAttributes: addressAttributes)
            currentY += 30
        }
        
        // Draw client phone
        if !invoice.clientPhone.isEmpty {
            let phoneAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let phoneText = "Phone: \(invoice.clientPhone)"
            let phoneRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 15)
            phoneText.draw(in: phoneRect, withAttributes: phoneAttributes)
            currentY += 15
        }
        
        // Draw client email
        if !invoice.clientEmail.isEmpty {
            let emailAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let emailText = "Email: \(invoice.clientEmail)"
            let emailRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 15)
            emailText.draw(in: emailRect, withAttributes: emailAttributes)
            currentY += 15
        }
        
        return yPosition + boxHeight + 10
    }
    
    private func drawClientInfoForEstimate(context: UIGraphicsPDFRendererContext, estimate: Estimate, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        var boxHeight: CGFloat = 20 // Start with label height
        
        // Calculate box height based on available fields
        boxHeight += 18 // Name
        if !estimate.clientAddress.isEmpty {
            boxHeight += 30 // Address (multi-line)
        }
        if !estimate.clientPhone.isEmpty {
            boxHeight += 15 // Phone
        }
        if !estimate.clientEmail.isEmpty {
            boxHeight += 15 // Email
        }
        boxHeight += 10 // Padding
        
        // Draw background box
        let boxRect = CGRect(x: pageMargin, y: currentY, width: contentWidth, height: boxHeight)
        UIColor.systemGray6.setFill()
        context.fill(boxRect)
        
        currentY += 10
        
        // Draw "Estimate For:" label
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let labelRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 15)
        "Estimate For:".draw(in: labelRect, withAttributes: labelAttributes)
        
        currentY += 18
        
        // Draw client name
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        let nameRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 18)
        estimate.clientName.draw(in: nameRect, withAttributes: nameAttributes)
        
        currentY += 18
        
        // Draw client address
        if !estimate.clientAddress.isEmpty {
            let addressAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let addressRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth - 20, height: 30)
            estimate.clientAddress.draw(in: addressRect, withAttributes: addressAttributes)
            currentY += 30
        }
        
        // Draw client phone
        if !estimate.clientPhone.isEmpty {
            let phoneAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let phoneText = "Phone: \(estimate.clientPhone)"
            let phoneRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 15)
            phoneText.draw(in: phoneRect, withAttributes: phoneAttributes)
            currentY += 15
        }
        
        // Draw client email
        if !estimate.clientEmail.isEmpty {
            let emailAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let emailText = "Email: \(estimate.clientEmail)"
            let emailRect = CGRect(x: pageMargin + 10, y: currentY, width: contentWidth, height: 15)
            emailText.draw(in: emailRect, withAttributes: emailAttributes)
            currentY += 15
        }
        
        return yPosition + boxHeight + 10
    }
    
    private func drawInvoiceItems(context: UIGraphicsPDFRendererContext, invoice: Invoice, yPosition: CGFloat) -> CGFloat {
        guard !invoice.items.isEmpty else { return yPosition }
        
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        let rowHeight: CGFloat = 25
        let headerHeight: CGFloat = 30
        
        // Draw table header
        let headerRect = CGRect(x: pageMargin, y: currentY, width: contentWidth, height: headerHeight)
        UIColor.systemGray6.setFill()
        context.fill(headerRect)
        
        currentY += 8
        
        // Header text
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        
        "Description".draw(in: CGRect(x: pageMargin + 5, y: currentY, width: 300, height: 15), withAttributes: headerAttributes)
        "Qty".draw(in: CGRect(x: pageMargin + 310, y: currentY, width: 60, height: 15), withAttributes: headerAttributes)
        "Price".draw(in: CGRect(x: pageMargin + 370, y: currentY, width: 100, height: 15), withAttributes: headerAttributes)
        "Total".draw(in: CGRect(x: pageMargin + 470, y: currentY, width: 100, height: 15), withAttributes: headerAttributes)
        
        currentY = yPosition + headerHeight
        
        // Draw items
        let itemAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "USD"
        
        for (index, item) in invoice.items.enumerated() {
            // Draw divider line before each item (except the first one)
            if index > 0 {
                context.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.move(to: CGPoint(x: pageMargin, y: currentY))
                context.cgContext.addLine(to: CGPoint(x: pageMargin + contentWidth, y: currentY))
                context.cgContext.strokePath()
            }
            
            // Draw item description
            item.description.draw(in: CGRect(x: pageMargin + 5, y: currentY + 5, width: 300, height: 15), withAttributes: itemAttributes)
            
            // Draw quantity
            let qtyText = String(format: "%.1f", item.quantity)
            qtyText.draw(in: CGRect(x: pageMargin + 310, y: currentY + 5, width: 60, height: 15), withAttributes: itemAttributes)
            
            // Draw unit price
            if let priceText = currencyFormatter.string(from: NSNumber(value: item.unitPrice)) {
                priceText.draw(in: CGRect(x: pageMargin + 370, y: currentY + 5, width: 100, height: 15), withAttributes: itemAttributes)
            }
            
            // Draw total
            if let totalText = currencyFormatter.string(from: NSNumber(value: item.total)) {
                totalText.draw(in: CGRect(x: pageMargin + 470, y: currentY + 5, width: 100, height: 15), withAttributes: itemAttributes)
            }
            
            currentY += rowHeight
        }
        
        // Draw divider line after the last item
        if !invoice.items.isEmpty {
            context.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: pageMargin, y: currentY))
            context.cgContext.addLine(to: CGPoint(x: pageMargin + contentWidth, y: currentY))
            context.cgContext.strokePath()
            currentY += rowHeight // Add space after the line
        }
        
        return currentY
    }
    
    private func drawEstimateItems(context: UIGraphicsPDFRendererContext, estimate: Estimate, yPosition: CGFloat) -> CGFloat {
        guard !estimate.items.isEmpty else { return yPosition }
        
        var currentY = yPosition
        let contentWidth = a4Width - (pageMargin * 2)
        let rowHeight: CGFloat = 25
        let headerHeight: CGFloat = 30
        
        // Draw table header
        let headerRect = CGRect(x: pageMargin, y: currentY, width: contentWidth, height: headerHeight)
        UIColor.systemGray6.setFill()
        context.fill(headerRect)
        
        currentY += 8
        
        // Header text
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        
        "Description".draw(in: CGRect(x: pageMargin + 5, y: currentY, width: 300, height: 15), withAttributes: headerAttributes)
        "Qty".draw(in: CGRect(x: pageMargin + 310, y: currentY, width: 60, height: 15), withAttributes: headerAttributes)
        "Price".draw(in: CGRect(x: pageMargin + 370, y: currentY, width: 100, height: 15), withAttributes: headerAttributes)
        "Total".draw(in: CGRect(x: pageMargin + 470, y: currentY, width: 100, height: 15), withAttributes: headerAttributes)
        
        currentY = yPosition + headerHeight
        
        // Draw items
        let itemAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "USD"
        
        for (index, item) in estimate.items.enumerated() {
            // Draw divider line before each item (except the first one)
            if index > 0 {
                context.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.move(to: CGPoint(x: pageMargin, y: currentY))
                context.cgContext.addLine(to: CGPoint(x: pageMargin + contentWidth, y: currentY))
                context.cgContext.strokePath()
            }
            
            // Draw item description
            item.description.draw(in: CGRect(x: pageMargin + 5, y: currentY + 5, width: 300, height: 15), withAttributes: itemAttributes)
            
            // Draw quantity
            let qtyText = String(format: "%.1f", item.quantity)
            qtyText.draw(in: CGRect(x: pageMargin + 310, y: currentY + 5, width: 60, height: 15), withAttributes: itemAttributes)
            
            // Draw unit price
            if let priceText = currencyFormatter.string(from: NSNumber(value: item.unitPrice)) {
                priceText.draw(in: CGRect(x: pageMargin + 370, y: currentY + 5, width: 100, height: 15), withAttributes: itemAttributes)
            }
            
            // Draw total
            if let totalText = currencyFormatter.string(from: NSNumber(value: item.total)) {
                totalText.draw(in: CGRect(x: pageMargin + 470, y: currentY + 5, width: 100, height: 15), withAttributes: itemAttributes)
            }
            
            currentY += rowHeight
        }
        
        // Draw divider line after the last item
        if !estimate.items.isEmpty {
            context.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: pageMargin, y: currentY))
            context.cgContext.addLine(to: CGPoint(x: pageMargin + contentWidth, y: currentY))
            context.cgContext.strokePath()
            currentY += rowHeight // Add space after the line
        }
        
        return currentY
    }
    
    private func drawTotals(context: UIGraphicsPDFRendererContext, invoice: Invoice, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let rightMargin = a4Width - pageMargin - 200
        let lineSpacing: CGFloat = 18
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "USD"
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.gray
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        
        let boldValueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        // Subtotal
        "Subtotal:".draw(in: CGRect(x: rightMargin, y: currentY, width: 100, height: 15), withAttributes: labelAttributes)
        if let subtotalText = currencyFormatter.string(from: NSNumber(value: invoice.amount)) {
            subtotalText.draw(in: CGRect(x: rightMargin + 100, y: currentY, width: 100, height: 15), withAttributes: valueAttributes)
        }
        currentY += lineSpacing
        
        // Tax
        "Tax:".draw(in: CGRect(x: rightMargin, y: currentY, width: 100, height: 15), withAttributes: labelAttributes)
        if let taxText = currencyFormatter.string(from: NSNumber(value: invoice.tax)) {
            taxText.draw(in: CGRect(x: rightMargin + 100, y: currentY, width: 100, height: 15), withAttributes: valueAttributes)
        }
        currentY += lineSpacing + 5
        
        // Total
        "Total:".draw(in: CGRect(x: rightMargin, y: currentY, width: 100, height: 18), withAttributes: boldValueAttributes)
        if let totalText = currencyFormatter.string(from: NSNumber(value: invoice.total)) {
            totalText.draw(in: CGRect(x: rightMargin + 100, y: currentY, width: 100, height: 18), withAttributes: boldValueAttributes)
        }
        
        return currentY + 25
    }
    
    private func drawEstimateTotals(context: UIGraphicsPDFRendererContext, estimate: Estimate, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let rightMargin = a4Width - pageMargin - 200
        let lineSpacing: CGFloat = 18
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "USD"
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.gray
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        
        let boldValueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        // Subtotal
        "Subtotal:".draw(in: CGRect(x: rightMargin, y: currentY, width: 100, height: 15), withAttributes: labelAttributes)
        if let subtotalText = currencyFormatter.string(from: NSNumber(value: estimate.amount)) {
            subtotalText.draw(in: CGRect(x: rightMargin + 100, y: currentY, width: 100, height: 15), withAttributes: valueAttributes)
        }
        currentY += lineSpacing
        
        // Tax
        "Tax:".draw(in: CGRect(x: rightMargin, y: currentY, width: 100, height: 15), withAttributes: labelAttributes)
        if let taxText = currencyFormatter.string(from: NSNumber(value: estimate.tax)) {
            taxText.draw(in: CGRect(x: rightMargin + 100, y: currentY, width: 100, height: 15), withAttributes: valueAttributes)
        }
        currentY += lineSpacing + 5
        
        // Total
        "Total:".draw(in: CGRect(x: rightMargin, y: currentY, width: 100, height: 18), withAttributes: boldValueAttributes)
        if let totalText = currencyFormatter.string(from: NSNumber(value: estimate.total)) {
            totalText.draw(in: CGRect(x: rightMargin + 100, y: currentY, width: 100, height: 18), withAttributes: boldValueAttributes)
        }
        
        return currentY + 25
    }
    
    private func drawNotes(context: UIGraphicsPDFRendererContext, notes: String, yPosition: CGFloat) {
        let contentWidth = a4Width - (pageMargin * 2)
        let boxHeight: CGFloat = 60
        
        // Draw background box
        let boxRect = CGRect(x: pageMargin, y: yPosition, width: contentWidth, height: boxHeight)
        UIColor.systemGray6.setFill()
        context.fill(boxRect)
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        
        let notesAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        
        "Notes:".draw(in: CGRect(x: pageMargin + 10, y: yPosition + 10, width: contentWidth, height: 15), withAttributes: labelAttributes)
        notes.draw(in: CGRect(x: pageMargin + 10, y: yPosition + 25, width: contentWidth - 20, height: 30), withAttributes: notesAttributes)
    }
}

