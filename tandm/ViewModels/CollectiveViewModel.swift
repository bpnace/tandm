import Foundation
import Combine
import FirebaseFirestore // Needed for Timestamp

@MainActor // Ensure UI updates are on the main thread
class CollectiveViewModel: ObservableObject {

    @Published var collectives: [Collective] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let collectiveService = CollectiveService()
    private var cancellables = Set<AnyCancellable>()
    private let authViewModel: AuthenticationViewModel // Inject to get current user UID

    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
        // Observe changes in the authenticated user
        authViewModel.$authUser
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main) // Debounce slightly
            .sink { [weak self] firebaseUser in
                guard let self = self else { return }
                if let uid = firebaseUser?.uid {
                    self.fetchCollectives(forUserID: uid)
                } else {
                    // User logged out, clear collectives
                    self.collectives = []
                    self.isLoading = false
                    self.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }

    func fetchCollectives(forUserID uid: String) {
        isLoading = true
        errorMessage = nil
        Swift.Task {
            do {
                let fetchedCollectives = try await collectiveService.fetchCollectives(forUserID: uid)
                self.collectives = fetchedCollectives
                print("ViewModel updated with \(fetchedCollectives.count) collectives.")
            } catch {
                print("Error fetching collectives in ViewModel: \(error)")
                self.errorMessage = "Failed to load collectives: \(error.localizedDescription)"
            }    
            isLoading = false
        }
    }

    func createCollective(name: String, clientFacingName: String?, publicPageSlug: String?) {
        guard let uid = authViewModel.authUser?.uid else {
            errorMessage = "Cannot create collective: User not logged in."
            return
        }
        
        isLoading = true
        errorMessage = nil
        Swift.Task {
            do {
                let newCollectiveID = try await collectiveService.createCollective(
                    name: name, 
                    clientFacingName: clientFacingName, 
                    publicPageSlug: publicPageSlug, 
                    createdByUID: uid
                )
                print("Collective created with ID: \(newCollectiveID). Refreshing list...")
                // Refresh the list after creation
                fetchCollectives(forUserID: uid)
            } catch {
                 print("Error creating collective in ViewModel: \(error)")
                 self.errorMessage = "Failed to create collective: \(error.localizedDescription)"
                 isLoading = false // Ensure loading stops on error
            }
            // isLoading will be set to false by the fetchCollectives call upon completion
        }
    }
    
    // MARK: - Invite Member
    
    func inviteMember(byEmail email: String, toCollectiveID collectiveID: String) async throws {
        print("Attempting to invite user with email: \(email) to collective: \(collectiveID)")
        
        let userService = UserService() // Consider dependency injection later
        
        do {
            // 1. Fetch the user by email
            let targetUser = try await userService.fetchUser(byEmail: email)
            print("Found user: \(targetUser.email)") // Log email or name

            // Ensure UID is valid before proceeding
            guard let targetUID = targetUser.uid, !targetUID.isEmpty else {
                print("Error: Fetched user ID is missing or empty.")
                // fetchUser should ideally throw .missingUID if @DocumentID isn't populated
                 throw CollectiveServiceError.inviteeMissingUID // Use the error from CollectiveService
            }
            print("Found user UID: \(targetUID)")

            // 2. Add the fetched user ID to the collective's members array
            print("Attempting to add user \(targetUID) to collective \(collectiveID)")
            try await collectiveService.addMember(toCollectiveID: collectiveID, userID: targetUID) // Pass the UID string
            
            print("Successfully invited user \(email) (UID: \(targetUID)) to collective \(collectiveID)")

            // Optional: Refresh collective data or relevant list if needed after invite
            // await fetchCollectives(forUserID: authViewModel.authUser!.uid) // Requires authViewModel logic

        } catch let error as UserServiceError {
            // Handle specific UserService errors
            switch error {
            case .userNotFound:
                print("Error inviting member: User with email \(email) not found.")
                throw CollectiveServiceError.inviteeNotFound // Propagate a specific error
            case .missingUID:
                 print("Error inviting member: Found user document for \(email) but UID is missing.")
                 throw CollectiveServiceError.inviteeMissingUID // Propagate specific error
            case .firestoreError(let underlyingError):
                 print("Error fetching user \(email): Firestore error - \(underlyingError.localizedDescription)")
                 throw CollectiveServiceError.inviteeFetchFailed(underlyingError) // Propagate fetch error
             case .decodingError(let underlyingError):
                  print("Error decoding user data for \(email): \(underlyingError.localizedDescription)")
                  throw CollectiveServiceError.inviteeFetchFailed(underlyingError) // Propagate fetch error (consider a more specific error?)
            }
        } catch let error as CollectiveServiceError {
             // Handle specific CollectiveService errors (e.g., from addMember)
             print("Error adding member to collective: \(error)")
             // Re-throw the specific CollectiveServiceError to be handled by the View
             throw error
        } catch {
            // Catch any other unexpected errors during the invite process
            print("An unexpected error occurred during the invite process for email \(email): \(error.localizedDescription)")
            // Use a general failure case if available, or rethrow the generic error
             throw CollectiveServiceError.addMemberFailed(error) // Propagate add member error (or a more general one)
        }
    }
    
    // Add other functions as needed (e.g., updateCollective)
}

// Helper function to check if an error is a Firestore decoding error
// This might be better placed in an Error extension or utility file
// ... existing code ...

// REMOVE THIS ENTIRE ENUM DEFINITION
//enum CollectiveServiceError: Error {
//    case inviteeNotFound
//    case inviteeMissingUID
//    case inviteeFetchFailed(Error) // Includes Firestore and decoding errors during fetch
//    case addMemberFailed(Error)    // Includes Firestore errors during addMember
//    // Add other collective-specific errors as needed
//} 