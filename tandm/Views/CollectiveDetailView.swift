import SwiftUI

struct CollectiveDetailView: View {
    let collective: Collective
    @EnvironmentObject var collectiveViewModel: CollectiveViewModel // For invites
    @StateObject private var projectViewModel = ProjectViewModel()  // For projects
    
    @State private var showingInviteSheet = false
    @State private var showingCreateProjectSheet = false

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
             // Present the actual CreateProjectView
             CreateProjectView(
                collectiveId: collective.id ?? "", // Pass the collective ID
                projectViewModel: projectViewModel // Pass the view model instance
             )
        }
        .onAppear {
            Task { // Revert back to Task for async operation
                await projectViewModel.fetchProjects(for: collective.id ?? "")
            }
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