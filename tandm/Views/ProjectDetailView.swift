import SwiftUI
import FirebaseFirestore

struct ProjectDetailView: View {
    let project: Project
    
    // StateObject to manage the TaskViewModel lifecycle for this specific project view
    @StateObject private var taskViewModel: TaskViewModel
    
    // State for presenting the Create Task sheet
    @State private var showingCreateTaskSheet = false
    
    // State for presenting the Assign Task alert
    @State private var showingAssignAlert = false
    @State private var taskToAssign: TaskModel? = nil
    @State private var assignedUserIdInput: String = ""
    
    // State for presenting Edit Task sheet
    @State private var showingEditTaskSheet = false
    @State private var taskToEdit: TaskModel? = nil
    
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
                ProjectInfoSection(project: project)
            } // End Section("Project Details")

            Divider()

            // Task Section
            Section("Tasks") {
                if taskViewModel.isLoading {
                    ProgressView()
                } else if taskViewModel.tasks.isEmpty {
                    VStack {
                        Image(systemName: "checklist.unchecked")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 2)
                        Text("No tasks yet.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(taskViewModel.tasks) { task in
                        TaskRowView(task: task, taskViewModel: taskViewModel, taskToAssign: $taskToAssign, assignedUserIdInput: $assignedUserIdInput, showingAssignAlert: $showingAssignAlert)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                taskToEdit = task
                                showingEditTaskSheet = true
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
        // Add sheet for editing task
        .sheet(item: $taskToEdit) { task in // Use .sheet(item: ...) for optional state
            EditTaskView(task: task, taskViewModel: taskViewModel)
        }
        // Add alert for assigning task
        .alert("Assign Task", isPresented: $showingAssignAlert, presenting: taskToAssign) { task in
            TextField("Enter User ID", text: $assignedUserIdInput)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button("Assign") {
                Task {
                    // Use the captured taskToAssign (now 'task') and the input field
                    await taskViewModel.updateTaskAssignment(task: task, newAssignedTo: assignedUserIdInput.isEmpty ? nil : assignedUserIdInput)
                    assignedUserIdInput = "" // Clear input field
                }
            }
            Button("Cancel", role: .cancel) { 
                assignedUserIdInput = "" // Clear input field on cancel
            }
        } message: { task in
            Text("Enter the User ID to assign the task '\(task.title)' to. Leave empty to unassign.")
        }
        // Add alert for Task fetch/update errors
        .alert("Task Error", isPresented: .constant(taskViewModel.errorMessage != nil), actions: {
            Button("OK") { taskViewModel.errorMessage = nil }
        }, message: {
            Text(taskViewModel.errorMessage ?? "An unknown error occurred with tasks.")
        })
        // .onAppear is handled by TaskViewModel's init
    }
}

// MARK: - Task Row Helper View
private struct TaskRowView: View {
    let task: TaskModel
    @ObservedObject var taskViewModel: TaskViewModel
    @Binding var taskToAssign: TaskModel?
    @Binding var assignedUserIdInput: String
    @Binding var showingAssignAlert: Bool

    // Helper to determine color based on status
    private var statusColor: Color {
        switch task.status {
        case .todo:
            return .gray
        case .inProgress:
            return .blue
        case .blocked:
            return .orange
        case .done:
            return .green
        }
    }

    var body: some View {
        HStack(spacing: 8) { // Add HStack to hold bar and content
            // Vertical status indicator bar
            Rectangle()
                .fill(statusColor)
                .frame(width: 4)
                .cornerRadius(2) // Optional: slightly round the corners
            
            // Existing content
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text("Status: \(task.status.rawValue.capitalized)") // Capitalize status
                    .font(.subheadline)
                    .foregroundColor(.gray)
                // Display Assigned User
                if let assignedTo = task.assignedTo, !assignedTo.isEmpty {
                    Text("Assigned: \(assignedTo)") // Simple display for now
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("Unassigned")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate.dateValue().formatted(date: .abbreviated, time: .omitted))") // Explicit formatting
                        .font(.caption)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                // Call ViewModel delete function
                Task {
                    await taskViewModel.deleteTask(task: task)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                // Cycle through statuses
                Task {
                    guard let currentStatusIndex = TaskStatus.allCases.firstIndex(of: task.status) else { return }
                    let nextIndex = (currentStatusIndex + 1) % TaskStatus.allCases.count
                    let newStatus = TaskStatus.allCases[nextIndex]
                    await taskViewModel.updateTaskStatus(task: task, newStatus: newStatus)
                }
            } label: {
                Label("Next Status", systemImage: "arrow.clockwise.circle")
            }
            .tint(.blue) // Or choose a color based on the next status
        }
        // Context menu should remain here
        .contextMenu {
            Button {
                Task {
                    await taskViewModel.updateTaskAssignment(task: task, newAssignedTo: nil)
                }
            } label: {
                Label("Unassign Task", systemImage: "person.crop.circle.badge.xmark")
            }

            Button {
                self.taskToAssign = task
                self.assignedUserIdInput = task.assignedTo ?? ""
                self.showingAssignAlert = true
            } label: {
                Label("Reassign Task", systemImage: "person.crop.circle.badge.plus")
            }
        }
    }
}

// MARK: - Project Info Helper View
private struct ProjectInfoSection: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { 
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
            HStack {
                Text("Start Date:")
                Text(project.startDate.dateValue().formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)

            if let endDate = project.endDate {
                HStack {
                    Text("End Date:")
                    Text(endDate.dateValue().formatted(date: .abbreviated, time: .omitted))
                }
                .font(.caption)
            }
        }
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