import Foundation
import SwiftUI // Needed for @Published and ObservableObject
import Firebase // For Auth

@MainActor // Ensure UI updates are on the main thread
class UserProfileViewModel: ObservableObject {

    @Published var user: User? // The user profile data
    @Published var isLoading = false
    @Published var errorMessage: String? // To display errors in the UI

    private let userService = UserService()
    // Assuming you have a way to get the current user's UID
    // This could be injected or fetched from Firebase Auth
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        // Fetch profile when ViewModel is initialized, if a user is logged in
        fetchUserProfile()
    }

    func fetchUserProfile() {
        guard let uid = currentUserID else {
            errorMessage = "User not logged in."
            print(errorMessage!)
            return
        }

        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.user = try await userService.fetchUserProfile(uid: uid)
                if self.user == nil {
                    // Handle case where profile doesn't exist yet for a logged-in user
                    // Maybe create a default one?
                    print("User profile not found for uid \(uid). Consider creating a default profile.")
                    // For now, we'll just clear the error and loading state
                    // You might want to initialize a new User object here based on Auth info
                    self.user = createDefaultUserShell(uid: uid, email: Auth.auth().currentUser?.email)
                }
            } catch {
                errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
                print(errorMessage!)
                // Keep existing user data? Or set to nil?
                // self.user = nil
            }
            isLoading = false
        }
    }

    func saveUserProfile() {
        guard var userToSave = user else {
            errorMessage = "No user data to save."
            print(errorMessage!)
            return
        }
        
        // Ensure the UID is set correctly before saving
        if userToSave.uid == nil, let currentUid = currentUserID {
             userToSave.uid = currentUid
        }
        
        guard userToSave.uid != nil else {
            errorMessage = "Cannot save profile without a user ID."
            print(errorMessage!)
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await userService.createOrUpdateUserProfile(user: userToSave)
                // Optionally re-fetch or just update local state if confident
                // self.user = userToSave // Assuming save was successful
                 print("User profile saved successfully.")
            } catch {
                errorMessage = "Failed to save user profile: \(error.localizedDescription)"
                print(errorMessage!)
            }
            isLoading = false
        }
    }
    
    // Helper to create a basic user object if one doesn't exist in Firestore
    private func createDefaultUserShell(uid: String, email: String?) -> User {
        // Create a new User object with minimal info, prompting the user to complete it.
        // We use the UID from Auth as the primary identifier.
        return User(uid: uid,
                    name: "New User", // Default name
                    email: email ?? "no-email@example.com", // Use email from auth if available
                    bio: "Please update your bio.",
                    createdAt: Timestamp(date: Date()))
    }
    
    // Function to be called when user logs out to clear data
    func clearUserData() {
        self.user = nil
        self.errorMessage = nil
    }
} 