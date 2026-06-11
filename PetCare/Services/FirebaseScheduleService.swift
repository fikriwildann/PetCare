// MARK: - FirebaseScheduleService.swift
// PetCare — Firestore CRUD for schedules (Feeding, Vaccine, Medication)

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseScheduleService {
    static let shared = FirebaseScheduleService()
    private let db = Firestore.firestore()

    private init() {}

    private func userDocument() -> DocumentReference? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        return db.collection("users").document(userId)
    }

    // MARK: - Feedings

    func addFeeding(_ feeding: FeedingSchedule) async throws {
        guard let userDoc = userDocument() else { return }
        var data = feeding.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("feedings").document(feeding.id.uuidString).setData(data)
    }

    func updateFeeding(_ feeding: FeedingSchedule) async throws {
        guard let userDoc = userDocument() else { return }
        var data = feeding.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("feedings").document(feeding.id.uuidString).updateData(data)
    }

    func deleteFeeding(id: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        try await userDoc.collection("feedings").document(id.uuidString).delete()
    }

    func toggleFeedingComplete(id: UUID, isCompleted: Bool) async throws {
        guard let userDoc = userDocument() else { return }
        try await userDoc.collection("feedings").document(id.uuidString).updateData(["isCompleted": isCompleted])
    }

    func loadFeedings() async throws -> [FeedingSchedule] {
        guard let userDoc = userDocument() else { return [] }
        let snapshot = try await userDoc.collection("feedings").getDocuments()
        return snapshot.documents.compactMap { FeedingSchedule.from(dictionary: $0.data()) }
    }

    // MARK: - Vaccines

    func addVaccine(_ vaccine: Vaccine) async throws {
        guard let userDoc = userDocument() else { return }
        var data = vaccine.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("vaccines").document(vaccine.id.uuidString).setData(data)
    }

    func updateVaccine(_ vaccine: Vaccine) async throws {
        guard let userDoc = userDocument() else { return }
        var data = vaccine.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("vaccines").document(vaccine.id.uuidString).updateData(data)
    }

    func deleteVaccine(id: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        try await userDoc.collection("vaccines").document(id.uuidString).delete()
    }

    func loadVaccines() async throws -> [Vaccine] {
        guard let userDoc = userDocument() else { return [] }
        let snapshot = try await userDoc.collection("vaccines").getDocuments()
        return snapshot.documents.compactMap { Vaccine.from(dictionary: $0.data()) }
    }

    // MARK: - Medications

    func addMedication(_ medication: Medication) async throws {
        guard let userDoc = userDocument() else { return }
        var data = medication.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("medications").document(medication.id.uuidString).setData(data)
    }

    func updateMedication(_ medication: Medication) async throws {
        guard let userDoc = userDocument() else { return }
        var data = medication.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("medications").document(medication.id.uuidString).updateData(data)
    }

    func deleteMedication(id: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        try await userDoc.collection("medications").document(id.uuidString).delete()
    }

    func loadMedications() async throws -> [Medication] {
        guard let userDoc = userDocument() else { return [] }
        let snapshot = try await userDoc.collection("medications").getDocuments()
        return snapshot.documents.compactMap { Medication.from(dictionary: $0.data()) }
    }
}

// MARK: - Encodable Extensions

extension FeedingSchedule {
    var toDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "petId": petId.uuidString,
            "mealType": mealType.rawValue,
            "time": time.timeIntervalSince1970,
            "foodName": foodName,
            "portion": portion,
            "isCompleted": isCompleted,
            "notes": notes ?? ""
        ]
    }

    static func from(dictionary dict: [String: Any]) -> FeedingSchedule? {
        guard let idString = dict["id"] as? String,
              let petIdString = dict["petId"] as? String,
              let mealTypeRaw = dict["mealType"] as? String,
              let timeInterval = dict["time"] as? TimeInterval,
              let foodName = dict["foodName"] as? String,
              let portion = dict["portion"] as? String
        else { return nil }
        return FeedingSchedule(
            id: UUID(uuidString: idString) ?? UUID(),
            petId: UUID(uuidString: petIdString) ?? UUID(),
            mealType: MealType(rawValue: mealTypeRaw) ?? .breakfast,
            time: Date(timeIntervalSince1970: timeInterval),
            foodName: foodName,
            portion: portion,
            isCompleted: dict["isCompleted"] as? Bool ?? false,
            notes: dict["notes"] as? String
        )
    }
}

extension Vaccine {
    var toDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "petId": petId.uuidString,
            "name": name,
            "date": date.timeIntervalSince1970,
            "clinic": clinic ?? "",
            "doctorName": doctorName ?? "",
            "notes": notes ?? ""
        ]
        if let next = nextDate { dict["nextDate"] = next.timeIntervalSince1970 }
        return dict
    }

    static func from(dictionary dict: [String: Any]) -> Vaccine? {
        guard let idString = dict["id"] as? String,
              let petIdString = dict["petId"] as? String,
              let name = dict["name"] as? String,
              let dateInterval = dict["date"] as? TimeInterval
        else { return nil }
        return Vaccine(
            id: UUID(uuidString: idString) ?? UUID(),
            petId: UUID(uuidString: petIdString) ?? UUID(),
            name: name,
            date: Date(timeIntervalSince1970: dateInterval),
            nextDate: (dict["nextDate"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) },
            clinic: (dict["clinic"] as? String)?.isEmpty == true ? nil : dict["clinic"] as? String,
            doctorName: (dict["doctorName"] as? String)?.isEmpty == true ? nil : dict["doctorName"] as? String,
            notes: (dict["notes"] as? String)?.isEmpty == true ? nil : dict["notes"] as? String
        )
    }
}

extension Medication {
    var toDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "petId": petId.uuidString,
            "name": name,
            "dosage": dosage,
            "frequency": frequency.rawValue,
            "startDate": startDate.timeIntervalSince1970,
            "scheduleTimes": scheduleTimes.map { $0.timeIntervalSince1970 },
            "notes": notes ?? "",
            "isActive": isActive
        ]
        if let end = endDate { dict["endDate"] = end.timeIntervalSince1970 }
        return dict
    }

    static func from(dictionary dict: [String: Any]) -> Medication? {
        guard let idString = dict["id"] as? String,
              let petIdString = dict["petId"] as? String,
              let name = dict["name"] as? String,
              let dosage = dict["dosage"] as? String,
              let frequencyRaw = dict["frequency"] as? String,
              let startInterval = dict["startDate"] as? TimeInterval,
              let scheduleTimesIntervals = dict["scheduleTimes"] as? [TimeInterval]
        else { return nil }
        return Medication(
            id: UUID(uuidString: idString) ?? UUID(),
            petId: UUID(uuidString: petIdString) ?? UUID(),
            name: name,
            dosage: dosage,
            frequency: MedFrequency(rawValue: frequencyRaw) ?? .once,
            startDate: Date(timeIntervalSince1970: startInterval),
            endDate: (dict["endDate"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) },
            scheduleTimes: scheduleTimesIntervals.map { Date(timeIntervalSince1970: $0) },
            notes: (dict["notes"] as? String)?.isEmpty == true ? nil : dict["notes"] as? String,
            isActive: dict["isActive"] as? Bool ?? true
        )
    }
}