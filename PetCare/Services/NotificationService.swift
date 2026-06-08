// MARK: - NotificationService.swift
// PetCare — Local Notification Scheduling

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("❌ Notification permission error: \(error)")
            return false
        }
    }

    // MARK: - Schedule Vaccine Reminder
    func scheduleVaccineReminder(for vaccine: Vaccine, petName: String) {
        guard let nextDate = vaccine.nextDate else { return }

        // Reminder 3 days before
        let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: nextDate)!
        schedule(
            id: "vaccine-\(vaccine.id)",
            title: "⏰ Vaksin Akan Datang",
            body: "Vaksin \(vaccine.name) untuk \(petName) dijadwalkan dalam 3 hari!",
            date: reminderDate
        )

        // Day-of reminder
        schedule(
            id: "vaccine-day-\(vaccine.id)",
            title: "💉 Hari Vaksin \(petName)!",
            body: "Jangan lupa vaksin \(vaccine.name) hari ini.",
            date: nextDate
        )
    }

    // MARK: - Schedule Feeding Reminder
    func scheduleFeedingReminder(for feeding: FeedingSchedule, petName: String) {
        // 10 minutes before feeding time
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -10, to: feeding.time)!
        schedule(
            id: "feeding-\(feeding.id)",
            title: "\(feeding.mealType.emoji) Waktunya Makan \(petName)!",
            body: "\(feeding.mealType.rawValue): \(feeding.foodName) — \(feeding.portion)",
            date: reminderDate,
            repeats: true
        )
    }

    // MARK: - Schedule Medication Reminder
    func scheduleMedicationReminder(for med: Medication, petName: String) {
        for (i, scheduleTime) in med.scheduleTimes.enumerated() {
            schedule(
                id: "med-\(med.id)-\(i)",
                title: "💊 Waktu Obat \(petName)",
                body: "\(med.name) — \(med.dosage)",
                date: scheduleTime,
                repeats: true
            )
        }
    }

    // MARK: - Cancel
    func cancelReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Core scheduler
    private func schedule(id: String, title: String, body: String,
                           date: Date, repeats: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        var components = Calendar.current.dateComponents(
            repeats ? [.hour, .minute] : [.year, .month, .day, .hour, .minute],
            from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("❌ Notification schedule error: \(error)") }
        }
    }
}
