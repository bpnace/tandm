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
    func fetchTasks(forProjectID projectID: String) async throws -> [Task] {
        do {
            let querySnapshot = try await tasksCollectionRef(forProjectID: projectID)
                                        // Optionally order by creation date, due date, status etc.
                                        .order(by: "createdAt", descending: false)
                                        .getDocuments()

            let tasks = try querySnapshot.documents.compactMap { document -> Task? in
                do {
                    return try document.data(as: Task.self)
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
    func createTask(projectID: String, title: String, assignedToUID: String? = nil, status: TaskStatus = .todo, dueDate: Date? = nil) async throws -> String {
        // Create a Task object - createdAt will be set by Firestore
        let task = Task(
            title: title,
            assignedTo: assignedToUID,
            status: status,
            dueDate: dueDate != nil ? Timestamp(date: dueDate!) : nil
        )

        do {
            // Add the task document to the subcollection
            let documentRef = try await tasksCollectionRef(forProjectID: projectID).addDocument(from: task)
            print("Task '\\(title)' created successfully with ID: \\(documentRef.documentID) in project \\(projectID)")
            return documentRef.documentID
        } catch let error as EncodingError {
            print("Error encoding task data for project \\(projectID): \\(error)")
            throw TaskServiceError.decodingError(error) // Reusing decodingError for encoding errors
        } catch {
            print("Error creating task '\\(title)' in project \\(projectID): \\(error)")
            throw TaskServiceError.firestoreError(error)
        }
    }

    // MARK: - Update Task
    // func updateTaskStatus(...) async throws { ... }
    // func assignTask(...) async throws { ... }

    // MARK: - Delete Task
    // func deleteTask(...) async throws { ... }

} 