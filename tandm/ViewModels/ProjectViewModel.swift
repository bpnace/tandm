import Foundation
import SwiftUI // For @Published

@MainActor // Ensure UI updates happen on the main thread
class ProjectViewModel: ObservableObject {
    
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let projectService = ProjectService()
    private var currentCollectiveID: String? // Keep track of which collective we've fetched for
    
    init() {
        // Initializer can be simple for now.
        // Fetching might be triggered by a view's onAppear.
    }
    
    // MARK: - Fetch Projects
    func fetchProjects(for collectiveID: String) async {
        // Avoid redundant fetches for the same collective if already loading or loaded
        // guard collectiveID != currentCollectiveID || projects.isEmpty else { return }
        // Note: Decided against the guard above for now to allow easy refresh.
        // Consider adding pull-to-refresh or more sophisticated state management later.
        
        self.isLoading = true
        self.errorMessage = nil
        self.currentCollectiveID = collectiveID // Store the ID we are fetching for
        print("Fetching projects for collective: \(collectiveID)")
        
        do {
            self.projects = try await projectService.fetchProjects(forCollectiveID: collectiveID)
            print("Successfully fetched \(self.projects.count) projects.")
        } catch let error as ProjectServiceError {
            print("Error fetching projects: \(error)")
            self.errorMessage = "Failed to load projects: \(error.localizedDescription)" // Provide a user-friendly message
            // Map ProjectServiceError to more specific user messages if needed
        } catch {
            print("Unexpected error fetching projects: \(error)")
            self.errorMessage = "An unexpected error occurred while loading projects."
        }
        
        self.isLoading = false
    }
    
    // MARK: - Create Project
    func createProject(title: String, description: String, collectiveId: String, startDate: Date, endDate: Date? = nil) async {
        self.isLoading = true
        self.errorMessage = nil
        print("Attempting to create project '\(title)' for collective: \(collectiveId)")

        // Ensure the creation is for the currently relevant collective if needed
        // guard collectiveId == self.currentCollectiveID else {
        //     self.errorMessage = "Cannot create project for a different collective."
        //     self.isLoading = false
        //     return
        // }
        
        do {
            let newProjectID = try await projectService.createProject(
                title: title, 
                description: description, 
                collectiveId: collectiveId, 
                startDate: startDate, 
                endDate: endDate
            )
            print("Successfully created project with ID: \(newProjectID)")
            // Refresh the project list after creation
            await fetchProjects(for: collectiveId)
        } catch let error as ProjectServiceError {
             print("Error creating project: \(error)")
            self.errorMessage = "Failed to create project: \(error.localizedDescription)"
        } catch {
            print("Unexpected error creating project: \(error)")
            self.errorMessage = "An unexpected error occurred while creating the project."
        }
        
        self.isLoading = false
    }
    
    // Add functions for updating/deleting projects later as needed
} 