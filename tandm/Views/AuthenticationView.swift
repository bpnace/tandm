import SwiftUI

struct AuthenticationView: View {
    // ViewModel will be passed as an EnvironmentObject
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    // State to toggle between Login and Sign Up
    @State private var showLogin = true

    var body: some View {
        VStack {
            // Logo or App Title (Optional)
            Text("Freelancer Suite")
                .font(.largeTitle)
                .padding(.bottom, 40)

            if showLogin {
                LoginView()
                Button("Don't have an account? Sign Up") {
                    showLogin = false
                }
                .padding(.top)
            } else {
                SignUpView()
                Button("Already have an account? Log In") {
                    showLogin = true
                }
                .padding(.top)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    // Provide a dummy ViewModel for the preview
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
} 