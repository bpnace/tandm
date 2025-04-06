import Foundation
import Combine
import FirebaseFirestoreSwift // Ensure this is imported if needed for Task model, though likely already is

@MainActor // Ensure UI updates happen on the main thread
class TaskViewModel: ObservableObject {
    
    @Published var tasks: [TaskModel] = []
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
        
        Task { // Removed Swift. prefix as TaskModel rename resolves ambiguity
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
    func createTask(title: String, assignedTo: String? = nil, status: TaskStatus = .todo, dueDate: Date? = nil) async {
        guard !title.isEmpty else {
            errorMessage = "Task title cannot be empty."
            return
        }
        
        print("Attempting to create task '\\(title)' for project \\(projectID)...")
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await taskService.createTask(
                projectID: projectID,
                title: title,
                assignedTo: assignedTo,
                status: status,
                dueDate: dueDate
            )
            print("Task '\\(title)' created successfully for project \\(projectID). Refreshing tasks...")
            // Refresh the task list after successful creation. 
            // fetchTasks() will set isLoading = false on completion.
            fetchTasks() 
        } catch {
            print("Error creating task '\\(title)': \\(error)")
            self.errorMessage = "Failed to create task: \\(error.localizedDescription)"
            isLoading = false // Ensure loading state is reset on error
        }
    }
    
    // MARK: - Other Actions (Update, Delete)
    // Add functions for updating status, assignment, deletion etc.
    // func updateTaskStatus(taskID: String, newStatus: TaskStatus) async { ... }
    // func deleteTask(taskID: String) async { ... }
} 