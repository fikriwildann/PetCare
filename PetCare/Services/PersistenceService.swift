// MARK: - PersistenceService.swift
// PetCare — Simple JSON-based local storage

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var baseURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: Save
    func save<T: Encodable>(_ value: T, key: String) {
        do {
            let data = try encoder.encode(value)
            let url = baseURL.appendingPathComponent("\(key).json")
            try data.write(to: url, options: .atomic)
        } catch {
            print("❌ PersistenceService save error [\(key)]: \(error)")
        }
    }

    // MARK: Load
    func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        let url = baseURL.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ PersistenceService load error [\(key)]: \(error)")
            return nil
        }
    }

    // MARK: Delete
    func delete(key: String) {
        let url = baseURL.appendingPathComponent("\(key).json")
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - Storage Keys
enum StorageKey {
    static let pets          = "pets"
    static let vaccines      = "vaccines"
    static let medications   = "medications"
    static let feedings      = "feedings"
    static let healthRecords = "health_records"
    static let weightRecords = "weight_records"
    static let notifications = "notifications"
    static let user          = "user"
    static let authState     = "auth_state"
}
