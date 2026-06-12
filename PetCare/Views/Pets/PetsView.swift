// MARK: - PetsView.swift
// PetCare — Pets List, Add Pet, Detail

import SwiftUI

// ─────────────────────────────────────────
// MARK: PetsListView
// ─────────────────────────────────────────
struct PetsListView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var search = ""
    @State private var filter: PetType? = nil
    @State private var appeared = false
    @Namespace private var ns

    private var filtered: [Pet] {
        vm.pets.filter { p in
            let matchType = filter == nil || p.type == filter
            let matchSearch = search.isEmpty || p.name.localizedCaseInsensitiveContains(search) ||
                              p.breed.localizedCaseInsensitiveContains(search)
            return matchType && matchSearch
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PCMeshBackground()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.pcIndigo)
                            .frame(width: 36, height: 36)
                            .background(Color.pcIndigo.opacity(0.12))
                            .clipShape(Circle())
                    }

                    Text("Hewan Saya")
                        .font(PCFont.title1(.black))
                        .foregroundStyle(Color.pcText1)
                    Spacer()
                    PCIconNavButton(icon: "plus") { vm.showAddPet = true }
                }
                .padding(.horizontal, PCSpace.lg)
                .padding(.vertical, PCSpace.sm)

                // Search
                PCGlassSearchBar(text: $search)
                    .padding(.horizontal, PCSpace.lg)
                    .padding(.bottom, PCSpace.sm)

                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(label: "Semua", active: filter == nil) { filter = nil }
                        ForEach(PetType.allCases, id: \.self) { t in
                            FilterPill(label: "\(t.emoji) \(t.rawValue)", active: filter == t) { filter = t }
                        }
                    }
                    .padding(.horizontal, PCSpace.lg)
                }
                .padding(.bottom, PCSpace.sm)

                // List
                if filtered.isEmpty {
                    PCEmptyState(icon: "pawprint", title: "Belum Ada Hewan",
                                 message: "Tambah hewan peliharaan pertama Anda",
                                 action: { vm.showAddPet = true })
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { pet in
                                NavigationLink {
                                    PetDetailView(pet: pet)
                                } label: {
                                    PetListRow(pet: pet, namespace: ns)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) { vm.deletePet(pet) } label: {
                                        Label("Hapus", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, PCSpace.lg)
                        .padding(.bottom, 120)
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            // FAB
            PCFAB(icon: "plus") { vm.showAddPet = true }
                .padding(.trailing, PCSpace.lg)
                .padding(.bottom, 100)
        }
        .navigationBarHidden(true)
        .onAppear { withAnimation(.pcSpring) { appeared = true } }
        .sheet(isPresented: $vm.showAddPet) { AddPetView() }
    }
}

// MARK: - PetListRow
struct PetListRow: View {
    let pet: Pet
    let namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(pet.type.accent.opacity(0.14))
                    .frame(width: 68, height: 68)
                Text(pet.type.emoji).font(.system(size: 36))
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(pet.name)
                    .font(PCFont.subhead().weight(.bold))
                    .foregroundStyle(Color.pcText1)
                Text("\(pet.breed) • \(pet.age)")
                    .font(PCFont.caption())
                    .foregroundStyle(Color.pcText2)
                HStack(spacing: 6) {
                    PCBadge(text: String(format: "%.1f kg", pet.weight),
                            color: pet.type.accent, small: true)
                    PCBadge(text: "Sehat", color: .pcGreen, small: true)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.pcText3)
        }
        .padding(16)
        .liquidGlass(radius: PCRadius.xl)
    }
}

// MARK: - FilterPill (local)
struct FilterPill: View {
    let label: String; let active: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(PCFont.caption().weight(.semibold))
                .foregroundStyle(active ? .white : Color.pcText2)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(
                    Capsule().fill(active
                                   ? AnyShapeStyle(Color.primaryGradient)
                                   : AnyShapeStyle(Color.clear))
                    .overlay(Capsule().stroke(active ? Color.clear : Color.pcBorder, lineWidth: 1))
                )
                .shadow(color: active ? Color.pcIndigo.opacity(0.3) : .clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.pcSpring, value: active)
    }
}

