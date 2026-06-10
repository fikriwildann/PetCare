// MARK: - PetModels.swift
// PetCare — All Data Models

import Foundation
import SwiftUI

// MARK: - Pet
struct Pet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: PetType
    var breed: String
    var birthDate: Date
    var gender: PetGender
    var weight: Double
    var photoName: String?
    var notes: String?
    var createdAt: Date = Date()

    var age: String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month], from: birthDate, to: Date())
        if let y = c.year, y > 0 { return "\(y) Tahun" }
        if let m = c.month, m > 0 { return "\(m) Bulan" }
        return "< 1 Bulan"
    }
}

enum PetType: String, Codable, CaseIterable, Hashable {
    case dog = "Anjing", cat = "Kucing", bird = "Burung", rabbit = "Kelinci", other = "Lainnya"
    var emoji: String {
        switch self {
        case .dog: "🐕"; case .cat: "🐱"; case .bird: "🐦"; case .rabbit: "🐇"; case .other: "🐾"
        }
    }
    var accent: Color {
        switch self {
        case .dog: .pcIndigo; case .cat: .pcOrange; case .bird: .pcCyan; case .rabbit: .pcGreen; case .other: .pcPurple
        }
    }
}

enum PetGender: String, Codable, CaseIterable {
    case male = "Jantan", female = "Betina"
    var symbol: String { self == .male ? "♂" : "♀" }
}

// MARK: - Pet Firestore Extensions
extension Pet {
    var toDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "type": type.rawValue,
            "breed": breed,
            "birthDate": birthDate.timeIntervalSince1970,
            "gender": gender.rawValue,
            "weight": weight,
            "photoName": photoName ?? "",
            "notes": notes ?? "",
            "createdAt": createdAt.timeIntervalSince1970
        ]
    }

    static func from(dictionary dict: [String: Any]) -> Pet? {
        guard let idString = dict["id"] as? String,
              let name = dict["name"] as? String,
              let typeRaw = dict["type"] as? String,
              let breed = dict["breed"] as? String,
              let birthDateInterval = dict["birthDate"] as? TimeInterval,
              let genderRaw = dict["gender"] as? String,
              let weight = dict["weight"] as? Double
        else { return nil }
        return Pet(
            id: UUID(uuidString: idString) ?? UUID(),
            name: name,
            type: PetType(rawValue: typeRaw) ?? .other,
            breed: breed,
            birthDate: Date(timeIntervalSince1970: birthDateInterval),
            gender: PetGender(rawValue: genderRaw) ?? .male,
            weight: weight,
            photoName: (dict["photoName"] as? String)?.isEmpty == true ? nil : dict["photoName"] as? String,
            notes: (dict["notes"] as? String)?.isEmpty == true ? nil : dict["notes"] as? String,
            createdAt: Date(timeIntervalSince1970: dict["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970)
        )
    }
}

// MARK: - Vaccine
struct Vaccine: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var name: String
    var date: Date
    var nextDate: Date?
    var clinic: String?
    var doctorName: String?
    var notes: String?

    var status: VaccineStatus {
        guard let next = nextDate else { return .done }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: next).day ?? 0
        if days < 0 { return .overdue }
        if days <= 7 { return .upcoming }
        return .done
    }
    var daysUntilNext: Int? {
        guard let next = nextDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: next).day
    }
}

enum VaccineStatus: String {
    case done = "Selesai", upcoming = "Akan Datang", overdue = "Terlambat"
    var color: Color {
        switch self { case .done: .pcGreen; case .upcoming: .pcOrange; case .overdue: .pcRed }
    }
    var icon: String {
        switch self { case .done: "checkmark.circle.fill"; case .upcoming: "clock.fill"; case .overdue: "exclamationmark.circle.fill" }
    }
}

// MARK: - Medication
struct Medication: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var name: String
    var dosage: String
    var frequency: MedFrequency
    var startDate: Date
    var endDate: Date?
    var scheduleTimes: [Date]
    var notes: String?
    var isActive: Bool = true

    var totalDays: Int? {
        guard let e = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: e).day
    }
    var daysCompleted: Int {
        max(0, Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0)
    }
    var progress: Double {
        guard let total = totalDays, total > 0 else { return 1.0 }
        return min(Double(daysCompleted) / Double(total), 1.0)
    }
}

enum MedFrequency: String, Codable, CaseIterable {
    case once = "1× sehari", twice = "2× sehari", thrice = "3× sehari"
    case asNeeded = "Bila perlu", continuous = "Berkelanjutan"
}

// MARK: - Feeding
struct FeedingSchedule: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var mealType: MealType
    var time: Date
    var foodName: String
    var portion: String
    var isCompleted: Bool = false
    var notes: String?
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Sarapan", lunch = "Makan Siang", dinner = "Makan Malam", snack = "Camilan"
    var id: String { rawValue }
    var emoji: String {
        switch self { case .breakfast: "🌅"; case .lunch: "☀️"; case .dinner: "🌙"; case .snack: "🍪" }
    }
    var color: Color {
        switch self { case .breakfast: .blue; case .lunch: .pcOrange; case .dinner: .pcPurple; case .snack: .pink }
    }
}

// MARK: - Health Record
struct HealthRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var date: Date
    var type: HealthRecordType
    var diagnosis: String
    var treatment: String?
    var doctorName: String?
    var clinic: String?
    var notes: String?
}

enum HealthRecordType: String, Codable, CaseIterable {
    case checkup = "Pemeriksaan Rutin", vaccination = "Vaksinasi"
    case treatment = "Pengobatan", surgery = "Operasi", grooming = "Grooming", other = "Lainnya"
    var emoji: String {
        switch self {
        case .checkup: "🏥"; case .vaccination: "💉"; case .treatment: "💊"
        case .surgery: "🔬"; case .grooming: "✂️"; case .other: "📋"
        }
    }
    var color: Color {
        switch self {
        case .checkup: .pcIndigo; case .vaccination: .pcGreen; case .treatment: .pcPurple
        case .surgery: .pcRed; case .grooming: .pcCyan; case .other: .gray
        }
    }
}

// MARK: - Weight
struct WeightRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var date: Date
    var weight: Double
    var notes: String?
}

// MARK: - Notification
struct AppNotification: Identifiable, Codable {
    var id: UUID = UUID()
    var type: NotificationType
    var title: String
    var message: String
    var date: Date
    var isRead: Bool = false
    var petId: UUID?
}

enum NotificationType: String, Codable {
    case vaccine = "Vaksin", feeding = "Makan", medication = "Obat"
    case healthCheck = "Pemeriksaan", general = "Umum"
    var emoji: String {
        switch self { case .vaccine: "💉"; case .feeding: "🍖"; case .medication: "💊"; case .healthCheck: "🏥"; case .general: "🔔" }
    }
    var color: Color {
        switch self { case .vaccine: .pcOrange; case .feeding: .pcGreen; case .medication: .pcPurple; case .healthCheck: .blue; case .general: .pcIndigo }
    }
}

// MARK: - User
struct AppUser: Codable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var profileImageName: String?
    var joinDate: Date = Date()
}
