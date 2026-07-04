// MARK: - HealthRecordForms.swift
// PetCare — Add Health Record and Weight Record forms

import SwiftUI

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
                            PCSectionLabel(text: "Jenis Pemeriksaan")
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
                            PCSectionLabel(text: "Detail Pemeriksaan")
                            dateRow("Tanggal Pemeriksaan", selection: $date)
                            PCTextField(label: "Diagnosa", placeholder: "Contoh: Sehat, kondisi prima", text: $diagnosis)
                            PCTextField(label: "Pengobatan (Opsional)", placeholder: "Contoh: Amoxicillin 0.5 tab", text: $treatment)
                        }

                        formCard {
                            PCSectionLabel(text: "Tenaga Medis (Opsional)")
                            PCTextField(label: "Nama Dokter", placeholder: "Contoh: Dr. Hendra", text: $doctorName)
                            PCTextField(label: "Klinik / Rumah Sakit", placeholder: "Contoh: Klinik Hewan Sehat", text: $clinic)
                        }

                        formCard {
                            PCSectionLabel(text: "Catatan Tambahan")
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
                            PCSectionLabel(text: "Detail Penimbangan")
                            dateRow("Tanggal Penimbangan", selection: $date)
                            PCTextField(label: "Berat (kg)", placeholder: "Contoh: 5.2", text: $weight)
                                .keyboardType(.decimalPad)
                        }

                        formCard {
                            PCSectionLabel(text: "Catatan (Opsional)")
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

#Preview("Add Health Record") { AddHealthRecordView().environmentObject(AppViewModel()) }
#Preview("Add Weight Record") { AddWeightRecordView().environmentObject(AppViewModel()) }
