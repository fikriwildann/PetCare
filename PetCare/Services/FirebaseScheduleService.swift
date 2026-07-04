// MARK: - FirebaseScheduleService.swift
// PetCare — Firestore CRUD for schedules (Feeding, Vaccine, Medication)

import Foundation
import FirebaseFirestore

final class FirebaseScheduleService: BaseFirebaseService {
    static let shared = FirebaseScheduleService()

    private override init() {}

    // MARK: - Feedings

    func addFeeding(_ feeding: FeedingSchedule) async throws {
        guard let userDoc = userDocument else { return }
        let data = feeding.toDictionary
        try await userDoc.collection("feedings").document(feeding.id.uuidString).setData(data)
    }

    func updateFeeding(_ feeding: FeedingSchedule) async throws {
        guard let userDoc = userDocument else { return }
        let data = feeding.toDictionary
        try await userDoc.collection("feedings").document(feeding.id.uuidString).updateData(data)
    }

    func deleteFeeding(id: UUID) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("feedings").document(id.uuidString).delete()
    }

    func deleteAllFeedings(for petId: UUID) async throws {
        guard let userDoc = userDocument else { return }
        let snapshot = try await userDoc.collection("feedings")
            .whereField("petId", isEqualTo: petId.uuidString).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }

    func toggleFeedingComplete(id: UUID, isCompleted: Bool) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("feedings").document(id.uuidString).updateData(["isCompleted": isCompleted])
    }

    func loadFeedings() async throws -> [FeedingSchedule] {
        guard let userDoc = userDocument else { return [] }
        let snapshot = try await userDoc.collection("feedings").getDocuments()
        return snapshot.documents.compactMap { FeedingSchedule.from(dictionary: $0.data()) }
    }

    // MARK: - Vaccines

    func addVaccine(_ vaccine: Vaccine) async throws {
        guard let userDoc = userDocument else { return }
        let data = vaccine.toDictionary
        try await userDoc.collection("vaccines").document(vaccine.id.uuidString).setData(data)
    }

    func updateVaccine(_ vaccine: Vaccine) async throws {
        guard let userDoc = userDocument else { return }
        let data = vaccine.toDictionary
        try await userDoc.collection("vaccines").document(vaccine.id.uuidString).updateData(data)
    }

    func deleteVaccine(id: UUID) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("vaccines").document(id.uuidString).delete()
    }

    func deleteAllVaccines(for petId: UUID) async throws {
        guard let userDoc = userDocument else { return }
        let snapshot = try await userDoc.collection("vaccines")
            .whereField("petId", isEqualTo: petId.uuidString).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }

    func loadVaccines() async throws -> [Vaccine] {
        guard let userDoc = userDocument else { return [] }
        let snapshot = try await userDoc.collection("vaccines").getDocuments()
        return snapshot.documents.compactMap { Vaccine.from(dictionary: $0.data()) }
    }

    // MARK: - Medications

    func addMedication(_ medication: Medication) async throws {
        guard let userDoc = userDocument else { return }
        let data = medication.toDictionary
        try await userDoc.collection("medications").document(medication.id.uuidString).setData(data)
    }

    func updateMedication(_ medication: Medication) async throws {
        guard let userDoc = userDocument else { return }
        let data = medication.toDictionary
        try await userDoc.collection("medications").document(medication.id.uuidString).updateData(data)
    }

    func deleteMedication(id: UUID) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("medications").document(id.uuidString).delete()
    }

    func deleteAllMedications(for petId: UUID) async throws {
        guard let userDoc = userDocument else { return }
        let snapshot = try await userDoc.collection("medications")
            .whereField("petId", isEqualTo: petId.uuidString).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }

    func loadMedications() async throws -> [Medication] {
        guard let userDoc = userDocument else { return [] }
        let snapshot = try await userDoc.collection("medications").getDocuments()
        return snapshot.documents.compactMap { Medication.from(dictionary: $0.data()) }
    }
}
