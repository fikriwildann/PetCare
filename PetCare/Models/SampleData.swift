// MARK: - SampleData.swift
// PetCare — Dummy data for development & SwiftUI Previews

import Foundation
import SwiftUI

struct SampleData {

    // MARK: User
    static let user = AppUser(id: "sample_user_id", name: "Fikri Nuswantara", email: "fikri@dinuswantara.ac.id")

    // MARK: Pets
    static let buddy = Pet(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        name: "Buddy", type: .dog, breed: "Golden Retriever",
        birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
        gender: .male, weight: 28.5, notes: "Aktif dan suka bermain di luar")

    static let luna = Pet(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
        name: "Luna", type: .cat, breed: "Persian Cat",
        birthDate: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
        gender: .female, weight: 4.2, notes: "Suka tidur di sofa")

    static let mochi = Pet(
        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
        name: "Mochi", type: .rabbit, breed: "Holland Lop",
        birthDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
        gender: .male, weight: 1.8, notes: "Suka wortel dan daun selada")

    static let pets: [Pet] = [buddy, luna, mochi]

    // MARK: Vaccines
    static let vaccines: [Vaccine] = [
        Vaccine(petId: buddy.id, name: "Vaksin Rabies",
                date: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                nextDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
                clinic: "Klinik Hewan Sehat", doctorName: "Dr. Hendra"),
        Vaccine(petId: buddy.id, name: "Distemper",
                date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                nextDate: Calendar.current.date(byAdding: .month, value: 11, to: Date()),
                clinic: "Petcare Clinic", doctorName: "Dr. Sari"),
        Vaccine(petId: luna.id, name: "Distemper",
                date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                nextDate: Calendar.current.date(byAdding: .month, value: 11, to: Date()),
                clinic: "Klinik Hewan Sehat", doctorName: "Dr. Hendra"),
        Vaccine(petId: mochi.id, name: "Vaksin RHDV",
                date: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
                nextDate: Calendar.current.date(byAdding: .day, value: -4, to: Date()),
                clinic: "Rabbit Care Clinic")
    ]

    // MARK: Medications
    static let medications: [Medication] = [
        Medication(petId: buddy.id, name: "Amoxicillin", dosage: "0.5 tablet",
                   frequency: .twice,
                   startDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                   endDate: Calendar.current.date(byAdding: .day, value: 6, to: Date()),
                   scheduleTimes: [
                    Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!,
                    Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
                   ], notes: "Diberikan bersama makanan", isActive: true),
        Medication(petId: mochi.id, name: "Vitamin C", dosage: "25 mg",
                   frequency: .once,
                   startDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                   endDate: nil,
                   scheduleTimes: [
                    Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
                   ], notes: "Kelinci tidak bisa memproduksi Vitamin C sendiri", isActive: true),
        Medication(petId: luna.id, name: "Antifungal Krim", dosage: "Oleskan tipis",
                   frequency: .twice,
                   startDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                   endDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
                   scheduleTimes: [], isActive: false)
    ]

    // MARK: Feedings
    static let feedings: [FeedingSchedule] = [
        FeedingSchedule(petId: buddy.id, mealType: .breakfast,
                        time: Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!,
                        foodName: "Dry Food Premium", portion: "200 gram", isCompleted: true),
        FeedingSchedule(petId: buddy.id, mealType: .lunch,
                        time: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!,
                        foodName: "Wet Food Mix", portion: "150 gram", isCompleted: true),
        FeedingSchedule(petId: buddy.id, mealType: .dinner,
                        time: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!,
                        foodName: "Dry Food Premium", portion: "200 gram", isCompleted: false),
        FeedingSchedule(petId: luna.id, mealType: .breakfast,
                        time: Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!,
                        foodName: "Royal Canin Persian", portion: "60 gram", isCompleted: true),
        FeedingSchedule(petId: luna.id, mealType: .dinner,
                        time: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
                        foodName: "Royal Canin Persian", portion: "60 gram", isCompleted: false),
        FeedingSchedule(petId: mochi.id, mealType: .breakfast,
                        time: Calendar.current.date(bySettingHour: 7,  minute: 0, second: 0, of: Date())!,
                        foodName: "Hay Timothy + Sayuran", portion: "Ad libitum", isCompleted: true),
        FeedingSchedule(petId: mochi.id, mealType: .lunch,
                        time: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!,
                        foodName: "Hay Timothy + Wortel", portion: "Ad libitum", isCompleted: false)
    ]

    // MARK: Health Records
    static let healthRecords: [HealthRecord] = [
        HealthRecord(petId: buddy.id,
                     date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                     type: .checkup, diagnosis: "Sehat, kondisi prima",
                     treatment: "Amoxicillin 0.5 tab 2× sehari 10 hari",
                     doctorName: "Dr. Hendra", clinic: "Klinik Hewan Sehat",
                     notes: "Berat 28.5 kg, gigi bersih, mata cerah"),
        HealthRecord(petId: buddy.id,
                     date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                     type: .vaccination, diagnosis: "Vaksinasi Distemper booster tahunan",
                     doctorName: "Dr. Sari", clinic: "Petcare Clinic",
                     notes: "Reaksi normal, tidak ada efek samping"),
        HealthRecord(petId: buddy.id,
                     date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                     type: .checkup, diagnosis: "Sedikit kegemukan",
                     treatment: "Diet khusus, kurangi porsi 20%",
                     doctorName: "Dr. Hendra", clinic: "Klinik Hewan Sehat"),
        HealthRecord(petId: luna.id,
                     date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                     type: .treatment, diagnosis: "Infeksi jamur ringan di kulit",
                     treatment: "Antifungal krim 2× sehari 4 minggu",
                     doctorName: "Dr. Ratna", clinic: "Cat Specialist Clinic")
    ]

    // MARK: Weight Records
    static func weights(for petId: UUID) -> [WeightRecord] {
        guard petId == buddy.id else { return [] }
        let months = [-5, -4, -3, -2, -1, 0]
        let vals: [Double] = [26.5, 27.2, 27.3, 28.1, 27.8, 28.5]
        return zip(months, vals).map { m, w in
            WeightRecord(petId: petId,
                         date: Calendar.current.date(byAdding: .month, value: m, to: Date())!,
                         weight: w)
        }
    }

    // MARK: Notifications
    static let notifications: [AppNotification] = [
        AppNotification(type: .vaccine, title: "Vaksin Rabies Buddy",
                        message: "Jadwal vaksin 2 hari lagi (7 Jun)",
                        date: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
                        isRead: false, petId: buddy.id),
        AppNotification(type: .vaccine, title: "Vaksin RHDV Mochi Terlambat",
                        message: "Sudah 4 hari melewati jadwal",
                        date: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
                        isRead: false, petId: mochi.id),
        AppNotification(type: .feeding, title: "Sarapan Luna ✓",
                        message: "Telah diberikan pukul 08:00",
                        date: Calendar.current.date(bySettingHour: 8, minute: 5, second: 0, of: Date())!,
                        isRead: true, petId: luna.id),
        AppNotification(type: .medication, title: "Antibiotik Buddy",
                        message: "Dosis malam telah diberikan",
                        date: Calendar.current.date(byAdding: .day, value: -1,
                                to: Calendar.current.date(bySettingHour: 19, minute: 2, second: 0, of: Date())!)!,
                        isRead: true, petId: buddy.id)
    ]
}
