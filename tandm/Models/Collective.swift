import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Collective: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    var name: String
    var members: [String] // Array of user UIDs
    var clientFacingName: String?
    var createdBy: String // UID of the user who created the collective
    var publicPageSlug: String?
    var createdAt: Timestamp?

    // Conform to Codable for Firestore integration
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members
        case clientFacingName
        case createdBy
        case publicPageSlug
        case createdAt
    }

    // Optional: Initializer for convenience
    init(id: String? = nil, name: String, members: [String], clientFacingName: String? = nil, createdBy: String, publicPageSlug: String? = nil, createdAt: Timestamp? = Timestamp(date: Date())) {
        self.id = id
        self.name = name
        self.members = members
        self.clientFacingName = clientFacingName
        self.createdBy = createdBy
        self.publicPageSlug = publicPageSlug
        self.createdAt = createdAt
    }
} 