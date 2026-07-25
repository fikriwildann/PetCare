// MARK: - NotificationService.swift
// PetCare — Local Notification Scheduling

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // MARK: - UserDefaults Keys
    private enum PrefsKey {
        static let vaccineNotif = "notif_vaccine_enabled"
        static let feedingNotif = "notif_feeding_enabled"
        static let medicationNotif = "notif_medication_enabled"
    }

    // MARK: - Default preferences (all on)
    private var vaccineEnabled: Bool {
        get { UserDefaults.standard.object(forKey: PrefsKey.vaccineNotif) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: PrefsKey.vaccineNotif) }
    }

    private var feedingEnabled: Bool {
        get { UserDefaults.standard.object(forKey: PrefsKey.feedingNotif) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: PrefsKey.feedingNotif) }
    }

    private var medicationEnabled: Bool {
        get { UserDefaults.standard.object(forKey: PrefsKey.medicationNotif) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: PrefsKey.medicationNotif) }
    }

    // Called by NotificationSettingsView when toggles change
    func setVaccineNotif(enabled: Bool) { vaccineEnabled = enabled }
    func setFeedingNotif(enabled: Bool) { feedingEnabled = enabled }
    func setMedicationNotif(enabled: Bool) { medicationEnabled = enabled }

    func getVaccineNotif() -> Bool { vaccineEnabled }
    func getFeedingNotif() -> Bool { feedingEnabled }
    func getMedicationNotif() -> Bool { medicationEnabled }

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
        guard vaccineEnabled else { return }
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
        guard feedingEnabled else { return }
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
        guard medicationEnabled else { return }
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

    // MARK: - Cancel per type (receive arrays as params — NotificationService has no internal state)
    func cancelAllVaccineReminders(for vaccines: [Vaccine]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: vaccines.flatMap { ["vaccine-\($0.id)", "vaccine-day-\($0.id)"] }
        )
    }

    func cancelAllFeedingReminders(for feedings: [FeedingSchedule]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: feedings.map { "feeding-\($0.id)" }
        )
    }

    func cancelAllMedicationReminders(for medications: [Medication]) {
        let ids = medications.flatMap { med in
            (0..<med.scheduleTimes.count).map { "med-\(med.id)-\($0)" }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Cancel single / legacy (still used by AppViewModel update/delete)
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

    // MARK: - Reschedule per type (for toggle re-enable)
    func rescheduleVaccineReminders(vaccines: [Vaccine], pets: [Pet]) {
        let petNames = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0.name) })
        for v in vaccines {
            scheduleVaccineReminder(for: v, petName: petNames[v.petId] ?? "Hewan")
        }
    }

    func rescheduleFeedingReminders(feedings: [FeedingSchedule], pets: [Pet]) {
        let petNames = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0.name) })
        for f in feedings {
            scheduleFeedingReminder(for: f, petName: petNames[f.petId] ?? "Hewan")
        }
    }

    func rescheduleMedicationReminders(medications: [Medication], pets: [Pet]) {
        let petNames = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0.name) })
        for m in medications {
            scheduleMedicationReminder(for: m, petName: petNames[m.petId] ?? "Hewan")
        }
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
