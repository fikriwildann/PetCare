// MARK: - PetCareApp.swift
// PetCare — App Entry Point

import SwiftUI

@main
struct PetCareApp: App {
    @StateObject private var vm = AppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
        }
    }
}
