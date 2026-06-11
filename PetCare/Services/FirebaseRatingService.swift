// MARK: - FirebaseRatingService.swift
// PetCare — Rating Firebase Service

import Foundation
import FirebaseFirestore

final class FirebaseRatingService {
    static let shared = FirebaseRatingService()
    private let db = Firestore.firestore()

    private init() {}

    struct Rating: Codable {
        var id: UUID = UUID()
        var userId: String
        var userName: String
        var rating: Int
        var review: String?
        var createdAt: Date = Date()
    }

    func submitRating(_ rating: Rating) async throws {
        let doc = db.collection("ratings").document(rating.id.uuidString)
        try await doc.setData(rating.toDictionary)
    }

    func loadRatings() async throws -> [Rating] {
        let snapshot = try await db.collection("ratings")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { Rating.from(dictionary: $0.data()) }
    }

    func getAverageRating() async throws -> Double {
        let snapshot = try await db.collection("ratings").getDocuments()
        let ratings = snapshot.documents.compactMap { Rating.from(dictionary: $0.data()) }
        guard !ratings.isEmpty else { return 0 }
        let total = ratings.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(ratings.count)
    }
}

extension FirebaseRatingService.Rating {
    var toDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "userId": userId,
            "userName": userName,
            "rating": rating,
            "createdAt": createdAt.timeIntervalSince1970
        ]
        if let review = review {
            dict["review"] = review
        }
        return dict
    }

    static func from(dictionary dict: [String: Any]) -> FirebaseRatingService.Rating? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let userId = dict["userId"] as? String,
              let userName = dict["userName"] as? String,
              let rating = dict["rating"] as? Int else {
            return nil
        }

        let review = dict["review"] as? String
        let createdAt = dict["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970

        return FirebaseRatingService.Rating(
            id: id,
            userId: userId,
            userName: userName,
            rating: rating,
            review: review,
            createdAt: Date(timeIntervalSince1970: createdAt)
        )
    }
}
