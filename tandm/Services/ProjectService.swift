import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProjectService {

    private let db = Firestore.firestore()
    private var projectsCollectionRef: CollectionReference {
        return db.collection("projects")
    }

    // MARK: - Create Project
    func createProject(title: String, description: String, collectiveId: String, status: ProjectStatus = .planning, startDate: Date, endDate: Date? = nil) async throws -> String {
        let project = Project(
            title: title,
            description: description,
            collectiveId: collectiveId,
            status: status,
            startDate: Timestamp(date: startDate),
            endDate: endDate != nil ? Timestamp(date: endDate!) : nil
            // createdAt is handled by @ServerTimestamp
        )

        do {
            let documentRef = try await projectsCollectionRef.addDocument(from: project)
            print("Project created successfully with ID: \(documentRef.documentID)")
            return documentRef.documentID
        } catch let error as EncodingError {
            print("Error encoding project data: \(error)")
            throw ProjectServiceError.decodingError(error) // Reusing decodingError for encoding
        } catch {
            print("Error creating project: \(error)")
            throw ProjectServiceError.firestoreError(error)
        }
    }

    // MARK: - Fetch Projects for Collective
    func fetchProjects(forCollectiveID collectiveID: String) async throws -> [Project] {
        do {
            let querySnapshot = try await projectsCollectionRef
                                        .whereField("collectiveId", isEqualTo: collectiveID)
                                        // Optionally order by creation date or status
                                        .order(by: "createdAt", descending: true) // <-- Restore ordering
                                        .getDocuments()
            
            let projects = try querySnapshot.documents.compactMap { document -> Project? in
                do {
                    return try document.data(as: Project.self)
                } catch {
                    print("Error decoding project document \(document.documentID): \(error)")
                    // Optionally throw, log, or return nil depending on desired behavior for partial failures
                    return nil 
                }
            }
            
            print("Fetched \(projects.count) projects for collective \(collectiveID).")
            return projects
        } catch {
            print("Error fetching projects for collective \(collectiveID): \(error)")
            throw ProjectServiceError.firestoreError(error)
        }
    }

    // MARK: - Update Project (Example - Add more update functions as needed)
    // func updateProjectStatus(projectID: String, newStatus: ProjectStatus) async throws { ... }
    
    // MARK: - Delete Project (Example - Add if needed)
    // func deleteProject(projectID: String) async throws { ... }

}

// MARK: - Error Enum (Moved outside the class)
enum ProjectServiceError: Error {
    case firestoreError(Error)
    case projectNotFound
    case decodingError(Error)
    // Add other specific errors as needed
} 