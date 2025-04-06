import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Represents the status of an invoice
enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case draft = "Draft"
    case sent = "Sent"
    case paid = "Paid"
    case overdue = "Overdue"
    case void = "Void" // Added void status
    
    var id: String { self.rawValue }
}

// Represents a single line item within an invoice
struct InvoiceLineItem: Codable, Identifiable, Hashable {
    var id = UUID() // Local identifier for list iteration
    var description: String
    var amount: Decimal // Using Decimal for precision
    var freelancerId: String // UID of the freelancer this item applies to
    
    // Conform to Hashable for ForEach loops if needed
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: InvoiceLineItem, rhs: InvoiceLineItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Represents an invoice document in Firestore
struct Invoice: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var projectId: String
    var collectiveId: String
    var lineItems: [InvoiceLineItem]
    var total: Decimal // Calculated from line items, store for easy access
    var status: InvoiceStatus = .draft
    var dueDate: Timestamp
    @ServerTimestamp var createdAt: Timestamp? // Auto-set by Firestore
    var sentAt: Timestamp? // Optional timestamp for when the invoice was sent
    var paidAt: Timestamp? // Optional timestamp for when the invoice was paid

    static func == (lhs: Invoice, rhs: Invoice) -> Bool {
        lhs.id == rhs.id
    }
} 