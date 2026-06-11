// MARK: - FirebasePetService.swift
// PetCare — Firestore CRUD for Pets

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebasePetService {
    static let shared = FirebasePetService()
    private let db = Firestore.firestore()

    private init() {}

    private func userDocument() -> DocumentReference? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        return db.collection("users").document(userId)
    }

    func addPet(_ pet: Pet) async throws {
        guard let userDoc = userDocument() else { return }
        var data = pet.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("pets").document(pet.id.uuidString).setData(data)
    }

    func updatePet(_ pet: Pet) async throws {
        guard let userDoc = userDocument() else { return }
        var data = pet.toDictionary
        data["userId"] = Auth.auth().currentUser?.uid ?? ""
        try await userDoc.collection("pets").document(pet.id.uuidString).updateData(data)
    }

    func deletePet(id: UUID) async throws {
        guard let userDoc = userDocument() else { return }
        try await userDoc.collection("pets").document(id.uuidString).delete()
    }

    func loadPets() async throws -> [Pet] {
        guard let userDoc = userDocument() else { return [] }
        let snapshot = try await userDoc.collection("pets").getDocuments()
        return snapshot.documents.compactMap { Pet.from(dictionary: $0.data()) }
    }
}