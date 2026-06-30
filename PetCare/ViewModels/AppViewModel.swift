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
    @Published var pets: [Pet] = []
    @Published var selectedPet: Pet? = nil

    // MARK: Vaccines
    @Published var vaccines: [Vaccine] = []

    // MARK: Medications
    @Published var medications: [Medication] = []

    // MARK: Feedings
    @Published var feedings: [FeedingSchedule] = []

    // MARK: Health Records
    @Published var healthRecords: [HealthRecord] = []

    // MARK: Weight Records
    @Published var weightRecords: [WeightRecord] = []

    // MARK: Notifications
    @Published var notifications: [AppNotification] = []

    // MARK: UI State
    @Published var selectedTab: Int = 0
    @Published var selectedHealthSegment: Int = 0
    @Published var navigateToWeightChart: Bool = false
    @Published var showAddPet: Bool = false
    @Published var showAddVaccine: Bool = false
    @Published var showAddMedication: Bool = false
    @Published var showAddFeeding: Bool = false
    @Published var showAddHealthRecord: Bool = false
    @Published var showAddWeight: Bool = false
    @Published var showEditFeeding: Bool = false
    @Published var editingFeeding: FeedingSchedule?
    @Published var showEditVaccine: Bool = false
    @Published var editingVaccine: Vaccine?
    @Published var showEditMedication: Bool = false
    @Published var editingMedication: Medication?

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
        withAnimation(.pcSpring) {
            pets.removeAll { $0.id == pet.id }
            feedings.removeAll { $0.petId == pet.id }
            vaccines.removeAll { $0.petId == pet.id }
            medications.removeAll { $0.petId == pet.id }
            healthRecords.removeAll { $0.petId == pet.id }
            weightRecords.removeAll { $0.petId == pet.id }
            if selectedPet?.id == pet.id {
                selectedPet = pets.first
            }
        }
        Task {
            try? await FirebaseScheduleService.shared.deleteAllFeedings(for: pet.id)
            try? await FirebaseScheduleService.shared.deleteAllVaccines(for: pet.id)
            try? await FirebaseScheduleService.shared.deleteAllMedications(for: pet.id)
            try? await FirebaseHealthRecordService.shared.deleteAllHealthRecords(for: pet.id)
            try? await FirebaseWeightService.shared.deleteAllWeights(for: pet.id)
            try? await FirebasePetService.shared.deletePet(id: pet.id)
        }
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
        let petName = petName(for: v.petId)
        NotificationService.shared.scheduleVaccineReminder(for: v, petName: petName)
        let notif = AppNotification(type: .vaccine, title: "Vaksin Ditambahkan",
                                     message: "Vaksin \(v.name) untuk \(petName) berhasil disimpan.",
                                     date: Date(), isRead: false, petId: v.petId)
        withAnimation(.pcSpring) { notifications.insert(notif, at: 0) }
    }
    func addMedication(_ m: Medication) {
        withAnimation(.pcSpring) { medications.append(m) }
        Task { try? await FirebaseScheduleService.shared.addMedication(m) }
        let petName = petName(for: m.petId)
        NotificationService.shared.scheduleMedicationReminder(for: m, petName: petName)
        let notif = AppNotification(type: .medication, title: "Obat Ditambahkan",
                                     message: "Jadwal obat \(m.name) untuk \(petName) berhasil disimpan.",
                                     date: Date(), isRead: false, petId: m.petId)
        withAnimation(.pcSpring) { notifications.insert(notif, at: 0) }
    }
    func addFeeding(_ f: FeedingSchedule) {
        withAnimation(.pcSpring) { feedings.append(f) }
        Task { try? await FirebaseScheduleService.shared.addFeeding(f) }
        let petName = petName(for: f.petId)
        NotificationService.shared.scheduleFeedingReminder(for: f, petName: petName)
        let notif = AppNotification(type: .feeding, title: "Jadwal Makan Ditambahkan",
                                     message: "\(f.mealType.rawValue) untuk \(petName) berhasil disimpan.",
                                     date: Date(), isRead: false, petId: f.petId)
        withAnimation(.pcSpring) { notifications.insert(notif, at: 0) }
    }
    func addHealthRecord(_ r: HealthRecord) {
        withAnimation(.pcSpring) { healthRecords.append(r) }
        Task { try? await FirebaseHealthRecordService.shared.addHealthRecord(r) }
    }
    func addWeightRecord(_ r: WeightRecord) {
        withAnimation(.pcSpring) { weightRecords.append(r) }
        Task { try? await FirebaseWeightService.shared.addWeight(r) }
    }

    func toggleFeedingComplete(_ id: UUID) {
        if let i = feedings.firstIndex(where: { $0.id == id }) {
            let newValue = !feedings[i].isCompleted
            withAnimation(.pcSpring) { feedings[i].isCompleted = newValue }
            Task { try? await FirebaseScheduleService.shared.toggleFeedingComplete(id: id, isCompleted: newValue) }
        }
    }
    func updateFeeding(_ f: FeedingSchedule) {
        if let i = feedings.firstIndex(where: { $0.id == f.id }) {
            // Cancel old notification before scheduling new one
            NotificationService.shared.cancelReminder(id: "feeding-\(f.id)")
            withAnimation(.pcSpring) { feedings[i] = f }
            Task {
                try? await FirebaseScheduleService.shared.updateFeeding(f)
                // Reschedule notification with updated data
                NotificationService.shared.scheduleFeedingReminder(for: f, petName: petName(for: f.petId))
            }
        }
    }
    func deleteFeeding(_ f: FeedingSchedule) {
        // Cancel notification first
        NotificationService.shared.cancelReminder(id: "feeding-\(f.id)")
        withAnimation(.pcSpring) { feedings.removeAll { $0.id == f.id } }
        Task { try? await FirebaseScheduleService.shared.deleteFeeding(id: f.id) }
    }
    func updateVaccine(_ v: Vaccine) {
        if let i = vaccines.firstIndex(where: { $0.id == v.id }) {
            // Cancel old notification before scheduling new one
            NotificationService.shared.cancelVaccineReminders(for: v.id)
            withAnimation(.pcSpring) { vaccines[i] = v }
            Task {
                try? await FirebaseScheduleService.shared.updateVaccine(v)
                // Reschedule notification with updated data
                NotificationService.shared.scheduleVaccineReminder(for: v, petName: petName(for: v.petId))
            }
        }
    }
    func deleteVaccine(_ v: Vaccine) {
        // Cancel notification first
        NotificationService.shared.cancelVaccineReminders(for: v.id)
        withAnimation(.pcSpring) { vaccines.removeAll { $0.id == v.id } }
        Task { try? await FirebaseScheduleService.shared.deleteVaccine(id: v.id) }
    }
    func updateMedication(_ m: Medication) {
        if let i = medications.firstIndex(where: { $0.id == m.id }) {
            // Cancel old notifications before scheduling new ones
            NotificationService.shared.cancelMedicationReminders(for: m.id, scheduleTimesCount: m.scheduleTimes.count)
            withAnimation(.pcSpring) { medications[i] = m }
            Task {
                try? await FirebaseScheduleService.shared.updateMedication(m)
                // Reschedule notification with updated data
                NotificationService.shared.scheduleMedicationReminder(for: m, petName: petName(for: m.petId))
            }
        }
    }
    func deleteMedication(_ m: Medication) {
        // Cancel notifications first
        NotificationService.shared.cancelMedicationReminders(for: m.id, scheduleTimesCount: m.scheduleTimes.count)
        withAnimation(.pcSpring) { medications.removeAll { $0.id == m.id } }
        Task { try? await FirebaseScheduleService.shared.deleteMedication(id: m.id) }
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
            async let loadedWeights = FirebaseWeightService.shared.loadWeights()

            let (f, v, m, h, w) = try await (loadedFeedings, loadedVaccines, loadedMedications, loadedHealthRecords, loadedWeights)
            await MainActor.run {
                withAnimation(.pcSpring) {
                    feedings = f
                    vaccines = v
                    medications = m
                    healthRecords = h
                    weightRecords = w
                    notifications = []
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
                _ = await NotificationService.shared.requestPermission()
                // Reschedule all notifications after loading from Firestore
                NotificationService.shared.rescheduleAllReminders(
                    feedings: feedings,
                    vaccines: vaccines,
                    medications: medications,
                    pets: pets
                )
            }
            isLoggedIn = true
            showOnboarding = false
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
            notifications = []
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

    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        authError = nil
        guard let user = Auth.auth().currentUser else {
            completion(false, "Tidak ada pengguna yang login")
            return
        }

        // Re-authenticate first (Firebase requirement)
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)

        Task {
            do {
                try await user.reauthenticate(with: credential)
                try await user.updatePassword(to: newPassword)
                await MainActor.run {
                    completion(true, nil)
                }
            } catch let error as NSError {
                await MainActor.run {
                    completion(false, mapChangePasswordError(error))
                }
            }
        }
    }

    private func mapChangePasswordError(_ error: NSError) -> String {
        let errorCode = AuthErrorCode(rawValue: error.code)
        switch errorCode {
        case .wrongPassword:
            return "Password saat ini salah"
        case .invalidCredential:
            return "Kredensial tidak valid"
        case .networkError:
            return "Kesalahan jaringan"
        case .tooManyRequests:
            return "Terlalu banyak percobaan, coba lagi nanti"
        case .userTokenExpired:
            return "Sesi habis, silakan login ulang"
        default:
            return "Gagal mengubah password. Coba lagi nanti"
        }
    }
}
