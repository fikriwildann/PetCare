// MARK: - FormViews.swift
// PetCare — Add Vaccine / Medication / Health Record sheets

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
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Detail Vaksin")
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
                            sectionLabel("Info Klinik (Opsional)")
                            PCTextField(label: "Nama Klinik", placeholder: "Contoh: Klinik Hewan Sehat", text: $clinic)
                            PCTextField(label: "Nama Dokter", placeholder: "Contoh: Dr. Hendra", text: $doctorName)
                        }

                        formCard {
                            sectionLabel("Catatan (Opsional)")
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

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        formCard {
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Detail Obat")
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

                        formCard {
                            sectionLabel("Durasi Pengobatan")
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
                            sectionLabel("Catatan (Opsional)")
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
        }
    }

    private func save() {
        guard let petId = selectedPetId else { return }
        let m = Medication(petId: petId, name: name, dosage: dosage,
                           frequency: frequency, startDate: startDate,
                           endDate: hasEndDate ? endDate : nil,
                           scheduleTimes: [],
                           notes: notes.isEmpty ? nil : notes,
                           isActive: true)
        vm.addMedication(m); dismiss()
    }
}

// ─────────────────────────────────────────
// MARK: AddHealthRecordView
// ─────────────────────────────────────────
struct AddHealthRecordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var date        = Date()
    @State private var type        = HealthRecordType.checkup
    @State private var diagnosis   = ""
    @State private var treatment   = ""
    @State private var doctorName  = ""
    @State private var clinic      = ""
    @State private var notes       = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        formCard {
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Jenis Pemeriksaan")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(HealthRecordType.allCases, id: \.self) { t in
                                    Button { withAnimation(.pcSpring) { type = t } } label: {
                                        HStack(spacing: 8) {
                                            Text(t.emoji).font(.system(size: 16))
                                            Text(t.rawValue)
                                                .font(PCFont.caption().weight(.semibold))
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .foregroundStyle(type == t ? t.color : Color.pcText2)
                                        .background(
                                            RoundedRectangle(cornerRadius: PCRadius.sm, style: .continuous)
                                                .fill(type == t ? t.color.opacity(0.12) : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: PCRadius.sm, style: .continuous)
                                                        .stroke(type == t ? t.color.opacity(0.30) : Color.pcBorder,
                                                                lineWidth: 1))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        formCard {
                            sectionLabel("Detail Pemeriksaan")
                            dateRow("Tanggal Pemeriksaan", selection: $date)
                            PCTextField(label: "Diagnosa", placeholder: "Contoh: Sehat, kondisi prima", text: $diagnosis)
                            PCTextField(label: "Pengobatan (Opsional)", placeholder: "Contoh: Amoxicillin 0.5 tab", text: $treatment)
                        }

                        formCard {
                            sectionLabel("Tenaga Medis (Opsional)")
                            PCTextField(label: "Nama Dokter", placeholder: "Contoh: Dr. Hendra", text: $doctorName)
                            PCTextField(label: "Klinik / Rumah Sakit", placeholder: "Contoh: Klinik Hewan Sehat", text: $clinic)
                        }

                        formCard {
                            sectionLabel("Catatan Tambahan")
                            noteEditor(text: $notes)
                        }

                        PCPrimaryButton("Simpan Riwayat", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(diagnosis.isEmpty || selectedPetId == nil)
                            .opacity(diagnosis.isEmpty || selectedPetId == nil ? 0.5 : 1)

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
                    Text("Riwayat Kesehatan").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
        }
    }

    private func save() {
        guard let petId = selectedPetId else { return }
        let r = HealthRecord(petId: petId, date: date, type: type,
                             diagnosis: diagnosis,
                             treatment: treatment.isEmpty ? nil : treatment,
                             doctorName: doctorName.isEmpty ? nil : doctorName,
                             clinic: clinic.isEmpty ? nil : clinic,
                             notes: notes.isEmpty ? nil : notes)
        vm.addHealthRecord(r); dismiss()
    }
}

// ─────────────────────────────────────────
// MARK: AddWeightRecordView
// ─────────────────────────────────────────
struct AddWeightRecordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var selectedPetId: UUID?
    @State private var date   = Date()
    @State private var weight = ""
    @State private var notes  = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        formCard {
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Detail Penimbangan")
                            dateRow("Tanggal Penimbangan", selection: $date)
                            PCTextField(label: "Berat (kg)", placeholder: "Contoh: 5.2", text: $weight)
                                .keyboardType(.decimalPad)
                        }

                        formCard {
                            sectionLabel("Catatan (Opsional)")
                            noteEditor(text: $notes)
                        }

                        PCPrimaryButton("Simpan", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(weight.isEmpty || selectedPetId == nil)
                            .opacity(weight.isEmpty || selectedPetId == nil ? 0.5 : 1)

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
                    Text("Tambah Berat").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
        }
    }

    private func save() {
        guard let petId = selectedPetId,
              let w = Double(weight.replacingOccurrences(of: ",", with: "."))
        else { return }
        let r = WeightRecord(petId: petId, date: date, weight: w,
                             notes: notes.isEmpty ? nil : notes)
        dismiss()
        vm.addWeightRecord(r)
    }
}

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
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Waktu Makan")
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
                            sectionLabel("Makanan")
                            PCTextField(label: "Nama Makanan", placeholder: "Contoh: Dry Food Premium", text: $foodName)
                            PCTextField(label: "Porsi", placeholder: "Contoh: 200 gram", text: $portion)
                        }

                        formCard {
                            sectionLabel("Catatan (Opsional)")
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
// MARK: Shared Form Helpers
// ─────────────────────────────────────────

struct PetPickerChip: View {
    let pet: Pet; let selected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(pet.type.emoji).font(.system(size: 18))
                Text(pet.name).font(PCFont.subhead().weight(.semibold))
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .foregroundStyle(selected ? .white : Color.pcText2)
            .background(
                Capsule()
                    .fill(selected ? AnyShapeStyle(Color.primaryGradient) : AnyShapeStyle(Color.clear))
                    .overlay(Capsule().stroke(selected ? Color.clear : Color.pcBorder, lineWidth: 1))
            )
            .shadow(color: selected ? Color.pcIndigo.opacity(0.30) : .clear, radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// Helper functions for form layouts
func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 16) { content() }
        .padding(PCSpace.xl)
        .modifier(ElevatedGlassCard(radius: PCRadius.xxl))
        .padding(.horizontal, PCSpace.lg)
}

func sectionLabel(_ text: String) -> some View {
    Text(text.uppercased())
        .font(PCFont.micro())
        .foregroundStyle(Color.pcText3)
        .tracking(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
}

func dateRow(_ label: String, selection: Binding<Date>) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label.uppercased())
            .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
        DatePicker("", selection: selection, displayedComponents: .date)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(Color.pcIndigo)
    }
}

