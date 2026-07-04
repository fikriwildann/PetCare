// MARK: - FirebaseRatingService.swift
// PetCare — Rating Firebase Service

import Foundation
import FirebaseFirestore

final class FirebaseRatingService: BaseFirebaseService {
    static let shared = FirebaseRatingService()

    private override init() {}

    func submitRating(_ rating: Rating) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("ratings").document(rating.id.uuidString).setData(rating.toDictionary)
    }

    func loadRatings() async throws -> [Rating] {
        guard let userDoc = userDocument else { return [] }
        let snapshot = try await userDoc.collection("ratings")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { Rating.from(dictionary: $0.data()) }
    }

    func getAverageRating() async throws -> Double {
        guard let userDoc = userDocument else { return 0 }
        let snapshot = try await userDoc.collection("ratings").getDocuments()
        let ratings = snapshot.documents.compactMap { Rating.from(dictionary: $0.data()) }
        guard !ratings.isEmpty else { return 0 }
        let total = ratings.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(ratings.count)
    }
}
