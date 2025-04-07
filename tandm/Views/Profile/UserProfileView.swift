import SwiftUI
import FirebaseFirestore // For Timestamp

struct UserProfileView: View {
    // Use @ObservedObject as the ViewModel instance is passed from the parent
    @ObservedObject var viewModel: UserProfileViewModel
    @ObservedObject var authViewModel: AuthenticationViewModel // Pass AuthViewModel for logout
    
    // Local state for potentially edited values if not binding directly
    @State private var nameInput: String = ""
    @State private var bioInput: String = ""
    @State private var skillsInput: String = "" // Comma-separated skills
    @State private var portfolioUrlInput: String = ""
    
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        NavigationView { // Embed in NavigationView for title and buttons
            Form {
                if viewModel.isLoading {
                    ProgressView("Loading Profile...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let user = viewModel.user {
                    // --- Profile Image Placeholder Section ---
                    Section("Profile Picture") {
                        HStack {
                            Spacer()
                            // Static Placeholder Icon
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        // Comment out or remove the picker button area
                        /*
                        HStack {
                           Spacer()
                           PhotosPicker(...) { ... }
                           Spacer()
                        }
                        */
                    }
                    // --- End Profile Image Placeholder Section ---
                    
                    // Display Section (potentially non-editable fields)
                    Section("Account Info") {
                        Text("Email: \(user.email)") // Non-editable
                        if let createdAt = user.createdAt {
                             Text("Member Since: \(createdAt.dateValue(), style: .date)")
                        }
                    }
                    
                    // Editable Profile Section
                    Section("Edit Profile") {
                        TextField("Name", text: $nameInput)
                        
                        TextField("Portfolio URL (Optional)", text: $portfolioUrlInput)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                        
                        VStack(alignment: .leading) {
                            Text("Bio")
                            TextEditor(text: $bioInput)
                                .frame(height: 100) // Give TextEditor some height
                                .border(Color.gray.opacity(0.2)) // Optional border
                        }
                        
                        TextField("Skills (comma-separated)", text: $skillsInput)
                            .autocapitalization(.none)
                        
                        // TODO: Add Profile Image Picker later
                        Text("Profile Image Upload (Coming Soon)")
                            .foregroundColor(.gray)
                    }
                    
                    // Action Section
                    Section {
                        Button("Save Profile") {
                            saveProfile()
                        }
                        .disabled(viewModel.isLoading) // Disable if already saving
                        
                        Button("Log Out", role: .destructive) {
                            logout()
                        }
                    }
                    
                     // Error Message Display
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        }
                    }
                    
                } else {
                    // Handle case where user is nil and not loading
                    Text("Could not load user profile.")
                    if let errorMessage = viewModel.errorMessage {
                         Text("Error: \(errorMessage)")
                             .foregroundColor(.red)
                    }
                    // Optionally add a button to retry fetching
                    Button("Retry Fetch") {
                        viewModel.fetchUserProfile()
                    }
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("Close") { dismiss() }
                 }
            }
            .onAppear {
                // Populate local state when view appears or user data changes
                populateLocalStateFromViewModel()
            }
            .onChange(of: viewModel.user) { // Use iOS 17+ onChange
                 populateLocalStateFromViewModel()
            }
        }
    }
    
    // Helper to populate local state from ViewModel's user
    private func populateLocalStateFromViewModel() {
        if let user = viewModel.user {
            nameInput = user.name
            bioInput = user.bio ?? ""
            skillsInput = user.skills?.joined(separator: ", ") ?? ""
            portfolioUrlInput = user.portfolioUrl ?? ""
        }
    }
    
    // Action to save profile
    private func saveProfile() {
        guard var updatedUser = viewModel.user else { return } // Get current user data
        
        // Update the user object with local state
        updatedUser.name = nameInput
        updatedUser.bio = bioInput.isEmpty ? nil : bioInput
        updatedUser.portfolioUrl = portfolioUrlInput.isEmpty ? nil : portfolioUrlInput
        // Split skills string into array, trimming whitespace
        updatedUser.skills = skillsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        // Update the ViewModel's user object BEFORE saving
        viewModel.user = updatedUser 
        
        // Call ViewModel save function
        viewModel.saveUserProfile()
        
        // Optionally dismiss after save, or wait for VM confirmation
        // Consider adding feedback to the user (e.g., alert, loading state)
    }
    
    // Action to log out
    private func logout() {
        authViewModel.signOut()
        // Dismiss the profile sheet after logging out
        dismiss()
    }
}

// MARK: - Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock ViewModels for preview
        let mockProfileVM = UserProfileViewModel()
        let mockAuthVM = AuthenticationViewModel()
        
        // Populate mockProfileVM with sample data if needed
        mockProfileVM.user = User(
            uid: "preview_user_123",
            name: "Preview User",
            email: "preview@example.com",
            bio: "This is a bio for the preview.",
            skills: ["SwiftUI", "Firebase", "Testing"],
            portfolioUrl: "https://example.com",
            createdAt: Timestamp(date: Date()))
            
        // Return the view here
        return UserProfileView(viewModel: mockProfileVM, authViewModel: mockAuthVM)
    }
} 