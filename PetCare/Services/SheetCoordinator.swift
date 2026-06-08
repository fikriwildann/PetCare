// MARK: - SheetCoordinator.swift
// PetCare — Sheet presentation coordinator for all form modals

import SwiftUI

/// Attach this modifier to MainTabView so all global sheets are available
/// regardless of which tab is active.
struct GlobalSheetModifier: ViewModifier {
    @EnvironmentObject var vm: AppViewModel

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $vm.showAddVaccine)      { AddVaccineView() }
            .sheet(isPresented: $vm.showAddMedication)   { AddMedicationView() }
            .sheet(isPresented: $vm.showAddFeeding)      { AddFeedingView() }
            .sheet(isPresented: $vm.showAddHealthRecord) { AddHealthRecordView() }
    }
}

extension View {
    func globalSheets() -> some View {
        modifier(GlobalSheetModifier())
    }
}
