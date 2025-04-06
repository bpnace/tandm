import SwiftUI

struct InviteMemberView: View {
    let collective: Collective
    @EnvironmentObject var collectiveViewModel: CollectiveViewModel
    @Environment(\.dismiss) var dismiss

    @State private var emailToInvite: String = ""
    @State private var isInviting: Bool = false
    @State private var inviteError: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Invite User by Email")) {
                        TextField("Email address", text: $emailToInvite)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    if let inviteError = inviteError {
                        Section {
                            Text("Error: \(inviteError)")
                                .foregroundColor(.red)
                        }
                    }
                }

                Spacer()

                Button(action: inviteMember) {
                    if isInviting {
                        ProgressView()
                    } else {
                        Text("Send Invite")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(emailToInvite.isEmpty || !isValidEmail(emailToInvite) || isInviting)
                .padding()
            }
            .navigationTitle("Invite to \(collective.name)")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }

    private func inviteMember() {
        guard let collectiveId = collective.id else {
            inviteError = "Collective ID is missing."
            return
        }
        
        isInviting = true
        inviteError = nil
        
        Swift.Task {
            do {
                try await collectiveViewModel.inviteMember(byEmail: emailToInvite, toCollectiveID: collectiveId)
                print("Invite process initiated for \(emailToInvite) to collective \(collectiveId)")
                // Optionally show success message before dismissing
                dismiss()
            } catch {
                print("Error inviting member: \(error)")
                // Improve error message based on specific error type if needed
                inviteError = error.localizedDescription 
            }
            isInviting = false
        }
    }
    
    // Basic email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview
#Preview {
    let mockAuth = AuthenticationViewModel()
    let mockCollectiveVM = CollectiveViewModel(authViewModel: mockAuth)
    let mockCollective = Collective(
        id: "mock123",
        name: "Preview Collective",
        members: ["user1"], 
        createdBy: "user1"
    )
    
    InviteMemberView(collective: mockCollective)
        .environmentObject(mockCollectiveVM)
} 