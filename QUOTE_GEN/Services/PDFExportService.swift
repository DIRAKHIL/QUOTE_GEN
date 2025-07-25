//
//  PDFExportService.swift
//  QUOTE_GEN
//
//  Professional PDF export service for Telugu event quotations
//

import Foundation
import AppKit
import PDFKit

class PDFExportService {
    static let shared = PDFExportService()
    
    private init() {}
    
    func showSavePanel(for quotation: Quotation, businessInfo: BusinessInfo) {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Quotation"
        savePanel.nameFieldStringValue = "Quotation_\(quotation.clientName.replacingOccurrences(of: " ", with: "_"))"
        savePanel.allowedContentTypes = [.pdf]
        savePanel.canCreateDirectories = true
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                self.createAndSavePDF(for: quotation, businessInfo: businessInfo, to: url)
                
                // Show in Finder
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }
    
    private func createAndSavePDF(for quotation: Quotation, businessInfo: BusinessInfo, to url: URL) {
        let pageSize = CGSize(width: 595, height: 842) // A4 size in points
        let margin: CGFloat = 50
        
        // Create PDF context
        guard let pdfContext = CGContext(url as CFURL, mediaBox: nil, nil) else { return }
        
        pdfContext.beginPDFPage(nil)
        
        var yPosition: CGFloat = pageSize.height - margin
        
        // Header
        yPosition = drawHeader(in: pdfContext, businessInfo: businessInfo, pageSize: pageSize, yPosition: yPosition)
        
        // Client Information
        yPosition = drawClientInfo(in: pdfContext, quotation: quotation, yPosition: yPosition, margin: margin)
        
        // Services Table
        yPosition = drawServicesTable(in: pdfContext, quotation: quotation, yPosition: yPosition, margin: margin, pageWidth: pageSize.width)
        
        // Totals
        yPosition = drawTotals(in: pdfContext, quotation: quotation, yPosition: yPosition, margin: margin, pageWidth: pageSize.width)
        
        // Footer
        drawFooter(in: pdfContext, businessInfo: businessInfo, pageSize: pageSize, margin: margin)
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
    }
    
    private func drawHeader(in context: CGContext, businessInfo: BusinessInfo, pageSize: CGSize, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        
        // Business name
        let businessNameFont = NSFont.boldSystemFont(ofSize: 24)
        let businessNameAttributes: [NSAttributedString.Key: Any] = [
            .font: businessNameFont,
            .foregroundColor: NSColor.textColor
        ]
        
        let businessNameString = NSAttributedString(string: businessInfo.businessName, attributes: businessNameAttributes)
        let businessNameSize = businessNameString.size()
        businessNameString.draw(at: CGPoint(x: 50, y: currentY - businessNameSize.height))
        currentY -= businessNameSize.height + 10
        
        // Tagline
        let taglineFont = NSFont.systemFont(ofSize: 14)
        let taglineAttributes: [NSAttributedString.Key: Any] = [
            .font: taglineFont,
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        
        let taglineString = NSAttributedString(string: businessInfo.branding.tagline, attributes: taglineAttributes)
        let taglineSize = taglineString.size()
        taglineString.draw(at: CGPoint(x: 50, y: currentY - taglineSize.height))
        currentY -= taglineSize.height + 30
        
        // Quotation title
        let titleFont = NSFont.boldSystemFont(ofSize: 20)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: NSColor.textColor
        ]
        
        let titleString = NSAttributedString(string: "QUOTATION", attributes: titleAttributes)
        let titleSize = titleString.size()
        titleString.draw(at: CGPoint(x: pageSize.width - titleSize.width - 50, y: currentY))
        
        return currentY - 40
    }
    
