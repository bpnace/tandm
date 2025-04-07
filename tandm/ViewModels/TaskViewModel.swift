import Foundation
import Combine
import FirebaseFirestoreSwift // Ensure this is imported if needed for Task model, though likely already is
import FirebaseFirestore // <-- Add this import

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
    func updateTaskStatus(task: TaskModel, newStatus: TaskStatus) async {
        guard let taskId = task.id else {
            print("[TaskViewModel] Error: Task ID is missing for update.")
            errorMessage = "Cannot update task: Missing ID."
            return
        }
        
        print("[TaskViewModel] Starting status update for task \(taskId) to \(newStatus.rawValue). Calling service...")
        errorMessage = nil // Clear previous errors
        // Optionally set isLoading = true if you want a loading indicator during update
        
        do {
            try await taskService.updateTaskStatus(projectID: projectID, taskId: taskId, newStatus: newStatus)
            print("[TaskViewModel] Service call updateTaskStatus completed for task \(taskId). Proceeding to update local state.")
            // Find the index of the task and update it locally
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                tasks[index].status = newStatus
                print("[TaskViewModel] Local state updated for task \(taskId) at index \(index).")
            } else {
                 print("[TaskViewModel] Task \(taskId) not found in local 'tasks' array after successful service update.")
            }
        } catch {
            print("[TaskViewModel] Service call updateTaskStatus FAILED for task \(taskId): \(error)")
            self.errorMessage = "Failed to update task status: \(error.localizedDescription)"
        }
        // Optionally set isLoading = false here
        print("[TaskViewModel] Status update process finished for task \(taskId).")
    }
    
    func updateTaskAssignment(task: TaskModel, newAssignedTo: String?) async {
        guard let taskId = task.id else {
            print("Error: Task ID is missing for assignment update.")
            errorMessage = "Cannot update task assignment: Missing ID."
            return
        }

        print("Attempting to update assignment for task \(taskId) to \(newAssignedTo ?? "Unassigned") in project \(projectID)...")
        errorMessage = nil
        
        do {
            try await taskService.updateTaskAssignment(projectID: projectID, taskId: taskId, newAssignedTo: newAssignedTo)
            print("Task \(taskId) assignment updated successfully. Updating local state.")
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                tasks[index].assignedTo = newAssignedTo
            }
        } catch {
            print("Error updating task \(taskId) assignment: \(error)")
            self.errorMessage = "Failed to update task assignment: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Update Task Details (Assignment & Due Date)
    func updateTaskDetails(task: TaskModel, newAssignedTo: String?, newDueDate: Date?) async {
        guard let taskId = task.id else {
            print("[TaskViewModel] Error: Task ID is missing for details update.")
            errorMessage = "Cannot update task details: Missing ID."
            return
        }
        
        print("[TaskViewModel] Starting details update for task \(taskId). Calling service...")
        errorMessage = nil
        
        do {
            // Convert Date? to Timestamp?
            let newTimestamp = newDueDate != nil ? Timestamp(date: newDueDate!) : nil
            
            try await taskService.updateTaskDetails(projectID: projectID, taskId: taskId, newAssignedTo: newAssignedTo, newDueDate: newTimestamp)
            print("[TaskViewModel] Service call updateTaskDetails completed for task \(taskId). Proceeding to update local state.")
            
            // Update local state
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                tasks[index].assignedTo = newAssignedTo
                tasks[index].dueDate = newTimestamp
                print("[TaskViewModel] Local state updated for task \(taskId) details.")
            } else {
                 print("[TaskViewModel] Task \(taskId) not found locally after successful details update.")
            }
        } catch {
            print("[TaskViewModel] Service call updateTaskDetails FAILED for task \(taskId): \(error)")
            self.errorMessage = "Failed to update task details: \(error.localizedDescription)"
        }
        print("[TaskViewModel] Details update process finished for task \(taskId).")
    }
    
    func deleteTask(task: TaskModel) async {
        guard let taskId = task.id else {
            print("Error: Task ID is missing for deletion.")
            errorMessage = "Cannot delete task: Missing ID."
            return
        }
        
        print("Attempting to delete task \(taskId) in project \(projectID)...")
        errorMessage = nil
        
        do {
            try await taskService.deleteTask(projectID: projectID, taskId: taskId)
            print("Task \(taskId) deleted successfully. Removing from local state.")
            tasks.removeAll { $0.id == taskId }
        } catch {
            print("Error deleting task \(taskId): \(error)")
            self.errorMessage = "Failed to delete task: \(error.localizedDescription)"
        }
    }
} 