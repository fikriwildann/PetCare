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

        // Cancel existing vaccine notifications first
        cancelVaccineReminders(for: vaccine.id)

        let now = Date()

        // Reminder 3 days before (only if future date)
        let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: nextDate)!
        if reminderDate > now {
            schedule(
                id: "vaccine-\(vaccine.id)",
                title: "⏰ Vaksin Akan Datang",
                body: "Vaksin \(vaccine.name) untuk \(petName) dijadwalkan dalam 3 hari!",
                date: reminderDate
            )
        }

        // Day-of reminder (only if future date)
        if nextDate > now {
            schedule(
                id: "vaccine-day-\(vaccine.id)",
                title: "💉 Hari Vaksin \(petName)!",
                body: "Jangan lupa vaksin \(vaccine.name) hari ini.",
                date: nextDate
            )
        }
    }

    // MARK: - Schedule Feeding Reminder
    func scheduleFeedingReminder(for feeding: FeedingSchedule, petName: String) {
        // Cancel existing notification first to avoid duplicates
        cancelReminder(id: "feeding-\(feeding.id)")

        // Calculate reminder time (10 minutes before feeding)
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -10, to: feeding.time) else { return }

        let now = Date()

        // Determine the next valid trigger date
        let scheduledDate: Date
        if reminderDate > now {
            // Reminder is still in the future today — use it directly
            scheduledDate = reminderDate
        } else {
            // Reminder time already passed today — schedule for tomorrow
            guard let tomorrowFeeding = Calendar.current.date(byAdding: .day, value: 1, to: feeding.time),
                  let tomorrowReminder = Calendar.current.date(byAdding: .minute, value: -10, to: tomorrowFeeding) else { return }
            scheduledDate = tomorrowReminder
        }

        schedule(
            id: "feeding-\(feeding.id)",
            title: "\(feeding.mealType.emoji) Waktunya Makan \(petName)!",
            body: "\(feeding.mealType.rawValue): \(feeding.foodName) — \(feeding.portion)",
            date: scheduledDate,
            repeats: true
        )
    }

    // MARK: - Schedule Medication Reminder
    func scheduleMedicationReminder(for med: Medication, petName: String) {
        // Skip if medication is not active
        guard med.isActive else { return }

        // Cancel existing medication notifications first
        cancelMedicationReminders(for: med.id, scheduleTimesCount: med.scheduleTimes.count)

        let now = Date()

        // Only schedule if startDate is in the past and endDate (if set) is in the future
        if med.startDate <= now {
            if let endDate = med.endDate, endDate < now {
                // Medication period has ended, don't schedule
                return
            }

            for (i, scheduleTime) in med.scheduleTimes.enumerated() {
                // For daily repeating, only schedule if the time hasn't passed today
                // or if endDate hasn't been reached
                var shouldSchedule = true
                if let endDate = med.endDate {
                    // Check if we should still be sending reminders
                    shouldSchedule = endDate > now
                }
                if shouldSchedule {
                    schedule(
                        id: "med-\(med.id)-\(i)",
                        title: "💊 Waktu Obat \(petName)",
                        body: "\(med.name) — \(med.dosage)",
                        date: scheduleTime,
                        repeats: true
                    )
                }
            }
        }
    }

    // MARK: - Cancel
    func cancelReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelVaccineReminders(for vaccineId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["vaccine-\(vaccineId)", "vaccine-day-\(vaccineId)"]
        )
    }

    func cancelMedicationReminders(for medId: UUID, scheduleTimesCount: Int) {
        let ids = (0..<scheduleTimesCount).map { "med-\(medId)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Reschedule All (for app launch)
    func rescheduleAllReminders(feedings: [FeedingSchedule], vaccines: [Vaccine], medications: [Medication], pets: [Pet]) {
        let petNames = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0.name) })

        for f in feedings {
            let name = petNames[f.petId] ?? "Hewan"
            scheduleFeedingReminder(for: f, petName: name)
        }

        for v in vaccines {
            let name = petNames[v.petId] ?? "Hewan"
            scheduleVaccineReminder(for: v, petName: name)
        }

        for m in medications {
            let name = petNames[m.petId] ?? "Hewan"
            scheduleMedicationReminder(for: m, petName: name)
        }
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
