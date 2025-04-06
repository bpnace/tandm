import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Enum for Project Status
enum ProjectStatus: String, Codable, CaseIterable {
    case planning = "planning"
    case active = "active"
    case onHold = "on_hold"
    case completed = "completed"
    case archived = "archived"
    // Add more statuses as needed
}

struct Project: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID, maps automatically
    let title: String
    let description: String
    let collectiveId: String      // ID of the collective this project belongs to
    // let tasks: [Task]          // For MVP, keep simple. Add Task model later if needed.
    var status: ProjectStatus     // Use the enum for status
    let startDate: Timestamp      // Use Firestore Timestamp for dates
    var endDate: Timestamp?       // Optional end date
    @ServerTimestamp var createdAt: Timestamp? // Firestore automatically sets this on creation

    // Conformance to Identifiable requires 'id'. Optional because it's nil before saving.
    
    // Add computed properties or methods if needed, e.g., for duration calculation
} 