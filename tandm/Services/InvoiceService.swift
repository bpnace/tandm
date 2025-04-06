import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum InvoiceServiceError: Error {
    case firestoreError(Error)
    case decodingError(Error)
    case calculationError(String) // For errors like calculating total
    // Add other specific invoice errors as needed
}

class InvoiceService {
    
    private let db = Firestore.firestore()
    private var invoicesCollectionRef: CollectionReference {
        return db.collection("invoices")
    }
    
    // MARK: - Fetch Invoices for Collective
    func fetchInvoices(forCollectiveID collectiveID: String) async throws -> [Invoice] {
        print("Fetching invoices for collectiveID: \(collectiveID)")
        do {
            let querySnapshot = try await invoicesCollectionRef
                                        .whereField("collectiveId", isEqualTo: collectiveID)
                                        // Optionally order by dueDate or createdAt
                                        .order(by: "createdAt", descending: true)
                                        .getDocuments()
            
            let invoices = try querySnapshot.documents.compactMap { document -> Invoice? in
                do {
                    return try document.data(as: Invoice.self)
                } catch {
                    print("Error decoding invoice document \(document.documentID): \(error)")
                    return nil // Skip documents that fail to decode
                }
            }
            
            print("Fetched \(invoices.count) invoices for collective \(collectiveID).")
            return invoices
        } catch {
            print("Error fetching invoices for collective \(collectiveID): \(error)")
            throw InvoiceServiceError.firestoreError(error)
        }
    }
    
    // MARK: - Create Invoice
    func createInvoice(projectId: String, collectiveId: String, lineItems: [InvoiceLineItem], dueDate: Date) async throws -> Invoice {
        guard !lineItems.isEmpty else {
            throw InvoiceServiceError.calculationError("Invoice must have at least one line item.")
        }
        
        // Calculate total - ensure amounts are non-negative
        let total = lineItems.reduce(0.0) { sum, item in
            return sum + max(0, item.amount) // Ensure amounts aren't negative
        }
        
        let invoice = Invoice(
            projectId: projectId,
            collectiveId: collectiveId,
            lineItems: lineItems,
            total: total,
            status: .draft, // Default status
            dueDate: Timestamp(date: dueDate)
            // createdAt will be set by Firestore @ServerTimestamp
        )
        
        do {
            let documentRef = try await invoicesCollectionRef.addDocument(from: invoice)
            print("Invoice created successfully with ID: \(documentRef.documentID) for project \(projectId)")
            
            // Fetch the created invoice to return it with the ID and server timestamp
            let createdDoc = try await documentRef.getDocument()
            let createdInvoice = try createdDoc.data(as: Invoice.self)
            return createdInvoice
        } catch let error as EncodingError {
            print("Error encoding invoice data for project \(projectId): \(error)")
            throw InvoiceServiceError.decodingError(error) // Reusing for encoding errors
        } catch {
            print("Error creating invoice for project \(projectId): \(error)")
            throw InvoiceServiceError.firestoreError(error)
        }
    }
    
    // MARK: - Update Invoice Status
    // func updateInvoiceStatus(...) async throws { ... }

    // MARK: - Delete Invoice (If needed)
    // func deleteInvoice(...) async throws { ... }

} 