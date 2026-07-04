// MARK: - FeedingForms.swift
// PetCare — Add/Edit Feeding forms

import SwiftUI

// ─────────────────────────────────────────
// MARK: AddFeedingView
// ─────────────────────────────────────────
struct AddFeedingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var mealType  = MealType.breakfast
    @State private var time      = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @State private var foodName  = ""
    @State private var portion   = ""
    @State private var notes     = ""

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
                            PCSectionLabel(text: "Waktu Makan")
                            HStack(spacing: 10) {
                                ForEach(MealType.allCases, id: \.self) { t in
                                    Button { withAnimation(.pcSpring) { mealType = t } } label: {
                                        VStack(spacing: 6) {
                                            Text(t.emoji).font(.system(size: 22))
                                            Text(t.rawValue)
                                                .font(PCFont.micro()).lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .foregroundStyle(mealType == t ? t.color : Color.pcText2)
                                        .background(
                                            RoundedRectangle(cornerRadius: PCRadius.sm, style: .continuous)
                                                .fill(mealType == t ? t.color.opacity(0.12) : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: PCRadius.sm, style: .continuous)
                                                        .stroke(mealType == t ? t.color.opacity(0.30) : Color.pcBorder,
                                                                lineWidth: 1))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("JAM MAKAN").font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .tint(Color.pcIndigo)
                                    .frame(maxWidth: .infinity)
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Makanan")
                            PCTextField(label: "Nama Makanan", placeholder: "Contoh: Dry Food Premium", text: $foodName)
                            PCTextField(label: "Porsi", placeholder: "Contoh: 200 gram", text: $portion)
                        }

                        formCard {
                            PCSectionLabel(text: "Catatan (Opsional)")
                            noteEditor(text: $notes)
                        }

                        PCPrimaryButton("Simpan Jadwal Makan", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(foodName.isEmpty || selectedPetId == nil)
                            .opacity(foodName.isEmpty || selectedPetId == nil ? 0.5 : 1)

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
                    Text("Tambah Jadwal Makan").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
        }
    }

    private func save() {
        guard let petId = selectedPetId else { return }
        let f = FeedingSchedule(petId: petId, mealType: mealType, time: time,
                                foodName: foodName, portion: portion,
                                notes: notes.isEmpty ? nil : notes)
        vm.addFeeding(f); dismiss()
    }
}

// ─────────────────────────────────────────
// MARK: EditFeedingView
// ─────────────────────────────────────────
struct EditFeedingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var mealType  = MealType.breakfast
    @State private var time      = Date()
    @State private var foodName  = ""
    @State private var portion   = ""
    @State private var notes     = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        formCard {
                            PCSectionLabel(text: "Pilih Hewan")
                            if vm.pets.isEmpty {
                                Text("Belum ada hewan. Tambah dulu di menu Pets.")
                                    .font(PCFont.caption()).foregroundStyle(Color.pcText3)
                                    .padding(.vertical, 8)
                            } else {
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
                        }

                        formCard {
                            PCSectionLabel(text: "Waktu Makan")
                            HStack(spacing: 10) {
                                ForEach(MealType.allCases, id: \.self) { t in
                                    Button { withAnimation(.pcSpring) { mealType = t } } label: {
                                        VStack(spacing: 6) {
                                            Text(t.emoji).font(.system(size: 22))
                                            Text(t.rawValue)
                                                .font(PCFont.micro()).lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .foregroundStyle(mealType == t ? t.color : Color.pcText2)
                                        .background(
                                            RoundedRectangle(cornerRadius: PCRadius.sm, style: .continuous)
                                                .fill(mealType == t ? t.color.opacity(0.12) : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: PCRadius.sm, style: .continuous)
                                                        .stroke(mealType == t ? t.color.opacity(0.30) : Color.pcBorder,
                                                                lineWidth: 1))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("JAM MAKAN").font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .tint(Color.pcIndigo)
                                    .frame(maxWidth: .infinity)
                            }
                        }

                        formCard {
                            PCSectionLabel(text: "Makanan")
                            PCTextField(label: "Nama Makanan", placeholder: "Contoh: Dry Food Premium", text: $foodName)
                            PCTextField(label: "Porsi", placeholder: "Contoh: 200 gram", text: $portion)
                        }

                        formCard {
                            PCSectionLabel(text: "Catatan (Opsional)")
                            noteEditor(text: $notes)
                        }

                        PCPrimaryButton("Simpan Perubahan", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(foodName.isEmpty || selectedPetId == nil)
                            .opacity(foodName.isEmpty || selectedPetId == nil ? 0.5 : 1)

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
                    Text("Edit Jadwal Makan").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
            .onAppear {
                if let f = vm.editingFeeding {
                    selectedPetId = f.petId
                    mealType = f.mealType
                    time = f.time
                    foodName = f.foodName
                    portion = f.portion
                    notes = f.notes ?? ""
                }
            }
        }
    }

    private func save() {
        guard let petId = selectedPetId, var f = vm.editingFeeding else { return }
        f.petId = petId
        f.mealType = mealType
        f.time = time
        f.foodName = foodName
        f.portion = portion
        f.notes = notes.isEmpty ? nil : notes
        vm.updateFeeding(f)
        vm.editingFeeding = nil
        dismiss()
    }
}

#Preview("Add Feeding") { AddFeedingView().environmentObject(AppViewModel()) }
#Preview("Edit Feeding") { EditFeedingView().environmentObject(AppViewModel()) }