// ─────────────────────────────────────────
// MARK: AddPetView
// ─────────────────────────────────────────
struct AddPetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var name = ""
    @State private var type: PetType = .dog
    @State private var breed    = ""
    @State private var birthDate = Date()
    @State private var gender: PetGender = .male
    @State private var weight   = ""
    @State private var notes    = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Photo placeholder
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color.primaryGradient)
                                    .frame(width: 96, height: 96)
                                    .shadow(color: Color.pcIndigo.opacity(0.35), radius: 16, x: 0, y: 6)
                                Text(type.emoji).font(.system(size: 44))
                            }
                            Text("Tambah Foto")
                                .font(PCFont.caption())
                                .foregroundStyle(Color.pcText2)
                        }
                        .padding(.top, PCSpace.lg)

                        // Form
                        VStack(spacing: 16) {
                            PCTextField(label: "Nama", placeholder: "Nama hewan", text: $name)

                            // Pet Type Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Jenis")
                                    .font(PCFont.caption())
                                    .foregroundStyle(Color.pcText2)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(PetType.allCases, id: \.self) { petType in
                                            Button {
                                                type = petType
                                            } label: {
                                                Text("\(petType.emoji) \(petType.rawValue)")
                                                    .font(PCFont.caption().weight(.semibold))
                                                    .foregroundStyle(type == petType ? .white : Color.pcText2)
                                                    .padding(.horizontal, 16).padding(.vertical, 8)
                                                    .background(
                                                        Capsule().fill(type == petType
                                                                       ? AnyShapeStyle(Color.primaryGradient)
                                                                       : AnyShapeStyle(Color.clear))
                                                        .overlay(Capsule().stroke(type == petType ? Color.clear : Color.pcBorder, lineWidth: 1))
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }

                            PCTextField(label: "Ras", placeholder: "Ras/Jenis", text: $breed)

                            // Date Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tanggal Lahir")
                                    .font(PCFont.caption())
                                    .foregroundStyle(Color.pcText2)
                                DatePicker("", selection: $birthDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .padding(PCSpace.md)
                                    .background(Color.pcText1.opacity(0.05))
                                    .cornerRadius(PCRadius.md)
                            }

                            // Gender Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Jenis Kelamin")
                                    .font(PCFont.caption())
                                    .foregroundStyle(Color.pcText2)
                                HStack(spacing: 8) {
                                    ForEach(PetGender.allCases, id: \.self) { petGender in
                                        Button {
                                            gender = petGender
                                        } label: {
                                            Text(petGender.rawValue)
                                                .font(PCFont.caption().weight(.semibold))
                                                .foregroundStyle(gender == petGender ? .white : Color.pcText2)
                                                .padding(.horizontal, 20).padding(.vertical, 10)
                                                .background(
                                                    Capsule().fill(gender == petGender
                                                                   ? AnyShapeStyle(Color.primaryGradient)
                                                                   : AnyShapeStyle(Color.clear))
                                                    .overlay(Capsule().stroke(gender == petGender ? Color.clear : Color.pcBorder, lineWidth: 1))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            PCTextField(label: "Berat (kg)", placeholder: "Berat dalam kg", text: $weight, keyboardType: .decimalPad)
                            PCTextField(label: "Catatan", placeholder: "Catatan kesehatan", text: $notes)
                        }
                        .padding(PCSpace.xl)
                        .elevatedGlass(radius: PCRadius.xxl)

                        // Save button
                        PCPrimaryButton("Simpan", icon: "checkmark") {
                            savePet()
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.55 : 1)
                        .padding(.horizontal, PCSpace.lg)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.pcText2)
                    }
                }
            }
        }
    }

    private func savePet() {
        let w = Double(weight) ?? 0
        let pet = Pet(
            name: name, type: type, breed: breed,
            birthDate: birthDate, gender: gender,
            weight: w, photoName: nil, notes: notes.isEmpty ? nil : notes)
        Task { try? await FirebasePetService.shared.addPet(pet) }
        vm.pets.append(pet)
        dismiss()
    }
}

// ─────────────────────────────────────────
// MARK: PetDetailView
// ─────────────────────────────────────────
struct PetDetailView: View {
    let pet: Pet
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var appeared = false
    @State private var showEditSheet = false
    @Namespace private var ns