    private func drawClientInfo(in context: CGContext, quotation: Quotation, yPosition: CGFloat, margin: CGFloat) -> CGFloat {
        var currentY = yPosition
        
        let font = NSFont.systemFont(ofSize: 12)
        let boldFont = NSFont.boldSystemFont(ofSize: 12)
        
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.textColor
        ]
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: NSColor.textColor
        ]
        
        // Client information
        let clientInfo = [
            ("Client Name:", quotation.clientName),
            ("Event Type:", quotation.eventType.rawValue),
            ("Event Date:", DateFormatter.localizedString(from: quotation.eventDate, dateStyle: .long, timeStyle: .none)),
            ("Venue:", quotation.venue),
            ("Quotation Date:", DateFormatter.localizedString(from: quotation.createdDate, dateStyle: .medium, timeStyle: .none))
        ]
        
        for (label, value) in clientInfo {
            if !value.isEmpty {
                let labelString = NSAttributedString(string: label, attributes: boldAttributes)
                let valueString = NSAttributedString(string: " \(value)", attributes: regularAttributes)
                
                labelString.draw(at: CGPoint(x: margin, y: currentY))
                valueString.draw(at: CGPoint(x: margin + labelString.size().width, y: currentY))
                
                currentY -= 20
            }
        }
        
        return currentY - 20
    }
    
    private func drawServicesTable(in context: CGContext, quotation: Quotation, yPosition: CGFloat, margin: CGFloat, pageWidth: CGFloat) -> CGFloat {
        var currentY = yPosition
        
        let headerFont = NSFont.boldSystemFont(ofSize: 12)
        let cellFont = NSFont.systemFont(ofSize: 11)
        
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: NSColor.textColor
        ]
        
        let cellAttributes: [NSAttributedString.Key: Any] = [
            .font: cellFont,
            .foregroundColor: NSColor.textColor
        ]
        
        // Table header
        let tableWidth = pageWidth - (margin * 2)
        let colWidths: [CGFloat] = [tableWidth * 0.1, tableWidth * 0.5, tableWidth * 0.2, tableWidth * 0.2]
        
        // Draw header background
        context.setFillColor(NSColor.controlBackgroundColor.cgColor)
        context.fill(CGRect(x: margin, y: currentY - 25, width: tableWidth, height: 25))
        
        // Header text
        let headers = ["S.No", "Service Description", "Quantity", "Amount (₹)"]
        var xPosition = margin + 10
        
        for (index, header) in headers.enumerated() {
            let headerString = NSAttributedString(string: header, attributes: headerAttributes)
            headerString.draw(at: CGPoint(x: xPosition, y: currentY - 20))
            xPosition += colWidths[index]
        }
        
        currentY -= 35
        
        // Table rows
        for (index, item) in quotation.items.enumerated() {
            // Alternate row background
            if index % 2 == 0 {
                context.setFillColor(NSColor.controlBackgroundColor.withAlphaComponent(0.3).cgColor)
                context.fill(CGRect(x: margin, y: currentY - 20, width: tableWidth, height: 20))
            }
            
            xPosition = margin + 10
            let rowData = [
                "\(index + 1)",
                item.serviceItem.name,
                "\(item.quantity)",
                String(format: "%.2f", item.totalPrice)
            ]
            
            for (colIndex, data) in rowData.enumerated() {
                let cellString = NSAttributedString(string: data, attributes: cellAttributes)
                cellString.draw(at: CGPoint(x: xPosition, y: currentY - 15))
                xPosition += colWidths[colIndex]
            }
            
            currentY -= 25
        }
        
        return currentY - 20
    }
    
    private func drawTotals(in context: CGContext, quotation: Quotation, yPosition: CGFloat, margin: CGFloat, pageWidth: CGFloat) -> CGFloat {
        var currentY = yPosition
        
        let font = NSFont.systemFont(ofSize: 12)
        let boldFont = NSFont.boldSystemFont(ofSize: 14)
        
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.textColor
        ]
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: NSColor.textColor
        ]
        
        let rightAlign = pageWidth - margin - 150
        
        // Subtotal
        let subtotalLabel = NSAttributedString(string: "Subtotal:", attributes: regularAttributes)
        let subtotalValue = NSAttributedString(string: String(format: "₹ %.2f", quotation.subtotal), attributes: regularAttributes)
        
        subtotalLabel.draw(at: CGPoint(x: rightAlign, y: currentY))
        subtotalValue.draw(at: CGPoint(x: rightAlign + 80, y: currentY))
        currentY -= 20
        
        // Tax
        let taxLabel = NSAttributedString(string: "Tax (\(String(format: "%.0f", quotation.taxPercentage))%):", attributes: regularAttributes)
        let taxValue = NSAttributedString(string: String(format: "₹ %.2f", quotation.taxAmount), attributes: regularAttributes)
        
        taxLabel.draw(at: CGPoint(x: rightAlign, y: currentY))
        taxValue.draw(at: CGPoint(x: rightAlign + 80, y: currentY))
        currentY -= 25
        
        // Total
        let totalLabel = NSAttributedString(string: "Total:", attributes: boldAttributes)
        let totalValue = NSAttributedString(string: String(format: "₹ %.2f", quotation.grandTotal), attributes: boldAttributes)
        
        totalLabel.draw(at: CGPoint(x: rightAlign, y: currentY))
        totalValue.draw(at: CGPoint(x: rightAlign + 80, y: currentY))
        
        return currentY - 40
    }
    
    private func drawFooter(in context: CGContext, businessInfo: BusinessInfo, pageSize: CGSize, margin: CGFloat) {
        let font = NSFont.systemFont(ofSize: 10)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        
        let footerText = """
        \(businessInfo.businessName)
        \(businessInfo.address.formatted)
        Phone: \(businessInfo.contactInfo.primaryPhone) | Email: \(businessInfo.contactInfo.email)
        GST: \(businessInfo.taxInfo.gstNumber) | PAN: \(businessInfo.taxInfo.panNumber)
        """
        
        let footerString = NSAttributedString(string: footerText, attributes: attributes)
        footerString.draw(at: CGPoint(x: margin, y: 50))
    }
}