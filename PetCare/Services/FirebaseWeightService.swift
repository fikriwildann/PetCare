// MARK: - FirebaseWeightService.swift
// PetCare — Firestore CRUD for Weight Records

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseWeightService {
    static let shared = FirebaseWeightService()
    private let db = Firestore.firestore()

    private init() {}

    private func userDocument() -> DocumentReference? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(userId)
    }

    func addWeight(_ record: WeightRecord) async throws {
        guard let userDoc = userDocument() else { return }
        var data = record.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("weights").document(record.id.uuidString).setData(data)
    }

    func updateWeight(_ record: WeightRecord) async throws {
        guard let userDoc = userDocument() else { return }
        var data = record.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("weights").document(record.id.uuidString).updateData(data)
    }

    func deleteWeight(id: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        try await userDoc.collection("weights").document(id.uuidString).delete()
    }

    func deleteAllWeights(for petId: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        let snapshot = try await userDoc.collection("weights")
            .whereField("petId", isEqualTo: petId.uuidString).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }

    func loadWeights() async throws -> [WeightRecord] {
        guard let userDoc = userDocument() else { return [] }
        let snapshot = try await userDoc.collection("weights").getDocuments()
        return snapshot.documents.compactMap { WeightRecord.from(dictionary: $0.data()) }
    }
}

// MARK: - WeightRecord Codable Extensions

extension WeightRecord {
    var toDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "petId": petId.uuidString,
            "date": date.timeIntervalSince1970,
            "weight": weight
        ]
        if let notes = notes { dict["notes"] = notes }
        return dict
    }

    static func from(dictionary dict: [String: Any]) -> WeightRecord? {
        guard let idString = dict["id"] as? String,
              let petIdString = dict["petId"] as? String,
              let dateInterval = dict["date"] as? TimeInterval,
              let weight = dict["weight"] as? Double
        else { return nil }
        return WeightRecord(
            id: UUID(uuidString: idString) ?? UUID(),
            petId: UUID(uuidString: petIdString) ?? UUID(),
            date: Date(timeIntervalSince1970: dateInterval),
            weight: weight,
            notes: dict["notes"] as? String
        )
    }
}