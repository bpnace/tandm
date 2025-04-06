import Foundation
import Combine

@MainActor // Ensure UI updates happen on the main thread
class InvoiceViewModel: ObservableObject {
    
    @Published var invoices: [Invoice] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let invoiceService = InvoiceService()
    private let collectiveId: String // The ID of the collective whose invoices this VM manages
    
    init(collectiveId: String) {
        self.collectiveId = collectiveId
        print("InvoiceViewModel initialized for collectiveId: \(collectiveId)")
        fetchInvoices()
    }
    
    // MARK: - Fetch Invoices
    func fetchInvoices() {
        print("Attempting to fetch invoices for collective \(collectiveId)...")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.invoices = try await invoiceService.fetchInvoices(forCollectiveID: collectiveId)
                print("Successfully fetched \(self.invoices.count) invoices for collective \(collectiveId).")
            } catch {
                print("Error fetching invoices: \(error)")
                self.errorMessage = "Failed to load invoices: \(error.localizedDescription)"
                self.invoices = [] // Clear invoices on error
            }
            isLoading = false
        }
    }
    
    // MARK: - Create Invoice
    func createInvoice(projectId: String, lineItems: [InvoiceLineItem], dueDate: Date) async {
        // Ensure we have the collectiveId this VM is responsible for
        guard !projectId.isEmpty else {
            errorMessage = "Project ID is required to create an invoice."
            return
        }
        guard !lineItems.isEmpty else {
            errorMessage = "Cannot create an empty invoice."
            return
        }

        print("Attempting to create invoice for project \(projectId) in collective \(collectiveId)...")
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await invoiceService.createInvoice(
                projectId: projectId,
                collectiveId: self.collectiveId, // Use the VM's collectiveId
                lineItems: lineItems,
                dueDate: dueDate
            )
            print("Invoice created successfully for project \(projectId). Refreshing invoices...")
            // Refresh the invoice list after successful creation
            fetchInvoices() 
        } catch {
            print("Error creating invoice: \(error)")
            self.errorMessage = "Failed to create invoice: \(error.localizedDescription)"
            isLoading = false // Ensure loading state is reset on error
        }
    }
    
    // MARK: - Other Actions (Update Status, etc.)
    // Add functions for updating status, etc.
    
} 