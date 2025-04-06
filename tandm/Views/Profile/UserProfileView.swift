import SwiftUI
import FirebaseFirestore // For Timestamp

struct UserProfileView: View {
    // Use @StateObject to create and manage the ViewModel instance
    @StateObject private var viewModel = UserProfileViewModel()
    
    // State for edit mode, if we want an explicit edit button
    // @State private var isEditing = false 
    // For simplicity, we'll make fields directly editable for now.

    var body: some View {
        NavigationView {
            Form {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let user = viewModel.user {
                    // Display Section (potentially non-editable fields)
                    Section(header: Text("Account Info")) {
                        Text("Email: \(user.email)") // Usually non-editable
                        if let createdAt = user.createdAt {
                             Text("Member Since: \(createdAt.dateValue(), style: .date)")
                        }
                    }
                    
                    // Editable Profile Section
                    Section(header: Text("Profile Details")) {
                        // Use bindings to allow editing directly
                        // Need to handle optionals carefully
                        TextField("Name", text: Binding(
                            get: { viewModel.user?.name ?? "" },
                            set: { viewModel.user?.name = $0 }
                        ))
                        
                        // TextEditor for multi-line bio
                        VStack(alignment: .leading) {
                             Text("Bio").font(.caption).foregroundColor(.gray)
                             TextEditor(text: Binding(
                                 get: { viewModel.user?.bio ?? "" },
                                 set: { viewModel.user?.bio = $0 }
                             ))
                             .frame(height: 100)
                             .border(Color.gray.opacity(0.2))
                        }
                        
                        TextField("Portfolio URL", text: Binding(
                            get: { viewModel.user?.portfolioUrl ?? "" },
                            set: { viewModel.user?.portfolioUrl = $0 }
                        ))
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        
                        // Skills - Simplified as comma-separated string for now
                         VStack(alignment: .leading) {
                             Text("Skills (comma-separated)").font(.caption).foregroundColor(.gray)
                             TextField("", text: Binding(
                                 get: { viewModel.user?.skills?.joined(separator: ", ") ?? "" },
                                 set: { viewModel.user?.skills = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } }
                             ))
                         }
                         
                         // Placeholder for Profile Image URL/Path
                         TextField("Profile Image Path", text: Binding(
                             get: { viewModel.user?.profileImage ?? "" },
                             set: { viewModel.user?.profileImage = $0 }
                         ))
                         .disabled(true) // Display only for now
                         .foregroundColor(.gray)
                    }

                    // Save Button
                    Section {
                        Button("Save Profile") {
                            viewModel.saveUserProfile()
                        }
                        .disabled(viewModel.isLoading) // Disable while loading/saving
                    }

                    // Error Message Display
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        }
                    }
                    
                } else {
                    // Handle case where user is nil and not loading (e.g., initial state or error)
                    Text("No user profile loaded.")
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
            .onAppear {
                // Fetch profile when view appears if needed (e.g., if not fetched in init)
                // viewModel.fetchUserProfile() // Already called in ViewModel init
            }
        }
    }
}

// MARK: - Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
            // Inject mock data or a specific state for preview if needed
    }
} 