import SwiftUI

struct CollectiveDetailView: View {
    let collective: Collective
    @EnvironmentObject var collectiveViewModel: CollectiveViewModel // For invites
    @StateObject private var projectViewModel: ProjectViewModel
    @StateObject private var invoiceViewModel: InvoiceViewModel // <-- Add InvoiceViewModel
    
    @State private var showingInviteSheet = false
    @State private var showingCreateProjectSheet = false
    @State private var showingCreateInvoiceSheet = false // <-- Add state for invoice sheet

    // Updated Initializer
    init(collective: Collective) {
        self.collective = collective
        guard let collectiveId = collective.id else {
            fatalError("CollectiveDetailView initialized without a collective ID.")
        }
        _projectViewModel = StateObject(wrappedValue: ProjectViewModel(collectiveId: collectiveId))
        _invoiceViewModel = StateObject(wrappedValue: InvoiceViewModel(collectiveId: collectiveId)) // <-- Initialize InvoiceViewModel
    }

    var body: some View {
        List { // Use List for sections
            // Section for Collective Info
            Section("Details") {
                Text(collective.name)
                    .font(.largeTitle)
                    .padding(.bottom)
                
                if let clientName = collective.clientFacingName, !clientName.isEmpty {
                    Text("Client Name: \(clientName)")
                        .font(.headline)
                }
                // Maybe add created date, creator info later
            }
            
            // Section for Members
            Section("Members") {
                // Keep member list simple for now
                ForEach(collective.members, id: \.self) { memberUID in
                    Text(memberUID) // Replace with fetched user names later
                        .font(.subheadline)
                }
            }
            
            // Section for Projects
            Section("Projects") {
                if projectViewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = projectViewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if projectViewModel.projects.isEmpty {
                    Text("No projects yet.")
                        .foregroundColor(.secondary)
                    Button("Create First Project") { // Added button for empty state
                        showingCreateProjectSheet = true
                    }
                } else {
                    ForEach(projectViewModel.projects) { project in
                        // Wrap the project display in a NavigationLink
                        NavigationLink(destination: ProjectDetailView(project: project)) {
                            VStack(alignment: .leading) {
                                Text(project.title).font(.headline)
                                Text("Status: \(project.status.rawValue.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Section: Invoices (NEW)
            Section("Invoices") {
                if invoiceViewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = invoiceViewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if invoiceViewModel.invoices.isEmpty {
                    Text("No invoices yet for this collective.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(invoiceViewModel.invoices) { invoice in
                        // Basic Invoice Row Display (Placeholder - refine later)
                        VStack(alignment: .leading) {
                            Text("Invoice for Project: \(invoice.projectId)") // Link to project later?
                                .font(.headline)
                            HStack {
                                Text("Total: $\\(invoice.total, specifier: "%.2f")")
                                Spacer()
                                Text("Status: \(invoice.status.rawValue)")
                            }
                            .font(.subheadline)
                            Text("Due: \(invoice.dueDate.dateValue(), style: .date)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        // Add NavigationLink or sheet presentation later for detail/edit
                    }
                }
                
                // Button to eventually open Create Invoice view
                 Button {
                     // Set state to show Create Invoice sheet/view
                     showingCreateInvoiceSheet = true 
                 } label: {
                     Label("Create New Invoice", systemImage: "plus.circle")
                 }
            }
        }
        .navigationTitle(collective.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { 
            ToolbarItemGroup(placement: .navigationBarTrailing) { // Group buttons
                // Create Project Button
                Button {
                    showingCreateProjectSheet = true
                } label: {
                    Label("Create Project", systemImage: "plus.rectangle.on.folder")
                }
                .disabled(collective.id == nil) // Disable if no collective ID

                // Invite Member Button
                Button {
                    showingInviteSheet = true
                } label: {
                    Label("Invite Member", systemImage: "person.crop.circle.badge.plus")
                }
                .disabled(collective.id == nil)
            }
        }
        .sheet(isPresented: $showingInviteSheet) {
             InviteMemberView(collective: collective)
                 .environmentObject(collectiveViewModel)
        }
        .sheet(isPresented: $showingCreateProjectSheet) {
             CreateProjectView(projectViewModel: projectViewModel)
        }
        .sheet(isPresented: $showingCreateInvoiceSheet) {
            CreateInvoiceView(invoiceViewModel: invoiceViewModel)
        }
        .onAppear {
            Task { // Revert back to Task for async operation
                await projectViewModel.fetchProjects(for: collective.id ?? "")
            }
            print("CollectiveDetailView appeared for \(collective.name)")
        }
    }
}

// Preview needs adjustment for @StateObject and potential async operations
#Preview {
    // Create mock data for preview
    let mockAuth = AuthenticationViewModel()
    let mockCollectiveVM = CollectiveViewModel(authViewModel: mockAuth)
    let mockCollective = Collective(
        id: "mock123",
        name: "Preview Collective",
        members: ["user1", "user2", "user3"],
        clientFacingName: "Client Preview Inc.",
        createdBy: "user1",
        publicPageSlug: "preview-collective"
    )
    
    // Note: Preview won't show real projects unless ProjectViewModel is mocked
    // or provided with sample data during initialization.
    NavigationView {
        CollectiveDetailView(collective: mockCollective)
            .environmentObject(mockCollectiveVM) 
    }
} 