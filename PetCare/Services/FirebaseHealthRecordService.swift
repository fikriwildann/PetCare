// MARK: - FirebaseHealthRecordService.swift
// PetCare — Firestore CRUD for Health Records

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseHealthRecordService {
    static let shared = FirebaseHealthRecordService()
    private let db = Firestore.firestore()

    private init() {}

    private func userDocument() -> DocumentReference? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        return db.collection("users").document(userId)
    }

    func addHealthRecord(_ record: HealthRecord) async throws {
        guard let userDoc = userDocument() else { return }
        let data = record.toDictionary
        try await userDoc.collection("healthRecords").document(record.id.uuidString).setData(data)
    }

    func updateHealthRecord(_ record: HealthRecord) async throws {
        guard let userDoc = userDocument() else { return }
        let data = record.toDictionary
        try await userDoc.collection("healthRecords").document(record.id.uuidString).updateData(data)
    }

    func deleteHealthRecord(id: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        try await userDoc.collection("healthRecords").document(id.uuidString).delete()
    }

    func deleteAllHealthRecords(for petId: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        let snapshot = try await userDoc.collection("healthRecords")
            .whereField("petId", isEqualTo: petId.uuidString).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }

    func loadHealthRecords() async throws -> [HealthRecord] {
        guard let userDoc = userDocument() else { return [] }
        let snapshot = try await userDoc.collection("healthRecords").getDocuments()
        return snapshot.documents.compactMap { HealthRecord.from(dictionary: $0.data()) }
    }
}

// MARK: - HealthRecord Extensions

extension HealthRecord {
    var toDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "petId": petId.uuidString,
            "type": type.rawValue,
            "date": date.timeIntervalSince1970,
            "diagnosis": diagnosis
        ]
        if let treatment = treatment { dict["treatment"] = treatment }
        if let doctorName = doctorName { dict["doctorName"] = doctorName }
        if let clinic = clinic { dict["clinic"] = clinic }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }

    static func from(dictionary dict: [String: Any]) -> HealthRecord? {
        guard let idString = dict["id"] as? String,
              let petIdString = dict["petId"] as? String,
              let typeRaw = dict["type"] as? String,
              let dateInterval = dict["date"] as? TimeInterval,
              let diagnosis = dict["diagnosis"] as? String
        else { return nil }
        return HealthRecord(
            id: UUID(uuidString: idString) ?? UUID(),
            petId: UUID(uuidString: petIdString) ?? UUID(),
            date: Date(timeIntervalSince1970: dateInterval),
            type: HealthRecordType(rawValue: typeRaw) ?? .checkup,
            diagnosis: diagnosis,
            treatment: dict["treatment"] as? String,
            doctorName: dict["doctorName"] as? String,
            clinic: dict["clinic"] as? String,
            notes: dict["notes"] as? String
        )
    }
}