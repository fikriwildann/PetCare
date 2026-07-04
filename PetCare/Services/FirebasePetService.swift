// MARK: - FirebasePetService.swift
// PetCare — Firestore CRUD for Pets

import Foundation
import FirebaseFirestore

final class FirebasePetService: BaseFirebaseService {
    static let shared = FirebasePetService()

    private override init() {}

    func addPet(_ pet: Pet) async throws {
        guard let userDoc = userDocument else { return }
        let data = pet.toDictionary
        try await userDoc.collection("pets").document(pet.id.uuidString).setData(data)
    }

    func updatePet(_ pet: Pet) async throws {
        guard let userDoc = userDocument else { return }
        let data = pet.toDictionary
        try await userDoc.collection("pets").document(pet.id.uuidString).updateData(data)
    }

    func deletePet(id: UUID) async throws {
        guard let userDoc = userDocument else { return }
        try await userDoc.collection("pets").document(id.uuidString).delete()
    }

    func loadPets() async throws -> [Pet] {
        guard let userDoc = userDocument else { return [] }
        let snapshot = try await userDoc.collection("pets").getDocuments()
        return snapshot.documents.compactMap { Pet.from(dictionary: $0.data()) }
    }
}
