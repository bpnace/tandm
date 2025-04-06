//
//  tandmApp.swift
//  tandm
//
//  Created by Tarik Marshall on 06.04.25.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct tandmApp: App {
    // Initialize the AuthenticationViewModel as a StateObject
    @StateObject var authViewModel = AuthenticationViewModel()
    // Remove CollectiveViewModel state object here

    // Firebase Initialization
    init() {
        FirebaseApp.configure()
        // Remove CollectiveViewModel initialization here
    }

    // Remove or keep SwiftData container based on requirements
    /*
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    */

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject only the AuthenticationViewModel into the environment
                .environmentObject(authViewModel)
                // Remove CollectiveViewModel injection here
        }
        // Remove or keep modelContainer modifier based on requirements
        // .modelContainer(sharedModelContainer)
    }
}
