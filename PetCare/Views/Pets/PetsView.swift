// MARK: - PetsView.swift
// PetCare — Pets List, Add Pet, Detail

import SwiftUI

// ─────────────────────────────────────────
// MARK: PetsListView
// ─────────────────────────────────────────
struct PetsListView: View {
    @EnvironmentObject var vm: AppViewModel
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

    @State private var name     = ""
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
                                Text(type.emoji).font(.system(size: 46))
                            }
                            Text("Tap untuk tambah foto")
                                .font(PCFont.caption())
                                .foregroundStyle(Color.pcIndigo)
                        }
                        .padding(.top, PCSpace.md)

                        // Form card
                        VStack(spacing: 18) {
                            sectionHeader("Informasi Dasar")
                            PCTextField(label: "Nama Hewan", placeholder: "Contoh: Buddy", text: $name)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("JENIS HEWAN")
                                    .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(PetType.allCases, id: \.self) { t in
                                            Button { withAnimation(.pcSpring) { type = t } } label: {
                                                HStack(spacing: 6) {
                                                    Text(t.emoji)
                                                    Text(t.rawValue)
                                                        .font(PCFont.caption().weight(.semibold))
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
                                                                    lineWidth: 1))
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }

                            PCTextField(label: "Ras", placeholder: "Contoh: Golden Retriever", text: $breed)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("TANGGAL LAHIR")
                                    .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.pcIndigo)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("JENIS KELAMIN")
                                    .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                HStack(spacing: 10) {
                                    ForEach(PetGender.allCases, id: \.self) { g in
                                        Button { withAnimation(.pcSpring) { gender = g } } label: {
                                            Text("\(g.symbol) \(g.rawValue)")
                                                .font(PCFont.subhead().weight(.semibold))
                                                .frame(maxWidth: .infinity).frame(height: 46)
                                                .foregroundStyle(gender == g ? Color.pcIndigo : Color.pcText2)
                                                .background(
                                                    RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                                                        .fill(gender == g
                                                              ? Color.pcIndigo.opacity(0.10)
                                                              : Color.clear)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                                                                .stroke(gender == g ? Color.pcIndigo : Color.pcBorder, lineWidth: 1.5))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            PCTextField(label: "Berat Badan (kg)", placeholder: "0.0",
                                        text: $weight, keyboardType: .decimalPad)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("CATATAN")
                                    .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                                TextEditor(text: $notes)
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
                        }
                        .padding(PCSpace.xl)
                        .elevatedGlass(radius: PCRadius.xxl)
                        .padding(.horizontal, PCSpace.lg)

                        // Save
                        PCPrimaryButton("Simpan Hewan", icon: "checkmark") { save() }
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
                    Text("Tambah Hewan").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
        }
    }

    private func sectionHeader(_ t: String) -> some View {
        Text(t.uppercased())
            .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        let pet = Pet(name: name, type: type, breed: breed, birthDate: birthDate,
                      gender: gender, weight: Double(weight) ?? 0, notes: notes.isEmpty ? nil : notes)
        vm.addPet(pet)
        vm.selectedPet = pet
        vm.selectedTab = 2
        vm.showAddFeeding = true
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
    @Namespace private var ns

    var body: some View {
        ZStack(alignment: .top) {
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
                Button {} label: {
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
                        .foregroundStyle(.white)
                    Text("\(pet.breed) • \(pet.gender.symbol) \(pet.gender.rawValue)")
                        .font(PCFont.subhead())
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .padding(.bottom, 32)
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)
        }
    }

    // MARK: Stats Strip
    private var statsStrip: some View {
        HStack(spacing: 0) {
            ForEach([
                ("Umur", pet.age),
                ("Berat", String(format: "%.1f kg", pet.weight)),
                ("Vaksin", "\(vm.vaccines(for: pet.id).count)")
            ], id: \.0) { item in
                VStack(spacing: 4) {
                    Text(item.1)
                        .font(PCFont.title3(.black))
                        .foregroundStyle(Color.pcText1)
                    Text(item.0)
                        .font(PCFont.micro())
                        .foregroundStyle(Color.pcText2)
                }
                .frame(maxWidth: .infinity)
                if item.0 != "Vaksin" {
                    Divider().frame(height: 30)
                }
            }
        }
        .padding(PCSpace.md)
        .elevatedGlass(radius: PCRadius.xl)
        .padding(.horizontal, PCSpace.lg)
        .offset(y: -20)
    }

    // MARK: Quick Actions
    private var quickActions: some View {
        VStack(spacing: 12) {
            PCSectionHeader(title: "Aksi Cepat")
                .padding(.horizontal, PCSpace.lg)
            HStack(spacing: 12) {
                ForEach([
                    ("💉","Vaksin", Color.pcOrange),
                    ("🍖","Makan",  Color.pcGreen),
                    ("💊","Obat",   Color.pcPurple),
                    ("📋","Riwayat",Color.pcIndigo)
                ], id: \.0) { item in
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(item.2.opacity(0.12))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(item.2.opacity(0.20), lineWidth: 1))
                            Text(item.0).font(.system(size: 22))
                        }
                        Text(item.1).font(PCFont.micro()).foregroundStyle(Color.pcText2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, PCSpace.lg)
        }
        .padding(.bottom, PCSpace.md)
    }

    // MARK: Active Schedules
    private var activeSchedules: some View {
        VStack(spacing: 12) {
            PCSectionHeader(title: "Jadwal Aktif")
                .padding(.horizontal, PCSpace.lg)
            VStack(spacing: 8) {
                ForEach(vm.vaccines(for: pet.id).filter { $0.status == .upcoming }.prefix(2)) { v in
                    PCScheduleRow(icon: "💉", iconColor: .pcOrange,
                                  title: v.name,
                                  subtitle: v.nextDate?.relative ?? "—",
                                  badge: v.status.rawValue, badgeColor: v.status.color)
                    .padding(.horizontal, PCSpace.lg)
                }
                ForEach(vm.medications(for: pet.id).filter { $0.isActive }.prefix(2)) { m in
                    PCScheduleRow(icon: "💊", iconColor: .pcPurple,
                                  title: m.name, subtitle: m.dosage + " • " + m.frequency.rawValue,
                                  badge: "Aktif", badgeColor: .pcPurple)
                    .padding(.horizontal, PCSpace.lg)
                }
            }
        }
        .padding(.bottom, PCSpace.md)
    }

    // MARK: Weight mini chart
    private var weightPreview: some View {
        VStack(spacing: 12) {
            PCSectionHeader(title: "Berat Badan", actionTitle: "Lihat Grafik")
                .padding(.horizontal, PCSpace.lg)
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sekarang").font(PCFont.caption()).foregroundStyle(Color.pcText2)
                    Text(String(format: "%.1f kg", pet.weight))
                        .font(PCFont.title2(.black)).foregroundStyle(Color.pcIndigo)
                }
                Spacer()
                PCMiniBarChart(
                    values: vm.weights(for: pet.id).map { $0.weight },
                    color: .pcIndigo, height: 44)
            }
            .padding(PCSpace.md)
            .elevatedGlass(radius: PCRadius.xl)
            .padding(.horizontal, PCSpace.lg)
        }
    }
}

#Preview("List") { NavigationStack { PetsListView() }.environmentObject(AppViewModel()) }
#Preview("Detail") { NavigationStack { PetDetailView(pet: SampleData.buddy) }.environmentObject(AppViewModel()) }
