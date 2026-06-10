// MARK: - FirebasePetService.swift
// PetCare — Firestore CRUD for Pets

import Foundation
import FirebaseFirestore

final class FirebasePetService {
    static let shared = FirebasePetService()
    private let db = Firestore.firestore()

    private init() {}

    func addPet(_ pet: Pet) async throws {
        let doc = db.collection("pets").document(pet.id.uuidString)
        try await doc.setData(pet.toDictionary)
    }

    func updatePet(_ pet: Pet) async throws {
        let doc = db.collection("pets").document(pet.id.uuidString)
        try await doc.updateData(pet.toDictionary)
    }

    func deletePet(id: UUID) async throws {
        let doc = db.collection("pets").document(id.uuidString)
        try await doc.delete()
    }

    func loadPets() async throws -> [Pet] {
        let snapshot = try await db.collection("pets").getDocuments()
        return snapshot.documents.compactMap { Pet.from(dictionary: $0.data()) }
    }
}