func noteEditor(text: Binding<String>) -> some View {
    TextEditor(text: text)
        .font(PCFont.subhead())
        .frame(height: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                    .stroke(Color.pcBorder, lineWidth: 0.5)))
        .scrollContentBackground(.hidden)
}

#Preview("Add Vaccine") { AddVaccineView().environmentObject(AppViewModel()) }
#Preview("Add Medication") { AddMedicationView().environmentObject(AppViewModel()) }
#Preview("Add Health Record") { AddHealthRecordView().environmentObject(AppViewModel()) }
#Preview("Add Feeding") { AddFeedingView().environmentObject(AppViewModel()) }

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
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Waktu Makan")
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
                            sectionLabel("Makanan")
                            PCTextField(label: "Nama Makanan", placeholder: "Contoh: Dry Food Premium", text: $foodName)
                            PCTextField(label: "Porsi", placeholder: "Contoh: 200 gram", text: $portion)
                        }

                        formCard {
                            sectionLabel("Catatan (Opsional)")
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

// ─────────────────────────────────────────
// MARK: AddScheduleFeedingView (used by ScheduleView)
// ─────────────────────────────────────────
struct AddScheduleFeedingView: View {
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
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Waktu Makan")
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
                            sectionLabel("Makanan")
                            PCTextField(label: "Nama Makanan", placeholder: "Contoh: Dry Food Premium", text: $foodName)
                            PCTextField(label: "Porsi", placeholder: "Contoh: 200 gram", text: $portion)
                        }

                        formCard {
                            sectionLabel("Catatan (Opsional)")
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
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Detail Vaksin")
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
                            sectionLabel("Info Klinik (Opsional)")
                            PCTextField(label: "Nama Klinik", placeholder: "Contoh: Klinik Hewan Sehat", text: $clinic)
                            PCTextField(label: "Nama Dokter", placeholder: "Contoh: Dr. Hendra", text: $doctorName)
                        }

                        formCard {
                            sectionLabel("Catatan (Opsional)")
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

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        formCard {
                            sectionLabel("Pilih Hewan")
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
                            sectionLabel("Detail Obat")
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

                        formCard {
                            sectionLabel("Durasi Pengobatan")
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
                            sectionLabel("Catatan (Opsional)")
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
                }
            }
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
        m.notes = notes.isEmpty ? nil : notes
        vm.updateMedication(m)
        vm.editingMedication = nil
        dismiss()
    }
}
