// MARK: - VaccineForms.swift
// PetCare — Add/Edit Vaccine forms

import SwiftUI

// ─────────────────────────────────────────
// MARK: AddVaccineView
// ─────────────────────────────────────────
struct AddVaccineView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var name        = ""
    @State private var date        = Date()
    @State private var nextDate    = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var clinic      = ""
    @State private var doctorName  = ""
    @State private var notes       = ""
    @State private var hasNextDate = true

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        // Pet picker
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

                        // Vaccine info
                        formCard {
                            PCSectionLabel(text: "Detail Vaksin")
                            PCTextField(label: "Nama Vaksin", placeholder: "Contoh: Vaksin Rabies", text: $name)

                            dateRow("Tanggal Vaksin", selection: $date)

                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $hasNextDate.animation(.pcSpring)) {
                                    Text("Jadwalkan Vaksin Berikutnya")
                                        .font(PCFont.subhead()).foregroundStyle(Color.pcText1)
                                }
                                .tint(Color.pcIndigo)
                                if hasNextDate {
                                    dateRow("Jadwal Berikutnya", selection: $nextDate)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }

                        // Clinic info
                        formCard {
                            PCSectionLabel(text: "Info Klinik (Opsional)")
                            PCTextField(label: "Nama Klinik", placeholder: "Contoh: Klinik Hewan Sehat", text: $clinic)
                            PCTextField(label: "Nama Dokter", placeholder: "Contoh: Dr. Hendra", text: $doctorName)
                        }

                        formCard {
                            PCSectionLabel(text: "Catatan (Opsional)")
                            noteEditor(text: $notes)
                        }

                        PCPrimaryButton("Simpan Vaksin", icon: "checkmark") { save() }
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
                    Text("Tambah Vaksin").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
        }
    }

    private func save() {
        guard let petId = selectedPetId else { return }
        let v = Vaccine(petId: petId, name: name, date: date,
                        nextDate: hasNextDate ? nextDate : nil,
                        clinic: clinic.isEmpty ? nil : clinic,
                        doctorName: doctorName.isEmpty ? nil : doctorName,
                        notes: notes.isEmpty ? nil : notes)
        vm.addVaccine(v); dismiss()
    }
}

// ─────────────────────────────────────────
// MARK: EditVaccineView
// ─────────────────────────────────────────
struct EditVaccineView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var name        = ""
    @State private var date        = Date()
    @State private var nextDate    = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var clinic      = ""
    @State private var doctorName  = ""
    @State private var notes       = ""
    @State private var hasNextDate = true

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
                            PCSectionLabel(text: "Detail Vaksin")
                            PCTextField(label: "Nama Vaksin", placeholder: "Contoh: Vaksin Rabies", text: $name)
                            dateRow("Tanggal Vaksin", selection: $date)

                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $hasNextDate.animation(.pcSpring)) {
                                    Text("Jadwalkan Vaksin Berikutnya")
                                        .font(PCFont.subhead()).foregroundStyle(Color.pcText1)
                                }
                                .tint(Color.pcIndigo)
                                if hasNextDate {
                                    dateRow("Jadwal Berikutnya", selection: $nextDate)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Info Klinik (Opsional)")
                            PCTextField(label: "Nama Klinik", placeholder: "Contoh: Klinik Hewan Sehat", text: $clinic)
                            PCTextField(label: "Nama Dokter", placeholder: "Contoh: Dr. Hendra", text: $doctorName)
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
                    Text("Edit Vaksin").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
            .onAppear {
                if let v = vm.editingVaccine {
                    selectedPetId = v.petId
                    name = v.name
                    date = v.date
                    nextDate = v.nextDate ?? Calendar.current.date(byAdding: .year, value: 1, to: Date())!
                    clinic = v.clinic ?? ""
                    doctorName = v.doctorName ?? ""
                    notes = v.notes ?? ""
                    hasNextDate = v.nextDate != nil
                }
            }
        }
    }

    private func save() {
        guard let petId = selectedPetId, var v = vm.editingVaccine else { return }
        v.petId = petId
        v.name = name
        v.date = date
        v.nextDate = hasNextDate ? nextDate : nil
        v.clinic = clinic.isEmpty ? nil : clinic
        v.doctorName = doctorName.isEmpty ? nil : doctorName
        v.notes = notes.isEmpty ? nil : notes
        vm.updateVaccine(v)
        vm.editingVaccine = nil
        dismiss()
    }
}

#Preview("Add Vaccine") { AddVaccineView().environmentObject(AppViewModel()) }
#Preview("Edit Vaccine") { EditVaccineView().environmentObject(AppViewModel()) }
