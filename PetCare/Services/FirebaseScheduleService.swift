// MARK: - FirebaseScheduleService.swift
// PetCare — Firestore CRUD for schedules (Feeding, Vaccine, Medication)

import Foundation
import FirebaseFirestore

final class FirebaseScheduleService {
    static let shared = FirebaseScheduleService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Feedings

    func addFeeding(_ feeding: FeedingSchedule) async throws {
        let doc = Firestore.firestore().collection("feedings").document(feeding.id.uuidString)
        try await doc.setData(feeding.toDictionary)
    }

    func updateFeeding(_ feeding: FeedingSchedule) async throws {
        let doc = Firestore.firestore().collection("feedings").document(feeding.id.uuidString)
        try await doc.updateData(feeding.toDictionary)
    }

    func deleteFeeding(id: UUID) async throws {
        let doc = Firestore.firestore().collection("feedings").document(id.uuidString)
        try await doc.delete()
    }

    func toggleFeedingComplete(id: UUID, isCompleted: Bool) async throws {
        let doc = Firestore.firestore().collection("feedings").document(id.uuidString)
        try await doc.updateData(["isCompleted": isCompleted])
    }

    func loadFeedings() async throws -> [FeedingSchedule] {
        let snapshot = try await Firestore.firestore().collection("feedings").getDocuments()
        return snapshot.documents.compactMap { FeedingSchedule.from(dictionary: $0.data()) }
    }

    // MARK: - Vaccines

    func addVaccine(_ vaccine: Vaccine) async throws {
        let doc = Firestore.firestore().collection("vaccines").document(vaccine.id.uuidString)
        try await doc.setData(vaccine.toDictionary)
    }

    func updateVaccine(_ vaccine: Vaccine) async throws {
        let doc = Firestore.firestore().collection("vaccines").document(vaccine.id.uuidString)
        try await doc.updateData(vaccine.toDictionary)
    }

    func deleteVaccine(id: UUID) async throws {
        let doc = Firestore.firestore().collection("vaccines").document(id.uuidString)
        try await doc.delete()
    }

    func loadVaccines() async throws -> [Vaccine] {
        let snapshot = try await Firestore.firestore().collection("vaccines").getDocuments()
        return snapshot.documents.compactMap { Vaccine.from(dictionary: $0.data()) }
    }

    // MARK: - Medications

    func addMedication(_ medication: Medication) async throws {
        let doc = Firestore.firestore().collection("medications").document(medication.id.uuidString)
        try await doc.setData(medication.toDictionary)
    }

    func updateMedication(_ medication: Medication) async throws {
        let doc = Firestore.firestore().collection("medications").document(medication.id.uuidString)
        try await doc.updateData(medication.toDictionary)
    }

    func deleteMedication(id: UUID) async throws {
        let doc = Firestore.firestore().collection("medications").document(id.uuidString)
        try await doc.delete()
    }

    func loadMedications() async throws -> [Medication] {
        let snapshot = try await Firestore.firestore().collection("medications").getDocuments()
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
