// MARK: - FirebaseHealthRecordService.swift
// PetCare — Firestore CRUD for Health Records

import Foundation
import FirebaseFirestore

final class FirebaseHealthRecordService: BaseFirebaseService {
    static let shared = FirebaseHealthRecordService()

    private override init() {}

    func addHealthRecord(_ record: HealthRecord) async throws {
        guard let userDoc = userDocument else { return }
        let data = record.toDictionary
        try await userDoc.collection("healthRecords").document(record.id.uuidString).setData(data)
    }

    func updateHealthRecord(_ record: HealthRecord) async throws {
        guard let userDoc = userDocument else { return }
        let data = record.toDictionary
        try await userDoc.collection("healthRecords").document(record.id.uuidString).updateData(data)
    }

    func deleteHealthRecord(id: UUID) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("healthRecords").document(id.uuidString).delete()
    }

    func deleteAllHealthRecords(for petId: UUID) async throws {
        guard let userDoc = userDocument else { return }
        let snapshot = try await userDoc.collection("healthRecords")
            .whereField("petId", isEqualTo: petId.uuidString).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }

    func loadHealthRecords() async throws -> [HealthRecord] {
        guard let userDoc = userDocument else { return [] }
        let snapshot = try await userDoc.collection("healthRecords").getDocuments()
        return snapshot.documents.compactMap { HealthRecord.from(dictionary: $0.data()) }
    }
}
