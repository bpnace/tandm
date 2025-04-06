//
//  ContentView.swift
//  tandm
//
//  Created by Tarik Marshall on 06.04.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.modelContext) private var modelContext
    //@Query private var items: [Item]

    var body: some View {
        Group {
            if authViewModel.authUser != nil {
                MainAppView(authViewModel: authViewModel)
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            print("ContentView appeared. Current user: \(authViewModel.authUser?.uid ?? "nil")")
        }
    }
}

struct MainAppView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @StateObject private var collectiveViewModel: CollectiveViewModel

    @State private var showingCreateCollectiveSheet = false

    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
        self._collectiveViewModel = StateObject(wrappedValue: CollectiveViewModel(authViewModel: authViewModel))
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome!")
                    .font(.title)
                Text("You are logged in.")
                if let email = authViewModel.authUser?.email {
                    Text("Email: \(email)")
                        .font(.footnote)
                        .padding(.top)
                }

                List {
                    Section("Your Collectives") {
                        if collectiveViewModel.isLoading {
                            ProgressView()
                        } else if let errorMessage = collectiveViewModel.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else if collectiveViewModel.collectives.isEmpty {
                            Text("You haven't joined any collectives yet.")
                        } else {
                            ForEach(collectiveViewModel.collectives) { collective in
                                NavigationLink(destination: CollectiveDetailView(collective: collective)) {
                                    Text(collective.name)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())

                Spacer()

                Button("Log Out") {
                    authViewModel.signOut()
                }
                .padding(.top)
                .buttonStyle(.bordered)

            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateCollectiveSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingCreateCollectiveSheet) {
                CreateCollectiveView()
                    .environmentObject(collectiveViewModel)
            }
        }
        .environmentObject(collectiveViewModel)
    }
}

struct CreateCollectiveView: View {
    @EnvironmentObject var collectiveViewModel: CollectiveViewModel
    @Environment(\.dismiss) var dismiss

    @State private var collectiveName: String = ""
    @State private var clientFacingName: String = ""
    @State private var publicSlug: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Collective Name", text: $collectiveName)
                TextField("Client Facing Name (Optional)", text: $clientFacingName)
                TextField("Public Slug (Optional)", text: $publicSlug)
            }
            .navigationTitle("New Collective")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveCollective()
                }.disabled(collectiveName.isEmpty)
            )
        }
    }

    private func saveCollective() {
        collectiveViewModel.createCollective(
            name: collectiveName,
            clientFacingName: clientFacingName.isEmpty ? nil : clientFacingName,
            publicPageSlug: publicSlug.isEmpty ? nil : publicSlug
        )
        dismiss()
    }
}

#Preview {
    let authViewModel = AuthenticationViewModel()
    // Simulate logged-in state for previewing MainAppView within ContentView
    // authViewModel.authUser = ... 

    ContentView()
        .environmentObject(authViewModel)

    // For previewing MainAppView directly (requires creating authViewModel)
    /*
    MainAppView(authViewModel: authViewModel) 
    */
    
    // For CreateCollectiveView specific preview (requires creating both VMs)
    /*
    let collectiveViewModel = CollectiveViewModel(authViewModel: authViewModel)
    CreateCollectiveView()
        .environmentObject(collectiveViewModel)
    */
}
