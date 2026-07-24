// MARK: - MedicationForms.swift
// PetCare — Add/Edit Medication forms

import SwiftUI

// ─────────────────────────────────────────
// MARK: AddMedicationView
// ─────────────────────────────────────────
struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var name       = ""
    @State private var dosage     = ""
    @State private var frequency  = MedFrequency.twice
    @State private var startDate  = Date()
    @State private var hasEndDate = true
    @State private var endDate    = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
    @State private var notes      = ""
    @State private var scheduleTimes: [Date] = []

    private var scheduleTimeLabels: [String] {
        switch frequency {
        case .once:       return ["Waktu Obat"]
        case .twice:      return ["Waktu Obat (Pagi)", "Waktu Obat (Sore)"]
        case .thrice:     return ["Waktu Obat (Pagi)", "Waktu Obat (Siang)", "Waktu Obat (Malam)"]
        case .asNeeded:   return []
        case .continuous: return []
        }
    }

    private func syncScheduleTimes() {
        let count = scheduleTimeLabels.count
        let defaultTimes: [Date] = [
            Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        ]
        if scheduleTimes.count < count {
            for i in scheduleTimes.count..<count {
                scheduleTimes.append(defaultTimes[i % defaultTimes.count])
            }
        } else if scheduleTimes.count > count {
            scheduleTimes = Array(scheduleTimes.prefix(count))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        formCard {
                            PCSectionLabel(text: "Pilih Hewan")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(vm.pets) { p in
                                        PetPickerChip(pet: p, selected: selectedPetId == p.id) {
                                            withAnimation(.pcSpring) { selectedPetId = p.id }
                                        }
                                    }
                                }
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Detail Obat")
                            PCTextField(label: "Nama Obat", placeholder: "Contoh: Amoxicillin", text: $name)
                            PCTextField(label: "Dosis", placeholder: "Contoh: 0.5 tablet / 25 mg", text: $dosage)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("FREKUENSI").font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(MedFrequency.allCases, id: \.self) { f in
                                            Button { withAnimation(.pcSpring) { frequency = f } } label: {
                                                Text(f.rawValue)
                                                    .font(PCFont.caption().weight(.semibold))
                                                    .foregroundStyle(frequency == f ? .white : Color.pcText2)
                                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                                    .background(
                                                        Capsule()
                                                            .fill(frequency == f
                                                                  ? AnyShapeStyle(Color.primaryGradient)
                                                                  : AnyShapeStyle(Color.clear))
                                                            .overlay(Capsule()
                                                                .stroke(frequency == f ? Color.clear : Color.pcBorder,
                                                                        lineWidth: 1))
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }

                        if !scheduleTimeLabels.isEmpty {
                            formCard {
                                PCSectionLabel(text: "Jadwal Waktu Obat")
                                ForEach(Array(zip(scheduleTimes.indices, scheduleTimeLabels)), id: \.0) { i, label in
                                    timeRow(label, selection: $scheduleTimes[i])
                                }
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Durasi Pengobatan")
                            dateRow("Tanggal Mulai", selection: $startDate)

                            Toggle(isOn: $hasEndDate.animation(.pcSpring)) {
                                Text("Punya Tanggal Selesai")
                                    .font(PCFont.subhead()).foregroundStyle(Color.pcText1)
                            }
                            .tint(Color.pcIndigo)

                            if hasEndDate {
                                dateRow("Tanggal Selesai", selection: $endDate)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Catatan (Opsional)")
                            noteEditor(text: $notes)
                        }

                        PCPrimaryButton("Simpan Obat", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(name.isEmpty || selectedPetId == nil)
                            .opacity(name.isEmpty || selectedPetId == nil ? 0.5 : 1)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }.foregroundStyle(Color.pcIndigo)
                }
                ToolbarItem(placement: .principal) {
                    Text("Tambah Obat").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
            .onAppear { syncScheduleTimes() }
            .onChange(of: frequency) { _, _ in syncScheduleTimes() }
        }
    }

    private func save() {
        guard let petId = selectedPetId else { return }
        let m = Medication(petId: petId, name: name, dosage: dosage,
                           frequency: frequency, startDate: startDate,
                           endDate: hasEndDate ? endDate : nil,
                           scheduleTimes: scheduleTimes,
                           notes: notes.isEmpty ? nil : notes,
                           isActive: true)
        vm.addMedication(m); dismiss()
    }
}

// ─────────────────────────────────────────
// MARK: EditMedicationView
// ─────────────────────────────────────────
struct EditMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var name       = ""
    @State private var dosage     = ""
    @State private var frequency  = MedFrequency.twice
    @State private var startDate = Date()
    @State private var hasEndDate = true
    @State private var endDate   = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
    @State private var notes      = ""
    @State private var scheduleTimes: [Date] = []

    private var scheduleTimeLabels: [String] {
        switch frequency {
        case .once:       return ["Waktu Obat"]
        case .twice:      return ["Waktu Obat (Pagi)", "Waktu Obat (Sore)"]
        case .thrice:     return ["Waktu Obat (Pagi)", "Waktu Obat (Siang)", "Waktu Obat (Malam)"]
        case .asNeeded:   return []
        case .continuous: return []
        }
    }

    private func syncScheduleTimes() {
        let count = scheduleTimeLabels.count
        let defaultTimes: [Date] = [
            Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        ]
        if scheduleTimes.count < count {
            for i in scheduleTimes.count..<count {
                scheduleTimes.append(defaultTimes[i % defaultTimes.count])
            }
        } else if scheduleTimes.count > count {
            scheduleTimes = Array(scheduleTimes.prefix(count))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        formCard {
                            PCSectionLabel(text: "Pilih Hewan")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(vm.pets) { p in
                                        PetPickerChip(pet: p, selected: selectedPetId == p.id) {
                                            withAnimation(.pcSpring) { selectedPetId = p.id }
                                        }
                                    }
                                }
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Detail Obat")
                            PCTextField(label: "Nama Obat", placeholder: "Contoh: Amoxicillin", text: $name)
                            PCTextField(label: "Dosis", placeholder: "Contoh: 0.5 tablet / 25 mg", text: $dosage)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("FREKUENSI").font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(MedFrequency.allCases, id: \.self) { f in
                                            Button { withAnimation(.pcSpring) { frequency = f } } label: {
                                                Text(f.rawValue)
                                                    .font(PCFont.caption().weight(.semibold))
                                                    .foregroundStyle(frequency == f ? .white : Color.pcText2)
                                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                                    .background(
                                                        Capsule()
                                                            .fill(frequency == f
                                                                  ? AnyShapeStyle(Color.primaryGradient)
                                                                  : AnyShapeStyle(Color.clear))
                                                            .overlay(Capsule()
                                                                .stroke(frequency == f ? Color.clear : Color.pcBorder,
                                                                        lineWidth: 1))
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }

                        if !scheduleTimeLabels.isEmpty {
                            formCard {
                                PCSectionLabel(text: "Jadwal Waktu Obat")
                                ForEach(Array(zip(scheduleTimes.indices, scheduleTimeLabels)), id: \.0) { i, label in
                                    timeRow(label, selection: $scheduleTimes[i])
                                }
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Durasi Pengobatan")
                            dateRow("Tanggal Mulai", selection: $startDate)

                            Toggle(isOn: $hasEndDate.animation(.pcSpring)) {
                                Text("Punya Tanggal Selesai")
                                    .font(PCFont.subhead()).foregroundStyle(Color.pcText1)
                            }
                            .tint(Color.pcIndigo)

                            if hasEndDate {
                                dateRow("Tanggal Selesai", selection: $endDate)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Catatan (Opsional)")
                            noteEditor(text: $notes)
                        }

                        PCPrimaryButton("Simpan Perubahan", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(name.isEmpty || selectedPetId == nil)
                            .opacity(name.isEmpty || selectedPetId == nil ? 0.5 : 1)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }.foregroundStyle(Color.pcIndigo)
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Obat").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
            .onAppear {
                if let m = vm.editingMedication {
                    selectedPetId = m.petId
                    name = m.name
                    dosage = m.dosage
                    frequency = m.frequency
                    startDate = m.startDate
                    endDate = m.endDate ?? Calendar.current.date(byAdding: .day, value: 10, to: Date())!
                    hasEndDate = m.endDate != nil
                    notes = m.notes ?? ""
                    scheduleTimes = m.scheduleTimes.isEmpty ? [] : m.scheduleTimes
                    syncScheduleTimes()
                }
            }
            .onChange(of: frequency) { _, _ in syncScheduleTimes() }
        }
    }

    private func save() {
        guard let petId = selectedPetId, var m = vm.editingMedication else { return }
        m.petId = petId
        m.name = name
        m.dosage = dosage
        m.frequency = frequency
        m.startDate = startDate
        m.endDate = hasEndDate ? endDate : nil
        m.scheduleTimes = scheduleTimes
        m.notes = notes.isEmpty ? nil : notes
        vm.updateMedication(m)
        vm.editingMedication = nil
        dismiss()
    }
}

#Preview("Add Medication") { AddMedicationView().environmentObject(AppViewModel()) }
#Preview("Edit Medication") { EditMedicationView().environmentObject(AppViewModel()) }
