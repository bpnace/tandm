import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    
    // StateObject to manage the TaskViewModel lifecycle for this specific project view
    @StateObject private var taskViewModel: TaskViewModel
    
    // State for presenting the Create Task sheet
    @State private var showingCreateTaskSheet = false
    
    // Initialize the ViewModel with the project's ID
    init(project: Project) {
        self.project = project
        // Ensure we have a valid project ID before initializing the viewModel
        // If project.id is nil, it indicates an issue (shouldn't happen if fetched correctly)
        guard let projectId = project.id else {
            // Handle the error case appropriately, maybe show an error view
            // For now, we'll fatalError or use a placeholder ID
            fatalError("ProjectDetailView initialized without a project ID.")
            // Or: _taskViewModel = StateObject(wrappedValue: TaskViewModel(projectID: "ERROR_NO_ID"))
        }
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(projectID: projectId))
    }

    var body: some View {
        List {
            // Section: Project Info
            Section("Project Details") {
                Text(project.title)
                    .font(.largeTitle)
                    .padding(.bottom, 2)
                Text(project.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                HStack {
                    Text("Status:")
                    Text(project.status.rawValue.capitalized)
                        .fontWeight(.semibold)
                }
                if let startDate = project.startDate {
                    Text("Start Date: \\(startDate.dateValue(), style: .date)")
                }
                if let endDate = project.endDate {
                    Text("End Date: \\(endDate.dateValue(), style: .date)")
                }
            }
            
            // Section: Tasks
            Section("Tasks") {
                if taskViewModel.isLoading {
                    ProgressView("Loading Tasks...")
                } else if let errorMessage = taskViewModel.errorMessage {
                    Text("Error: \\(errorMessage)")
                        .foregroundColor(.red)
                } else if taskViewModel.tasks.isEmpty {
                    Text("No tasks added yet.")
                        .foregroundColor(.secondary)
                    Button("Add First Task") { // Button to add task when list is empty
                         showingCreateTaskSheet = true
                    }
                } else {
                    ForEach(taskViewModel.tasks) { task in
                        // TODO: Create a TaskRowView for better structure
                        VStack(alignment: .leading) {
                            Text(task.title).font(.headline)
                            HStack {
                                Text(task.status.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(5)
                                if let dueDate = task.dueDate {
                                    Text("Due: \\(dueDate.dateValue(), style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                // Add assignedTo later
                            }
                        }
                        // Add swipe actions or context menu for status updates/deletion later
                    }
                }
            }
        }
        .navigationTitle(project.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateTaskSheet = true
                } label: {
                    Label("Add Task", systemImage: "plus.circle.fill")
                }
                .disabled(project.id == nil) // Should always have an ID here
            }
        }
        .sheet(isPresented: $showingCreateTaskSheet) {
             // Present the actual CreateTaskView, passing the viewModel
             CreateTaskView(taskViewModel: taskViewModel)
            // Text("Create Task View Placeholder") // Placeholder removed
        }
        // .onAppear is handled by TaskViewModel's init
    }
}

// Preview needs a mock Project and potentially TaskViewModel setup
#Preview {
    let mockProject = Project(
        id: "proj_preview_123",
        title: "Sample Project",
        description: "This is a detailed description for the sample project used in the preview.",
        collectiveId: "coll_abc",
        status: .active,
        startDate: Timestamp(date: Date()),
        endDate: nil,
        createdAt: Timestamp()
    )
    
    // For preview, TaskViewModel will fetch from Firestore if not mocked.
    // If you want controlled preview data, you'd need a MockTaskService
    // and inject it into TaskViewModel, or manually set tasks.
    NavigationView {
        ProjectDetailView(project: mockProject)
    }
} 