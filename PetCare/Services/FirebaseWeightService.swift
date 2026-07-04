// MARK: - FirebaseWeightService.swift
// PetCare — Firestore CRUD for Weight Records

import Foundation
import FirebaseFirestore

final class FirebaseWeightService: BaseFirebaseService {
    static let shared = FirebaseWeightService()

    private override init() {}

    func addWeight(_ record: WeightRecord) async throws {
        guard let userDoc = userDocument else { return }
        let data = record.toDictionary
        try await userDoc.collection("weights").document(record.id.uuidString).setData(data)
    }

    func updateWeight(_ record: WeightRecord) async throws {
        guard let userDoc = userDocument else { return }
        let data = record.toDictionary
        try await userDoc.collection("weights").document(record.id.uuidString).updateData(data)
    }

    func deleteWeight(id: UUID) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("weights").document(id.uuidString).delete()
    }

    func deleteAllWeights(for petId: UUID) async throws {
        guard let userDoc = userDocument else { return }
        let snapshot = try await userDoc.collection("weights")
            .whereField("petId", isEqualTo: petId.uuidString).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }

    func loadWeights() async throws -> [WeightRecord] {
        guard let userDoc = userDocument else { return [] }
        let snapshot = try await userDoc.collection("weights").getDocuments()
        return snapshot.documents.compactMap { WeightRecord.from(dictionary: $0.data()) }
    }
}
