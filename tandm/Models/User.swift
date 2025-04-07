import Foundation
import FirebaseFirestore // Import Firestore

struct User: Identifiable, Codable, Equatable {
    // Use documentID property wrapper for Firestore document ID mapping
    @DocumentID var id: String? // Maps the Firestore document ID to this property. Optional because it's not set until fetched/saved.
    
    // Make uid optional, as it might not be set immediately.
    // It should correspond to the Auth UID and potentially the document ID.
    var uid: String?
    var name: String
    var email: String // Should be non-optional as it's used for auth
    var bio: String? // Optional fields
    var skills: [String]?
    var portfolioUrl: String?
    var profileImage: String? // Path or URL to the image
    var createdAt: Timestamp? // Use Firestore Timestamp

    // CodingKeys for mapping Firestore field names if they differ or for clarity
    enum CodingKeys: String, CodingKey {
        case id // If using @DocumentID, it's often excluded or handled specially
        case uid
        case name
        case email
        case bio
        case skills
        case portfolioUrl = "portfolioUrl" // Explicit mapping
        case profileImage = "profileImage"
        case createdAt = "createdAt"
    }
    
    // Provide a default initializer if needed, especially if making properties optional
    // or if you want a convenience init
    init(id: String? = nil, uid: String? = nil, name: String, email: String, bio: String? = nil, skills: [String]? = nil, portfolioUrl: String? = nil, profileImage: String? = nil, createdAt: Timestamp? = Timestamp(date: Date())) {
        self.id = id // Allow setting id directly if needed
        self.uid = uid
        self.name = name
        self.email = email
        self.bio = bio
        self.skills = skills
        self.portfolioUrl = portfolioUrl
        self.profileImage = profileImage
        self.createdAt = createdAt
    }
} 