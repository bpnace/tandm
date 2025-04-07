import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum TaskServiceError: Error {
    case firestoreError(Error)
    case decodingError(Error)
    case taskNotFound
    // Add other specific task errors as needed
}

class TaskService {

    private let db = Firestore.firestore()

    // Helper function to get the tasks subcollection reference for a specific project
    private func tasksCollectionRef(forProjectID projectID: String) -> CollectionReference {
        return db.collection("projects").document(projectID).collection("tasks")
    }

    // MARK: - Fetch Tasks for Project
    func fetchTasks(forProjectID projectID: String) async throws -> [TaskModel] {
        do {
            let querySnapshot = try await tasksCollectionRef(forProjectID: projectID)
                                        // Optionally order by creation date, due date, status etc.
                                        .order(by: "createdAt", descending: false)
                                        .getDocuments()

            let tasks = try querySnapshot.documents.compactMap { document -> TaskModel? in
                do {
                    return try document.data(as: TaskModel.self)
                } catch {
                    print("Error decoding task document \(document.documentID) in project \(projectID): \(error)")
                    // Depending on requirements, you might throw, log, or return nil
                    return nil 
                }
            }

            print("Fetched \(tasks.count) tasks for project \(projectID).")
            return tasks
        } catch {
            print("Error fetching tasks for project \(projectID): \(error)")
            throw TaskServiceError.firestoreError(error)
        }
    }

    // MARK: - Create Task
    func createTask(projectID: String, title: String, assignedTo: String? = nil, status: TaskStatus = .todo, dueDate: Date? = nil) async throws -> TaskModel {
        // Create a TaskModel object - createdAt will be set by Firestore
        let task = TaskModel(
            title: title,
            assignedTo: assignedTo,
            status: status,
            dueDate: dueDate != nil ? Timestamp(date: dueDate!) : nil
        )

        do {
            // Add the task document to the subcollection
            let documentRef = try await tasksCollectionRef(forProjectID: projectID).addDocument(from: task)
            print("Task '\\(title)' created successfully with ID: \\(documentRef.documentID) in project \\(projectID)")
            // Optionally fetch the newly created task with its ID and return it
            var createdTask = task
            createdTask.id = documentRef.documentID // Assign the generated ID
            return createdTask // Return the task with the ID
        } catch let error as EncodingError {
            print("Error encoding task data for project \\(projectID): \\(error)")
            throw TaskServiceError.decodingError(error) // Reusing decodingError for encoding errors
        } catch {
            print("Error creating task '\\(title)' in project \\(projectID): \\(error)")
            throw TaskServiceError.firestoreError(error)
        }
    }

    // MARK: - Update Task
    func updateTaskStatus(projectID: String, taskId: String, newStatus: TaskStatus) async throws {
        print("  [TaskService] Attempting update for task \(taskId) to \(newStatus.rawValue)")
        let taskRef = tasksCollectionRef(forProjectID: projectID).document(taskId)
        do {
            try await taskRef.updateData(["status": newStatus.rawValue]) // Assuming TaskStatus has a String rawValue
            print("  [TaskService] Firestore updateData successful for task \(taskId).")
        } catch {
            print("  [TaskService] Firestore updateData FAILED for task \(taskId): \(error)")
            throw TaskServiceError.firestoreError(error)
        }
    }

    func updateTaskAssignment(projectID: String, taskId: String, newAssignedTo: String?) async throws {
        print("  [TaskService] Attempting assignment update for task \(taskId)")
        let taskRef = tasksCollectionRef(forProjectID: projectID).document(taskId)
        do {
            let data: [String: Any] = ["assignedTo": newAssignedTo as Any? ?? NSNull()]
            try await taskRef.updateData(data)
            print("  [TaskService] Firestore assignment update successful for task \(taskId).")
        } catch {
            print("  [TaskService] Firestore assignment update FAILED for task \(taskId): \(error)")
            throw TaskServiceError.firestoreError(error)
        }
    }

    // Update both assignment and due date
    func updateTaskDetails(projectID: String, taskId: String, newAssignedTo: String?, newDueDate: Timestamp?) async throws {
        print("  [TaskService] Attempting details update for task \(taskId)")
        let taskRef = tasksCollectionRef(forProjectID: projectID).document(taskId)
        do {
            // Prepare data dictionary, handling nil values
            var dataToUpdate: [String: Any] = [:]
            dataToUpdate["assignedTo"] = newAssignedTo as Any? ?? NSNull()
            dataToUpdate["dueDate"] = newDueDate as Any? ?? NSNull()
            
            try await taskRef.updateData(dataToUpdate)
            print("  [TaskService] Firestore details update successful for task \(taskId).")
        } catch {
            print("  [TaskService] Firestore details update FAILED for task \(taskId): \(error)")
            throw TaskServiceError.firestoreError(error)
        }
    }

    // MARK: - Delete Task
    func deleteTask(projectID: String, taskId: String) async throws {
        let taskRef = tasksCollectionRef(forProjectID: projectID).document(taskId)
        do {
            try await taskRef.delete()
            print("Task \(taskId) in project \(projectID) deleted successfully.")
        } catch {
            print("Error deleting task \(taskId) in project \(projectID): \(error)")
            throw TaskServiceError.firestoreError(error)
        }
    }

} 