import Foundation
import SwiftUI // Needed for @Published and ObservableObject
import Firebase // For Auth
import FirebaseFirestore // <-- Add this import
import FirebaseStorage // <-- Import Storage

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
                let fetchedUser = try await userService.fetchUserProfile(uid: uid)
                if fetchedUser == nil {
                    // Handle case where profile doesn't exist yet for a logged-in user
                    print("User profile not found for uid \(uid). Creating default profile.")
                    // Create a default user shell
                    let defaultUser = createDefaultUserShell(uid: uid, email: Auth.auth().currentUser?.email)
                    // Attempt to save the default profile immediately
                    try await userService.createOrUpdateUserProfile(user: defaultUser)
                    print("Default profile saved for user \(uid).")
                    // Set the local user state to the newly created default user
                    self.user = defaultUser 
                } else {
                    // Profile found, update local state
                    self.user = fetchedUser
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
    
    // MARK: - Upload Profile Image
    func uploadProfileImage(imageData: Data) async {
        guard let uid = currentUserID else {
            errorMessage = "Cannot upload image: User not logged in."
            print(errorMessage!)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 1. Define Storage Path
        // Use user's UID to create a unique path. Use .jpg extension.
        let storagePath = "profile_images/\(uid).jpg"
        let storageRef = Storage.storage().reference(withPath: storagePath)
        
        // 2. Define Metadata (optional, set content type)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            // 3. Upload Data
            print("Uploading image data to: \(storagePath)...")
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            print("Image uploaded successfully.")
            
            // --- Restore URL Fetch & Firestore Update ---
            // 4. Get Download URL
            let downloadURL = try await storageRef.downloadURL()
            let downloadURLString = downloadURL.absoluteString
            print("Image Download URL: \(downloadURLString)")
            
            // 5. Update Firestore profileImage field
            guard var userToUpdate = self.user else {
                errorMessage = "User data not available to update profile image URL."
                isLoading = false
                return
            }
            userToUpdate.profileImage = downloadURLString
            // Update local user immediately for faster UI feedback
            self.user = userToUpdate 
            
            // Save the updated user profile to Firestore
            try await userService.createOrUpdateUserProfile(user: userToUpdate)
            print("User profile updated with new image URL.")
             // --- End Restored Code ---
            
        } catch {
            errorMessage = "Failed to upload profile image or update profile: \(error.localizedDescription)"
            print("Error during image upload/profile update: \(error)")
        }
        
        isLoading = false
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
