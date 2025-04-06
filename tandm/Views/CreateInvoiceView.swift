import SwiftUI
import FirebaseFirestore

struct CreateInvoiceView: View {
    // Passed from the presenting view (e.g., CollectiveDetailView)
    @ObservedObject var invoiceViewModel: InvoiceViewModel
    // Environment property to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    
    // State variables for the form inputs
    @State private var projectIdInput: String = ""
    // Initialize with one default line item
    @State private var lineItems: [InvoiceLineItem] = [InvoiceLineItem(description: "", amount: 0.0, freelancerId: "")] 
    @State private var dueDate: Date = Date() // Default to today
    
    // TODO: Fetch current user ID to potentially pre-fill freelancerId
    // @State private var currentUserId: String = "" 
    
    var body: some View {
        NavigationView { // Embed in NavigationView for toolbar
            Form {
                Section("Invoice Details") {
                    TextField("Project ID", text: $projectIdInput)
                        .disableAutocorrection(true)
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section("Line Items") {
                    ForEach($lineItems) { $item in // Use binding ($) for direct modification
                        VStack {
                            TextField("Description", text: $item.description)
                            HStack {
                                TextField("Amount", value: $item.amount, format: .number)
                                    .keyboardType(.decimalPad)
                                TextField("Freelancer ID (Optional)", text: $item.freelancerId)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                            }
                        }
                    }
                    .onDelete(perform: deleteLineItem)
                    
                    Button {
                        addLineItem()
                    } label: {
                        Label("Add Line Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createInvoiceAction()
                    }
                    .disabled(!isFormValid) // Disable if form is not valid
                }
            }
        }
    }
    
    // Computed property for form validation
    private var isFormValid: Bool {
        !projectIdInput.isEmpty && 
        !lineItems.isEmpty && 
        // Ensure at least one line item has a description and a non-zero amount
        lineItems.contains { !$0.description.isEmpty && $0.amount > 0 }
    }

    // Action to create the invoice
    private func createInvoiceAction() {
        guard isFormValid else {
            // Optionally show an error to the user
            print("Form is invalid")
            return
        }
        
        // Filter out empty line items before saving (optional but recommended)
        let validLineItems = lineItems.filter { !$0.description.isEmpty && $0.amount > 0 }
        
        guard !validLineItems.isEmpty else {
             print("No valid line items to save.")
             // Maybe show an alert
             return
        }
        
        print("Calling createInvoice ViewModel function...")
        Task {
            await invoiceViewModel.createInvoice(
                projectId: projectIdInput,
                lineItems: validLineItems,
                dueDate: dueDate
            )
            // Check if there was an error message from the VM
            if invoiceViewModel.errorMessage == nil {
                dismiss() // Dismiss only on success
            }
            // If there was an error, the errorMessage will be displayed in the presenting view 
            // (if that view observes the viewModel's errorMessage)
        }
    }
    
    // Helper functions for line items
    private func addLineItem() {
        lineItems.append(InvoiceLineItem(description: "", amount: 0.0, freelancerId: ""))
    }
    
    private func deleteLineItem(at offsets: IndexSet) {
        lineItems.remove(atOffsets: offsets)
    }
}

// Preview Provider (requires a mock ViewModel)
#Preview {
    // Need a Collective ID for the preview InvoiceViewModel
    let mockCollectiveId = "preview_coll_123"
    let mockInvoiceViewModel = InvoiceViewModel(collectiveId: mockCollectiveId)
    
    // You might want to inject mock data or services into the ViewModel for preview
    
    CreateInvoiceView(invoiceViewModel: mockInvoiceViewModel)
} 