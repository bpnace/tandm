import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $authViewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Optional: Add a "Confirm Password" field if desired

            Button(action: authViewModel.signUp) {
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty || authViewModel.isLoading)
        }
        // Add alert for error messages
        .alert("Sign Up Error", isPresented: .constant(authViewModel.errorMessage != nil), actions: {
            Button("OK") {
                authViewModel.errorMessage = nil // Clear the error message
            }
        }, message: {
            Text(authViewModel.errorMessage ?? "An unknown error occurred.")
        })
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationViewModel())
} 