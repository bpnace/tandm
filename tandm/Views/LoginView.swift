import SwiftUI

struct LoginView: View {
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

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: authViewModel.signIn) {
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Log In")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty || authViewModel.isLoading)

            // Add Google Sign In Button later
            // Button("Sign In with Google") { ... }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
} 