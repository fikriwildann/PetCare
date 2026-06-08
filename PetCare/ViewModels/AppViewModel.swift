// MARK: - AppViewModel.swift
// PetCare — Central app state (ObservableObject)

import SwiftUI
import Combine

@MainActor
final class AppViewModel: ObservableObject {

    // MARK: Auth
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: AppUser = SampleData.user
    @Published var showOnboarding: Bool = true

    // MARK: Pets
    @Published var pets: [Pet] = SampleData.pets
    @Published var selectedPet: Pet? = SampleData.pets.first

    // MARK: Vaccines
    @Published var vaccines: [Vaccine] = SampleData.vaccines

    // MARK: Medications
    @Published var medications: [Medication] = SampleData.medications

    // MARK: Feedings
    @Published var feedings: [FeedingSchedule] = SampleData.feedings

    // MARK: Health Records
    @Published var healthRecords: [HealthRecord] = SampleData.healthRecords

    // MARK: Weight Records
    @Published var weightRecords: [WeightRecord] = SampleData.weights(for: SampleData.buddy.id)

    // MARK: Notifications
    @Published var notifications: [AppNotification] = SampleData.notifications

    // MARK: UI State
    @Published var selectedTab: Int = 0
    @Published var showAddPet: Bool = false
    @Published var showAddVaccine: Bool = false
    @Published var showAddMedication: Bool = false
    @Published var showAddFeeding: Bool = false
    @Published var showAddHealthRecord: Bool = false

    // MARK: Computed

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    var todayFeedings: [FeedingSchedule] { feedings }

    var upcomingVaccines: [Vaccine] {
        vaccines.filter { $0.status == .upcoming || $0.status == .overdue }
            .sorted { ($0.daysUntilNext ?? 999) < ($1.daysUntilNext ?? 999) }
    }

    var activeMedications: [Medication] { medications.filter { $0.isActive } }

    func vaccines(for petId: UUID) -> [Vaccine] { vaccines.filter { $0.petId == petId } }
    func medications(for petId: UUID) -> [Medication] { medications.filter { $0.petId == petId } }
    func feedings(for petId: UUID) -> [FeedingSchedule] { feedings.filter { $0.petId == petId } }
    func healthRecords(for petId: UUID) -> [HealthRecord] { healthRecords.filter { $0.petId == petId } }
    func weights(for petId: UUID) -> [WeightRecord] { weightRecords.filter { $0.petId == petId } }

    func petName(for id: UUID) -> String { pets.first { $0.id == id }?.name ?? "—" }

    // MARK: Actions
    func addPet(_ pet: Pet) { withAnimation(.pcSpring) { pets.append(pet) } }
    func deletePet(_ pet: Pet) { withAnimation(.pcSpring) { pets.removeAll { $0.id == pet.id } } }

    func addVaccine(_ v: Vaccine) { withAnimation(.pcSpring) { vaccines.append(v) } }
    func addMedication(_ m: Medication) { withAnimation(.pcSpring) { medications.append(m) } }
    func addFeeding(_ f: FeedingSchedule) { withAnimation(.pcSpring) { feedings.append(f) } }
    func addHealthRecord(_ r: HealthRecord) { withAnimation(.pcSpring) { healthRecords.append(r) } }

    func toggleFeedingComplete(_ id: UUID) {
        if let i = feedings.firstIndex(where: { $0.id == id }) {
            withAnimation(.pcSpring) { feedings[i].isCompleted.toggle() }
        }
    }

    func markAllRead() {
        withAnimation(.pcSmooth) {
            for i in notifications.indices { notifications[i].isRead = true }
        }
    }

    func login(email: String, password: String) {
        withAnimation(.pcSpring) { isLoggedIn = true }
    }

    func logout() {
        withAnimation(.pcSpring) { isLoggedIn = false }
    }
}
