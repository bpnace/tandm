import SwiftUI
import FirebaseFirestore

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
                // Display Project Dates
                HStack {
                    Text("Start Date:")
                    // Since startDate is NOT optional based on error, display directly
                    Text(project.startDate.dateValue(), style: .date)
                }
                .font(.caption)

                // Only show End Date if it exists (it IS optional in the model)
                if let endDate = project.endDate {
                    HStack {
                        Text("End Date:")
                        Text(endDate.dateValue(), style: .date) // Use the unwrapped endDate here
                    }
                    .font(.caption)
                }

                Divider()

                // Task Section
                Section("Tasks") {
                    if taskViewModel.isLoading {
                        ProgressView()
                    } else if taskViewModel.errorMessage != nil {
                        // Display the error message directly
                        Text("Error: \(taskViewModel.errorMessage!)")
                            .foregroundColor(.red)
                    } else if taskViewModel.tasks.isEmpty {
                        Text("No tasks yet.")
                    } else {
                        List {
                            ForEach(taskViewModel.tasks) { task in
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                    HStack {
                                        Text("Status: \(task.status.rawValue)")
                                        Spacer()
                                        // Display Due Date if it exists
                                        if let dueDate = task.dueDate { 
                                            Text("Due: \(dueDate.dateValue(), style: .date)") // Use unwrapped dueDate
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    // Add assignedTo later
                                }
                            }
                        }
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