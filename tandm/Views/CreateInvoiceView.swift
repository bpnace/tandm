import SwiftUI
import FirebaseFirestore

struct CreateInvoiceView: View {
    // Passed from the presenting view (e.g., CollectiveDetailView)
    @ObservedObject var invoiceViewModel: InvoiceViewModel
    // Inject AuthViewModel to get current user ID
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    // Environment property to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    
    // State variables for the form inputs
    @State private var projectIdInput: String = ""
    // Initialize with one default line item, trying to use current user ID
    @State private var lineItems: [InvoiceLineItem]
    @State private var dueDate: Date = Date() // Default to today
    
    // Formatter for Decimal input
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency // Use currency style
        // Adjust locale and currency symbol as needed
        formatter.locale = Locale.current 
        //formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    // Initializer to set up initial line item with user ID
    init(invoiceViewModel: InvoiceViewModel) {
        self._invoiceViewModel = ObservedObject(wrappedValue: invoiceViewModel)
        // Note: Cannot access @EnvironmentObject during init. 
        // We will adjust the first item in .onAppear or rely on addLineItem.
        // For simplicity, let's initialize empty and add the first in onAppear.
        self._lineItems = State(initialValue: []) 
    }
    
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
                                // Use formatter for Decimal TextField
                                TextField("Amount", value: $item.amount, formatter: currencyFormatter)
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
        .onAppear {
            // Add the initial line item here, now that authViewModel is available
            if lineItems.isEmpty {
                 addLineItem() 
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
        // Use current user ID if available
        let currentUserId = authViewModel.authUser?.uid ?? ""
        // Initialize amount with Decimal(0)
        lineItems.append(InvoiceLineItem(description: "", amount: Decimal(0), freelancerId: currentUserId))
    }
    
    private func deleteLineItem(at offsets: IndexSet) {
        lineItems.remove(atOffsets: offsets)
    }
}

// Preview Provider (requires a mock ViewModel AND AuthViewModel)
#Preview {
    // Need a Collective ID for the preview InvoiceViewModel
    let mockCollectiveId = "preview_coll_123"
    let mockInvoiceViewModel = InvoiceViewModel(collectiveId: mockCollectiveId)
    let mockAuthViewModel = AuthenticationViewModel()
    // You could simulate a logged-in user for preview:
    // mockAuthViewModel.authUser = ... 
    
    CreateInvoiceView(invoiceViewModel: mockInvoiceViewModel)
        .environmentObject(mockAuthViewModel) // Provide AuthViewModel
} 