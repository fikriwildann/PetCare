// MARK: - EditViews.swift
// PetCare — Edit Pet + Edit Profile sheets

import SwiftUI

// ─────────────────────────────────────────
// MARK: EditPetView
// ─────────────────────────────────────────
struct EditPetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    let pet: Pet

    @State private var name: String
    @State private var type: PetType
    @State private var breed: String
    @State private var birthDate: Date
    @State private var gender: PetGender
    @State private var weight: String
    @State private var notes: String

    init(pet: Pet) {
        self.pet = pet
        _name      = State(initialValue: pet.name)
        _type      = State(initialValue: pet.type)
        _breed     = State(initialValue: pet.breed)
        _birthDate = State(initialValue: pet.birthDate)
        _gender    = State(initialValue: pet.gender)
        _weight    = State(initialValue: String(pet.weight))
        _notes     = State(initialValue: pet.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        // Avatar
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(type.accent.opacity(0.15))
                                    .frame(width: 96, height: 96)
                                Text(type.emoji).font(.system(size: 46))
                            }
                            Text("Tap untuk ubah foto")
                                .font(PCFont.caption()).foregroundStyle(Color.pcIndigo)
                        }
                        .padding(.top, PCSpace.md)

                        formCard {
                            sectionLabel("Informasi Dasar")
                            PCTextField(label: "Nama Hewan", placeholder: "Nama hewan", text: $name)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("JENIS HEWAN").font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(PetType.allCases, id: \.self) { t in
                                            Button { withAnimation(.pcSpring) { type = t } } label: {
                                                HStack(spacing: 6) {
                                                    Text(t.emoji)
                                                    Text(t.rawValue).font(PCFont.caption().weight(.semibold))
                                                }
                                                .padding(.horizontal, 14).padding(.vertical, 9)
                                                .foregroundStyle(type == t ? .white : Color.pcText2)
                                                .background(
                                                    Capsule()
                                                        .fill(type == t
                                                              ? AnyShapeStyle(Color.primaryGradient)
                                                              : AnyShapeStyle(Color.clear))
                                                        .overlay(Capsule()
                                                            .stroke(type == t ? Color.clear : Color.pcBorder,
                                                                    lineWidth: 1)))
                                            }.buttonStyle(.plain)
                                        }
                                    }
                                }
                            }

                            PCTextField(label: "Ras", placeholder: "Ras hewan", text: $breed)
                            dateRow("Tanggal Lahir", selection: $birthDate)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("JENIS KELAMIN").font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                HStack(spacing: 10) {
                                    ForEach(PetGender.allCases, id: \.self) { g in
                                        Button { withAnimation(.pcSpring) { gender = g } } label: {
                                            Text("\(g.symbol) \(g.rawValue)")
                                                .font(PCFont.subhead().weight(.semibold))
                                                .frame(maxWidth: .infinity).frame(height: 46)
                                                .foregroundStyle(gender == g ? Color.pcIndigo : Color.pcText2)
                                                .background(
                                                    RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                                                        .fill(gender == g ? Color.pcIndigo.opacity(0.10) : Color.clear)
                                                        .overlay(RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                                                            .stroke(gender == g ? Color.pcIndigo : Color.pcBorder,
                                                                    lineWidth: 1.5)))
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }

                            PCTextField(label: "Berat Badan (kg)", placeholder: "0.0",
                                        text: $weight, keyboardType: .decimalPad)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("CATATAN").font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                noteEditor(text: $notes)
                            }
                        }

                        PCPrimaryButton("Simpan Perubahan", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(name.isEmpty)
                            .opacity(name.isEmpty ? 0.5 : 1)

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
                    Text("Edit \(pet.name)").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        vm.deletePet(pet); dismiss()
                    } label: {
                        Image(systemName: "trash").foregroundStyle(Color.pcRed)
                    }
                }
            }
        }
    }

    private func save() {
        if let i = vm.pets.firstIndex(where: { $0.id == pet.id }) {
            var updated = vm.pets[i]
            updated.name      = name
            updated.type      = type
            updated.breed     = breed
            updated.birthDate = birthDate
            updated.gender    = gender
            updated.weight    = Double(weight) ?? pet.weight
            updated.notes     = notes.isEmpty ? nil : notes
            withAnimation(.pcSpring) { vm.pets[i] = updated }
        }
        dismiss()
    }
}

// ─────────────────────────────────────────
// MARK: EditProfileView
// ─────────────────────────────────────────
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var name:  String
    @State private var email: String

    init() {
        // Will be filled from vm in onAppear, placeholders here
        _name  = State(initialValue: "")
        _email = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 4)

                        // Avatar
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryGradient)
                                    .frame(width: 90, height: 90)
                                    .shadow(color: Color.pcIndigo.opacity(0.35), radius: 16, x: 0, y: 6)
                                Text("🧑").font(.system(size: 42))
                            }
                            Text("Ubah Foto Profil")
                                .font(PCFont.caption().weight(.semibold))
                                .foregroundStyle(Color.pcIndigo)
                        }
                        .padding(.top, PCSpace.md)

                        formCard {
                            sectionLabel("Informasi Akun")
                            PCTextField(label: "Nama Lengkap", placeholder: "Nama Anda", text: $name)
                            PCTextField(label: "Email", placeholder: "email@contoh.com",
                                        text: $email, keyboardType: .emailAddress)
                        }

                        PCPrimaryButton("Simpan Profil", icon: "checkmark") { save() }
                            .padding(.horizontal, PCSpace.lg)
                            .disabled(name.isEmpty || email.isEmpty)
                            .opacity(name.isEmpty || email.isEmpty ? 0.5 : 1)

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
                    Text("Edit Profil").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
        }
        .onAppear {
            name  = vm.currentUser.name
            email = vm.currentUser.email
        }
    }

    private func save() {
        vm.currentUser.name  = name
        vm.currentUser.email = email
        dismiss()
    }
}

#Preview("Edit Pet") {
    EditPetView(pet: SampleData.buddy).environmentObject(AppViewModel())
}
#Preview("Edit Profile") {
    EditProfileView().environmentObject(AppViewModel())
}
