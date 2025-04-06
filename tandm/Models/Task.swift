import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case blocked = "Blocked"
    case done = "Done"
    
    var id: String { self.rawValue }
}

struct TaskModel: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var assignedTo: String? // User UID
    var status: TaskStatus = .todo
    var dueDate: Timestamp? // Optional due date
    @ServerTimestamp var createdAt: Timestamp? // Auto-set by Firestore

    // Add other relevant fields like description, priority, etc. later if needed
}