// MARK: - BaseFirebaseService.swift
// PetCare — Base class for all Firebase services

import Foundation
import FirebaseFirestore
import FirebaseAuth

class BaseFirebaseService {
    let db = Firestore.firestore()

    var userDocument: DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid)
    }
}