    var body: some View {
        ZStack {
            PCMeshBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    detailHero
                    statsStrip
                    quickActions
                    activeSchedules
                    weightPreview
                    Spacer().frame(height: 120)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Nav overlay
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.20))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.30), lineWidth: 1))
                }
                .buttonStyle(.plain)
                Spacer()
                Button { showEditSheet = true } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.20))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.30), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, PCSpace.lg)
            .padding(.top, 56)
        }
        .navigationBarHidden(true)
        .onAppear { withAnimation(.pcSpring.delay(0.1)) { appeared = true } }
        .sheet(isPresented: $showEditSheet) {
            EditPetView(pet: pet)
        }
    }

    // MARK: Hero
    private var detailHero: some View {
        ZStack(alignment: .bottom) {
            // Gradient bg
            LinearGradient(
                colors: [Color(hex: "#312E81"), pet.type.accent, pet.type.accent.opacity(0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(.white.opacity(0.08), lineWidth: 0))

            // Decorative orbs
            Circle().fill(.white.opacity(0.06)).frame(width: 180).offset(x: 100, y: -60)
            Circle().fill(.white.opacity(0.04)).frame(width: 120).offset(x: -90, y: 20)

            // Pet info
            VStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 2))
                        .shadow(color: .black.opacity(0.20), radius: 20, x: 0, y: 8)
                    Text(pet.type.emoji).font(.system(size: 50))
                }

                VStack(spacing: 6) {
                    Text(pet.name)
                        .font(PCFont.title1(.black))
                        .foregroundStyle(Color.pcText1)
                    Spacer()
                }
                .padding(.horizontal, PCSpace.lg)
                .padding(.vertical, PCSpace.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Hero
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryGradient)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color.pcIndigo.opacity(0.35), radius: 20, x: 0, y: 8)
                                Text(pet.type.emoji).font(.system(size: 50))
                            }
                            VStack(spacing: 4) {
                                Text(pet.name)
                                    .font(PCFont.display(.black))
                                    .foregroundStyle(Color.pcText1)
                                Text(pet.breed)
                                    .font(PCFont.subhead())
                                    .foregroundStyle(Color.pcText2)
                            }
                        }
                        .padding(.top, PCSpace.md)

                        // Info cards
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                InfoCard(icon: "scalemass.fill", label: "Berat", value: String(format: "%.1f kg", pet.weight), color: .pcIndigo)
                                InfoCard(icon: "heart.fill", label: "Status", value: "Sehat", color: .pcGreen)
                            }
                            HStack(spacing: 12) {
                                InfoCard(icon: "calendar", label: "Umur", value: pet.age, color: .pcOrange)
                                InfoCard(icon: pet.gender == .male ? "male.fill" : "female.fill", label: "Jenis Kelamin", value: pet.gender.rawValue, color: .pcPurple)
                            }
                        }
                        .padding(.horizontal, PCSpace.lg)

                        // Quick Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aksi Cepat")
                                .font(PCFont.title3())
                                .foregroundStyle(Color.pcText1)
                            HStack(spacing: 12) {
                                QuickActionButton(icon: "syringe.fill", label: "Vaksin", color: .pcOrange) { }
                                QuickActionButton(icon: "fork.knife", label: "Makan", color: .pcGreen) { }
                                QuickActionButton(icon: "pills.fill", label: "Obat", color: .pcPurple) { }
                                QuickActionButton(icon: "heart.text.square.fill", label: "Kesehatan", color: .pcIndigo) { }
                            }
                        }
                        .padding(.horizontal, PCSpace.lg)

                        // Weight Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Berat Badan")
                                .font(PCFont.title3())
                                .foregroundStyle(Color.pcText1)
                            PCMiniBarChart(values: [26.5, 27.2, 27.3, 28.1, 27.8, 28.5])
                        }
                        .padding(.horizontal, PCSpace.lg)

                        Spacer().frame(height: 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear { withAnimation(.pcSpring) { appeared = true } }
    }
}

struct InfoCard: View {
    let icon: String; let label: String; let value: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundStyle(color)
            }
            Text(label).font(PCFont.micro()).foregroundStyle(Color.pcText2)
            Text(value).font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
        }
        .frame(maxWidth: .infinity)
        .padding(PCSpace.md)
        .liquidGlass(radius: PCRadius.lg)
    }
}

struct QuickActionButton: View {
    let icon: String; let label: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: icon).font(.system(size: 20)).foregroundStyle(color))
                Text(label).font(PCFont.micro()).foregroundStyle(Color.pcText2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PCSpace.sm)
            .liquidGlass(radius: PCRadius.lg)
        }
        .buttonStyle(.plain)
    }
}

#Preview("List") { NavigationStack { PetsListView() }.environmentObject(AppViewModel()) }
#Preview("Detail") { NavigationStack { PetDetailView(pet: SampleData.buddy) }.environmentObject(AppViewModel()) }
