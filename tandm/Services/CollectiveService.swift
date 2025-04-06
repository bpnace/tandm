import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class CollectiveService {

    private let db = Firestore.firestore()
    private var collectivesCollectionRef: CollectionReference {
        return db.collection("collectives")
    }

    // MARK: - Create Collective

    func createCollective(name: String, clientFacingName: String?, publicPageSlug: String?, createdByUID: String) async throws -> String {
        // A new collective starts with the creator as the only member
        let initialMembers = [createdByUID]
        
        let newCollective = Collective(
            name: name,
            members: initialMembers,
            clientFacingName: clientFacingName,
            createdBy: createdByUID,
            publicPageSlug: publicPageSlug,
            createdAt: Timestamp(date: Date())
        )

        do {
            // Add a new document with an auto-generated ID
            let documentRef = try await collectivesCollectionRef.addDocument(from: newCollective)
            print("Collective created successfully with ID: \(documentRef.documentID)")
            return documentRef.documentID
        } catch {
            print("Error creating collective: \(error)")
            throw CollectiveServiceError.firestoreError(error)
        }
    }

    // MARK: - Fetch Collectives for User

    // Fetches collectives where the user's UID is in the 'members' array
    func fetchCollectives(forUserID uid: String) async throws -> [Collective] {
        do {
            let querySnapshot = try await collectivesCollectionRef
                                        .whereField("members", arrayContains: uid)
                                        .getDocuments()
            
            // Decode documents into Collective objects
            // Using compactMap to filter out any documents that fail to decode
            let collectives = querySnapshot.documents.compactMap { document -> Collective? in
                try? document.data(as: Collective.self)
            }
            
            print("Fetched \(collectives.count) collectives for user \(uid).")
            return collectives
        } catch {
            print("Error fetching collectives for user \(uid): \(error)")
            throw CollectiveServiceError.firestoreError(error)
        }
    }
    
    // MARK: - Add Member to Collective (Placeholder - Requires invite logic)
    
    // Basic function to add a member UID directly. 
    // In a real app, this would likely follow an invitation/acceptance flow.
    func addMember(toCollectiveID collectiveID: String, userID: String) async throws {
        let documentRef = collectivesCollectionRef.document(collectiveID)
        do {
            // Use FieldValue.arrayUnion to safely add the userID if not already present
            try await documentRef.updateData([
                "members": FieldValue.arrayUnion([userID])
            ])
            print("User \(userID) added to collective \(collectiveID).")
        } catch {
             print("Error adding member \(userID) to collective \(collectiveID): \(error)")
             throw CollectiveServiceError.firestoreError(error)
        }
    }

    // Add functions for updating, deleting collectives as needed later.
}

// Define potential custom errors for the service
enum CollectiveServiceError: Error {
    case firestoreError(Error)
    // Invite specific errors
    case inviteeNotFound
    case inviteeMissingUID
    case inviteeFetchFailed(Error) // Covers errors fetching the user to be invited
    case addMemberFailed(Error)    // Covers errors during the addMember Firestore operation
    // case alreadyMember // Consider adding later if needed
    // Add other specific errors like 'collectiveNotFound', 'permissionDenied' etc.
} 