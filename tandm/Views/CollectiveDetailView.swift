import SwiftUI

struct CollectiveDetailView: View {
    let collective: Collective
    @EnvironmentObject var collectiveViewModel: CollectiveViewModel // For invites
    @StateObject private var projectViewModel = ProjectViewModel()  // For projects
    
    // State for Member Details
    @State private var memberDetails: [String: User] = [:]
    @State private var isLoadingMembers = false
    private let userService = UserService() // Instance of UserService
    
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
                if isLoadingMembers {
                    ProgressView()
                } else if collective.members.isEmpty {
                    Text("No members added yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(collective.members, id: \.self) { memberUID in
                        // Display fetched username or UID as fallback
                        Text(memberDetails[memberUID]?.name ?? memberUID)
                            .font(.subheadline)
                    }
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
                    VStack {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 2)
                        Text("No projects yet.")
                            .foregroundColor(.secondary)
                    }
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
            // Fetch projects
            Task {
                await projectViewModel.fetchProjects(for: collective.id ?? "")
            }
            // Fetch member details
            fetchMemberDetails()
        }
    }
    
    // Function to fetch member details
    private func fetchMemberDetails() {
        guard !collective.members.isEmpty else { return }
        isLoadingMembers = true
        Task {
            do {
                let users = try await userService.fetchMultipleUsers(uids: collective.members)
                // Convert array of users to dictionary [UID: User]
                var detailsDict: [String: User] = [:]
                for user in users {
                    if let uid = user.uid { // Use the uid field from the User model
                         detailsDict[uid] = user
                    } else if let id = user.id { // Fallback to document ID if uid field is missing
                         detailsDict[id] = user
                    }
                }
                self.memberDetails = detailsDict
            } catch {
                print("Error fetching member details: \(error)")
                // Handle error display if needed
            }
            isLoadingMembers = false
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