import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift // For Codable support

class UserService {

    private let db = Firestore.firestore()
    private var usersCollectionRef: CollectionReference {
        return db.collection("users")
    }

    // MARK: - Fetch User Profile

    func fetchUserProfile(uid: String) async throws -> User? {
        let documentRef = usersCollectionRef.document(uid)
        do {
            // Use try await with getDocument(as:) for Codable conformance
            let user = try await documentRef.getDocument(as: User.self)
            return user
        } catch {
            print("Error fetching user profile for uid \(uid): \(error)")
            // Handle specific errors if needed (e.g., user not found vs. network error)
            // For now, rethrow the error or return nil depending on desired behavior
            if isDecodingError(error: error) {
                 print("Decoding error fetching user profile for uid \(uid): \(error)")
                 // Handle potentially corrupted data or schema mismatch
            }
            return nil // Or rethrow if the caller should handle the absence of a profile
        }
    }
    
    // Helper to check for decoding errors specifically
    private func isDecodingError(error: Error) -> Bool {
        if case DecodingError.keyNotFound = error { return true }
        if case DecodingError.valueNotFound = error { return true }
        if case DecodingError.typeMismatch = error { return true }
        if case DecodingError.dataCorrupted = error { return true }
        // Check for Firestore specific decoding issues if necessary
        if error.localizedDescription.contains("failed to decode") { return true }
        return false
    }

    // MARK: - Create or Update User Profile

    // Using merge = true allows this function to work for both creation (if doc doesn't exist)
    // and update (overwriting fields or adding new ones).
    // Consider separate create and update methods if stricter control is needed.
    func createOrUpdateUserProfile(user: User) async throws {
        guard let uid = user.uid else {
            print("Error: User UID is missing, cannot save profile.")
            throw UserServiceError.missingUID
        }

        let documentRef = usersCollectionRef.document(uid)
        do {
            // Use setData(from: merge: true) to update or create
            // This will only update the fields present in the `user` object
            // and won't overwrite fields not included (unless they are explicitly nil in the source object?)
            // Check Firestore docs for exact merge behavior with nil values if critical.
            // For a full overwrite, use merge: false.
            try documentRef.setData(from: user, merge: true)
            print("User profile successfully saved/updated for uid \(uid).")
        } catch {
            print("Error saving user profile for uid \(uid): \(error)")
            throw error // Rethrow the error for the caller to handle
        }
    }
    
    // Example of a more specific update function if needed
    func updateUserSpecificFields(uid: String, data: [String: Any]) async throws {
        let documentRef = usersCollectionRef.document(uid)
        do {
            try await documentRef.updateData(data)
            print("User profile fields successfully updated for uid \(uid).")
        } catch {
             print("Error updating specific fields for user profile uid \(uid): \(error)")
            throw error
        }
    }

    // MARK: - Fetch User by Email
    
    func fetchUser(byEmail email: String) async throws -> User {
        let querySnapshot = try await usersCollectionRef
                                    .whereField("email", isEqualTo: email)
                                    .limit(to: 1) // Email should be unique
                                    .getDocuments()
                                    
        guard let document = querySnapshot.documents.first else {
            print("Error: No user found with email \(email)")
            throw UserServiceError.userNotFound
        }
        
        do {
            let user = try document.data(as: User.self)
            // Note: The fetched User struct might not have the UID populated 
            // if the @DocumentID wrapper wasn't used or if UID isn't stored explicitly.
            // However, our User model uses @DocumentID, so it should be populated.
            // Let's ensure the UID is actually present.
            guard user.uid != nil else {
                print("Error: Fetched user for email \(email) is missing UID.")
                throw UserServiceError.missingUID // Or a different error? Firestore should populate @DocumentID.
            }
            print("Fetched user with UID: \(user.uid ?? "nil") for email: \(email)")
            return user
        } catch {
            print("Error decoding user for email \(email): \(error)")
            // Check if it's a decoding error specifically
            if isDecodingError(error: error) {
                 throw UserServiceError.decodingError(error)
            } else {
                 throw UserServiceError.firestoreError(error)
            }
        }
    }

    // Creates or updates a user document in Firestore
    // Made internal as it's primarily used after signup or for profile updates
    func updateUserProfile(_ user: User) async throws {
        guard let uid = user.uid else {
            print("Error: Cannot update profile for user without UID.")
            throw UserServiceError.missingUID
        }
        
        let documentRef = usersCollectionRef.document(uid)
        
        do {
            // Use setData(from:merge:) to create or update the document.
            // merge: true ensures we don't overwrite fields unintentionally.
            try documentRef.setData(from: user, merge: true) // Removed await
            print("User profile for UID \(uid) updated successfully.")
        } catch let error as EncodingError {
            print("Error encoding user data for UID \(uid): \(error)")
            throw UserServiceError.decodingError(error) // Reusing decodingError for encoding issues
        } catch {
            print("Error updating user profile for UID \(uid): \(error)")
            throw UserServiceError.firestoreError(error)
        }
    }

}

// Define potential custom errors for the service
enum UserServiceError: Error {
    case missingUID
    case firestoreError(Error)
    case decodingError(Error)
    case userNotFound
    // Add other specific errors as needed
} 