import SwiftUI
import Combine
import FirebaseAuth // Import FirebaseAuth

// ObservableObject to be used by SwiftUI views
@MainActor // Ensures UI updates are on the main thread
class AuthenticationViewModel: ObservableObject {

    // Published properties to update the UI
    @Published var email = ""
    @Published var password = ""
    @Published var authUser: FirebaseAuth.User?
    @Published var errorMessage: String? // For displaying errors
    @Published var isLoading = false // To show loading indicators

    private var authStateHandler: AuthStateDidChangeListenerHandle? = nil

    init() {
        registerAuthStateHandler()
    }

    deinit {
        // Clean up listener when ViewModel is deallocated
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Listen for changes in authentication state (login/logout)
    func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            self.authUser = user
            // Optional: Add logic here if something needs to happen immediately on auth state change
            print("Auth State Changed: User is \(user == nil ? "nil" : user!.uid)")
        }
    }

    // Function to handle sign-up
    func signUp() {
        isLoading = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Sign Up Error: \(error.localizedDescription)")
                } else {
                    // Sign up successful, user is automatically signed in
                    self.email = "" // Clear fields
                    self.password = ""
                    print("Sign Up Successful: User UID: \(authResult?.user.uid ?? "N/A")")
                    // self.authUser is updated by the listener (registerAuthStateHandler)
                }
            }
        }
    }

    // Function to handle sign-in
    func signIn() {
        isLoading = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Sign In Error: \(error.localizedDescription)")
                } else {
                    // Sign in successful
                     self.email = "" // Clear fields
                     self.password = ""
                    print("Sign In Successful: User UID: \(authResult?.user.uid ?? "N/A")")
                     // self.authUser is updated by the listener (registerAuthStateHandler)
                }
            }
        }
    }

    // Function to handle sign-out
    func signOut() {
        do {
            try Auth.auth().signOut()
            // authUser property will be set to nil by the listener
            print("Sign Out Successful")
        } catch let signOutError as NSError {
            self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    // Add Google Sign-In function later if needed
    // func signInWithGoogle() { ... }
} 