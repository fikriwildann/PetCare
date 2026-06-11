// MARK: - AppViewModel.swift
// PetCare — Central app state (ObservableObject)

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AppViewModel: ObservableObject {

    // MARK: Auth
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: AppUser = SampleData.user
    @Published var showOnboarding: Bool = true
    @Published var authError: String?

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
    func addPet(_ pet: Pet) {
        withAnimation(.pcSpring) { pets.append(pet) }
        Task { try? await FirebasePetService.shared.addPet(pet) }
    }
    func deletePet(_ pet: Pet) {
        withAnimation(.pcSpring) { pets.removeAll { $0.id == pet.id } }
        Task { try? await FirebasePetService.shared.deletePet(id: pet.id) }
    }
    func updatePet(_ pet: Pet) {
        if let i = pets.firstIndex(where: { $0.id == pet.id }) {
            withAnimation(.pcSpring) { pets[i] = pet }
            Task { try? await FirebasePetService.shared.updatePet(pet) }
        }
    }

    func addVaccine(_ v: Vaccine) {
        withAnimation(.pcSpring) { vaccines.append(v) }
        Task { try? await FirebaseScheduleService.shared.addVaccine(v) }
    }
    func addMedication(_ m: Medication) {
        withAnimation(.pcSpring) { medications.append(m) }
        Task { try? await FirebaseScheduleService.shared.addMedication(m) }
    }
    func addFeeding(_ f: FeedingSchedule) {
        withAnimation(.pcSpring) { feedings.append(f) }
        Task { try? await FirebaseScheduleService.shared.addFeeding(f) }
    }
    func addHealthRecord(_ r: HealthRecord) {
        withAnimation(.pcSpring) { healthRecords.append(r) }
        Task { try? await FirebaseHealthRecordService.shared.addHealthRecord(r) }
    }

    func toggleFeedingComplete(_ id: UUID) {
        if let i = feedings.firstIndex(where: { $0.id == id }) {
            let newValue = !feedings[i].isCompleted
            withAnimation(.pcSpring) { feedings[i].isCompleted = newValue }
            Task { try? await FirebaseScheduleService.shared.toggleFeedingComplete(id: id, isCompleted: newValue) }
        }
    }

    // MARK: - Load from Firestore
    func loadPetsFromFirestore() async {
        do {
            let loadedPets = try await FirebasePetService.shared.loadPets()
            await MainActor.run {
                withAnimation(.pcSpring) { pets = loadedPets }
            }
        } catch {
            print("Gagal memuat pets dari Firestore: \(error)")
        }
    }

    func loadSchedulesFromFirestore() async {
        do {
            async let loadedFeedings = FirebaseScheduleService.shared.loadFeedings()
            async let loadedVaccines = FirebaseScheduleService.shared.loadVaccines()
            async let loadedMedications = FirebaseScheduleService.shared.loadMedications()
            async let loadedHealthRecords = FirebaseHealthRecordService.shared.loadHealthRecords()

            let (f, v, m, h) = try await (loadedFeedings, loadedVaccines, loadedMedications, loadedHealthRecords)
            await MainActor.run {
                withAnimation(.pcSpring) {
                    feedings = f
                    vaccines = v
                    medications = m
                    healthRecords = h
                }
            }
        } catch {
            print("Gagal memuat jadwal dari Firestore: \(error)")
        }
    }

    func markAllRead() {
        withAnimation(.pcSmooth) {
            for i in notifications.indices { notifications[i].isRead = true }
        }
    }

    // MARK: - Firebase Auth

    func login(email: String, password: String) {
        authError = nil
        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                let user = result.user
                currentUser = AppUser(
                    id: UUID(),
                    name: user.displayName ?? email.components(separatedBy: "@").first ?? "User",
                    email: user.email ?? email,
                    profileImageName: nil,
                    joinDate: Date()
                )
                PersistenceService.shared.save(true, key: StorageKey.authState)
                withAnimation(.pcSpring) { isLoggedIn = true }
                await loadPetsFromFirestore()
                await loadSchedulesFromFirestore()
            } catch let error as NSError {
                authError = mapAuthError(error)
            }
        }
    }

    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            currentUser = AppUser(
                id: UUID(),
                name: user.displayName ?? user.email?.components(separatedBy: "@").first ?? "User",
                email: user.email ?? "",
                profileImageName: nil,
                joinDate: Date()
            )
            Task {
                await loadPetsFromFirestore()
                await loadSchedulesFromFirestore()
            }
            isLoggedIn = true
        }
    }

    private func mapAuthError(_ error: NSError) -> String {
        let errorCode = AuthErrorCode(rawValue: error.code)
        switch errorCode {
        case .wrongPassword:
            return "Salah password"
        case .userNotFound:
            return "Akun tidak ditemukan"
        case .invalidEmail:
            return "Email tidak valid"
        case .userDisabled:
            return "Akun telah dinonaktifkan"
        case .networkError:
            return "Kesalahan jaringan"
        case .tooManyRequests:
            return "Terlalu banyak percobaan, coba lagi nanti"
        default:
            return "Login gagal. Periksa email dan password Anda"
        }
    }

    func register(name: String, email: String, password: String) {
        authError = nil
        Task {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let user = result.user

                // Simpan nama lengkap ke Firebase Auth displayName
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                try await changeRequest.commitChanges()

                currentUser = AppUser(
                    id: UUID(),
                    name: name,
                    email: user.email ?? email,
                    profileImageName: nil,
                    joinDate: Date()
                )
                PersistenceService.shared.save(true, key: StorageKey.authState)
                withAnimation(.pcSpring) { isLoggedIn = true }
                await loadPetsFromFirestore()
                await loadSchedulesFromFirestore()
            } catch let error as NSError {
                authError = mapAuthError(error)
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        authError = nil
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                await MainActor.run {
                    completion(true)
                }
            } catch let error as NSError {
                await MainActor.run {
                    authError = mapResetPasswordError(error)
                    completion(false)
                }
            }
        }
    }

    private func mapResetPasswordError(_ error: NSError) -> String {
        let errorCode = AuthErrorCode(rawValue: error.code)
        switch errorCode {
        case .userNotFound:
            return "Akun tidak ditemukan"
        case .invalidEmail:
            return "Email tidak valid"
        case .networkError:
            return "Kesalahan jaringan"
        case .tooManyRequests:
            return "Terlalu banyak percobaan, coba lagi nanti"
        default:
            return "Gagal mengirim email reset. Coba lagi nanti"
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            PersistenceService.shared.delete(key: StorageKey.authState)
            withAnimation(.pcSpring) { isLoggedIn = false }
            currentUser = SampleData.user
        } catch {
            authError = error.localizedDescription
        }
    }

    func updateProfile(name: String) {
        withAnimation(.pcSpring) {
            currentUser.name = name
        }
        // Update Firebase Auth displayName
        Task {
            if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                try? await changeRequest.commitChanges()
            }
        }
    }
}
