import Foundation
import Combine

@MainActor // Ensure UI updates happen on the main thread
class TaskViewModel: ObservableObject {
    
    @Published var tasks: [Task] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let taskService = TaskService()
    private let projectID: String // The ID of the project whose tasks this VM manages
    
    init(projectID: String) {
        self.projectID = projectID
        print("TaskViewModel initialized for projectID: \\(projectID)")
        fetchTasks()
    }
    
    // MARK: - Fetch Tasks
    func fetchTasks() {
        print("Attempting to fetch tasks for project \\(projectID)...")
        isLoading = true
        errorMessage = nil
        
        Swift.Task { // Create a new Swift.Task for the async operation
            do {
                self.tasks = try await taskService.fetchTasks(forProjectID: projectID)
                print("Successfully fetched \\(self.tasks.count) tasks for project \\(projectID).")
            } catch {
                print("Error fetching tasks: \\(error)")
                self.errorMessage = "Failed to load tasks: \\(error.localizedDescription)"
                self.tasks = [] // Clear tasks on error
            }
            isLoading = false
        }
    }
    
    // MARK: - Create Task
    func createTask(title: String, assignedToUID: String? = nil, status: TaskStatus = .todo, dueDate: Date? = nil) async {
        guard !title.isEmpty else {
            errorMessage = "Task title cannot be empty."
            return
        }
        
        print("Attempting to create task '\\(title)' for project \\(projectID)...")
        isLoading = true
        errorMessage = nil
        
        Swift.Task { // Use Swift.Task for async creation
            do {
                _ = try await taskService.createTask(
                    projectID: projectID,
                    title: title,
                    assignedToUID: assignedToUID,
                    status: status,
                    dueDate: dueDate
                )
                print("Task '\\(title)' created successfully for project \\(projectID). Refreshing tasks...")
                // Refresh the task list after successful creation
                fetchTasks() // Re-fetch to get the latest list including the new task
            } catch {
                print("Error creating task '\\(title)': \\(error)")
                self.errorMessage = "Failed to create task: \\(error.localizedDescription)"
                isLoading = false // Ensure loading state is reset on error
            }
            // isLoading will be set to false by the fetchTasks() call upon completion
        }
    }
    
    // MARK: - Other Actions (Update, Delete)
    // Add functions for updating status, assignment, deletion etc.
    // func updateTaskStatus(taskID: String, newStatus: TaskStatus) async { ... }
    // func deleteTask(taskID: String) async { ... }
} 