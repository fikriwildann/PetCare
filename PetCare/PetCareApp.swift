// MARK: - PetCareApp.swift
// PetCare — App Entry Point

import SwiftUI
import FirebaseCore

@main
struct PetCareApp: App {
    @StateObject private var vm = AppViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
                .onAppear {
                    vm.checkAuthState()
                }
        }
    }
}
