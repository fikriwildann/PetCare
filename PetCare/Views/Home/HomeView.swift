// MARK: - HomeView.swift
// PetCare — Dashboard Beranda with Liquid Glass Hero + Stats

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var scrollOffset: CGFloat = 0
    @State private var appeared = false
    @Namespace private var ns
    @State private var showNotifications = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PCMeshBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    heroCard
                    statsGrid
                    petsSection
                    scheduleSection
                    healthSummary
                    Spacer().frame(height: 120)
                }
            }
            .coordinateSpace(name: "scroll")

            // FAB
            HStack {
                Spacer()
                PCFAB(icon: "plus") { vm.showAddPet = true }
                    .padding(.trailing, PCSpace.lg)
                    .padding(.bottom, 100)
            }
        }
        .onAppear { withAnimation(.pcSpring.delay(0.15)) { appeared = true } }
        .sheet(isPresented: $vm.showAddPet) { AddPetView() }
        .sheet(isPresented: $showNotifications) { NotificationListView() }
    }

    // MARK: Header
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(pcGreeting + ",")
                    .font(PCFont.subhead())
                    .foregroundStyle(Color.pcText2)
                Text(vm.currentUser.name.components(separatedBy: " ").first ?? "Kawan")
                    .font(PCFont.title1(.black))
                    .foregroundStyle(Color.pcText1)
                + Text(" 👋")
                    .font(PCFont.title1())
            }
            Spacer()
            HStack(spacing: 10) {
                PCIconNavButton(icon: "bell.fill", badge: vm.unreadCount) { showNotifications = true }
            }
        }
        .padding(.horizontal, PCSpace.lg)
        .padding(.top, PCSpace.sm)
        .padding(.bottom, PCSpace.md)
        .offset(y: appeared ? 0 : -16)
        .opacity(appeared ? 1 : 0)
        .animation(.pcSpring.delay(0.0), value: appeared)
    }

    // MARK: Hero Card
    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            RoundedRectangle(cornerRadius: PCRadius.xxxl, style: .continuous)
                .fill(Color.heroGradient)
                .frame(height: 170)
                .overlay(
                    // Glass highlight at top
                    RoundedRectangle(cornerRadius: PCRadius.xxxl, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [.white.opacity(0.35), .clear],
                                           startPoint: .top, endPoint: .bottom), lineWidth: 1.5))
                .shadow(color: Color.pcIndigo.opacity(0.40), radius: 28, x: 0, y: 12)

            // Decorative orbs
            Circle().fill(.white.opacity(0.07)).frame(width: 140).offset(x: 220, y: -20)
            Circle().fill(.white.opacity(0.05)).frame(width: 90).offset(x: 280, y: 40)
            Text("🐾").font(.system(size: 80)).opacity(0.08).offset(x: 210, y: 10)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Status Hari Ini")
                    .font(PCFont.caption().weight(.semibold))
                    .foregroundStyle(.white.opacity(0.70))
                Text("\(vm.pets.count) hewan sehat 🎉")
                    .font(PCFont.title2(.black))
                    .foregroundStyle(.white)
                HStack(spacing: 8) {
                    Label("\(vm.upcomingVaccines.count) vaksin menunggu",
                          systemImage: "syringe.fill")
                        .font(PCFont.micro())
                        .foregroundStyle(.white.opacity(0.80))
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())
                    Label("\(vm.activeMedications.count) obat aktif",
                          systemImage: "pills.fill")
                        .font(PCFont.micro())
                        .foregroundStyle(.white.opacity(0.80))
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .padding(.horizontal, PCSpace.lg)
        .padding(.bottom, PCSpace.md)
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.pcSpring.delay(0.08), value: appeared)
    }

    // MARK: Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(icon: "🐾", value: "\(vm.pets.count)", label: "Total Hewan",
                     color: .pcIndigo, delay: 0.10)
            StatCard(icon: "💉",
                     value: vm.upcomingVaccines.first.map { v in
                         if let d = v.daysUntilNext {
                             return d >= 0 ? "\(d) Hari" : "Terlambat"
                         }; return "—"
                     } ?? "Aman",
                     label: "Vaksin Terdekat",
                     color: .pcOrange, delay: 0.14)
            StatCard(icon: "🍖",
                     value: "\(vm.todayFeedings.count)×",
                     label: "Jadwal Makan",
                     color: .pcGreen, delay: 0.18)
            StatCard(icon: "💊",
                     value: "\(vm.activeMedications.count)",
                     label: "Obat Aktif",
                     color: .pcPurple, delay: 0.22)
        }
        .padding(.horizontal, PCSpace.lg)
        .padding(.bottom, PCSpace.md)
    }

    // MARK: Pets Section
    private var petsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Hewan Saya")
                    .font(PCFont.title3())
                    .foregroundStyle(Color.pcText1)
                Spacer()
                NavigationLink {
                    PetsListView()
                } label: {
                    Text("Lihat Semua")
                        .font(PCFont.subhead().weight(.semibold))
                        .foregroundStyle(Color.pcIndigo)
                }
            }
            .padding(.horizontal, PCSpace.lg)
            .padding(.bottom, PCSpace.sm)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.pets) { pet in
                        HomePetCard(pet: pet, namespace: ns)
                    }
                    // Add card
                    addPetCard
                }
                .padding(.horizontal, PCSpace.lg)
            }
        }
        .padding(.bottom, PCSpace.md)
        .offset(y: appeared ? 0 : 16).opacity(appeared ? 1 : 0)
        .animation(.pcSpring.delay(0.24), value: appeared)
    }

    private var addPetCard: some View {
        Button { vm.showAddPet = true } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .foregroundStyle(Color.pcText3.opacity(0.4))
                        .frame(width: 52, height: 52)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.pcText3)
                }
                Text("Tambah")
                    .font(PCFont.caption())
                    .foregroundStyle(Color.pcText3)
            }
            .frame(width: 120, height: 140)
            .liquidGlass(radius: PCRadius.xl)
        }
        .buttonStyle(.plain)
    }

    // MARK: Schedule Section
    private var scheduleSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Jadwal Terdekat")
                    .font(PCFont.title3())
                    .foregroundStyle(Color.pcText1)
                Spacer()
                NavigationLink {
                    ScheduleView()
                } label: {
                    Text("Semua")
                        .font(PCFont.subhead().weight(.semibold))
                        .foregroundStyle(Color.pcIndigo)
                }
            }
            .padding(.horizontal, PCSpace.lg)

            VStack(spacing: 8) {
                ForEach(vm.upcomingVaccines.prefix(2)) { v in
                    PCScheduleRow(
                        icon: "💉", iconColor: .pcOrange,
                        title: "\(v.name) — \(vm.petName(for: v.petId))",
                        subtitle: v.nextDate?.relative ?? "—",
                        badge: v.status.rawValue, badgeColor: v.status.color)
                    .padding(.horizontal, PCSpace.lg)
                }
                ForEach(vm.feedings.filter { !$0.isCompleted }.prefix(2)) { f in
                    PCScheduleRow(
                        icon: f.mealType.emoji, iconColor: f.mealType.color,
                        title: "\(f.mealType.rawValue) — \(vm.petName(for: f.petId))",
                        subtitle: "\(f.foodName) • \(f.time.timeOnly)",
                        badge: "Belum", badgeColor: .pcOrange)
                    .padding(.horizontal, PCSpace.lg)
                }
            }
        }
        .padding(.bottom, PCSpace.md)
        .offset(y: appeared ? 0 : 16).opacity(appeared ? 1 : 0)
        .animation(.pcSpring.delay(0.28), value: appeared)
    }

    // MARK: Health Summary
    private var healthSummary: some View {
        let currentPet = vm.selectedPet ?? vm.pets.first
        let currentPetId = currentPet?.id ?? UUID()
        let weightRecords = vm.weights(for: currentPetId)
        let latestWeight = weightRecords.last?.weight ?? currentPet?.weight ?? 0
        let hasPets = !vm.pets.isEmpty

        return VStack(spacing: 12) {
            HStack {
                Text("Ringkasan Kesehatan")
                    .font(PCFont.title3())
                    .foregroundStyle(Color.pcText1)
                Spacer()
                NavigationLink {
                    HealthView()
                } label: {
                    Text("Detail")
                        .font(PCFont.subhead().weight(.semibold))
                        .foregroundStyle(Color.pcIndigo)
                }
            }
            .padding(.horizontal, PCSpace.lg)

            VStack(spacing: 0) {
                HealthSummaryRow(
                    icon: "scalemass.fill", iconBg: Color.pcIndigo.opacity(0.12),
                    iconFg: .pcIndigo,
                    title: "Berat \(currentPet?.name ?? "—")",
                    value: hasPets ? String(format: "%.1f kg", latestWeight) : "Belum ada",
                    trailing: AnyView(
                        hasPets
                            ? AnyView(PCMiniBarChart(values: weightRecords.map { $0.weight }))
                            : AnyView(EmptyView())
                    ))
                Divider().padding(.leading, 58)
                HealthSummaryRow(
                    icon: "heart.fill", iconBg: Color.pcGreen.opacity(0.12),
                    iconFg: .pcGreen,
                    title: "Status Kesehatan",
                    value: "Sehat",
                    trailing: AnyView(
                        PCBadge(text: "Baik", color: .pcGreen)
                    ))
            }
            .padding(PCSpace.md)
            .elevatedGlass(radius: PCRadius.xl)
            .padding(.horizontal, PCSpace.lg)
        }
        .padding(.bottom, PCSpace.md)
        .offset(y: appeared ? 0 : 16).opacity(appeared ? 1 : 0)
        .animation(.pcSpring.delay(0.32), value: appeared)
    }
}

// MARK: - Sub-components

struct StatCard: View {
    let icon: String; let value: String; let label: String
    let color: Color; let delay: Double
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Circle().fill(color.opacity(0.12))
                    .frame(width: 64, height: 64)
                    .offset(x: 20, y: -20)
            }
            .frame(height: 8)

            Text(icon).font(.system(size: 30))

            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(PCFont.micro())
                .foregroundStyle(Color.pcText2)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(radius: PCRadius.xl)
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.pcBounce.delay(delay)) { appeared = true }
        }
    }
}

struct HomePetCard: View {
    let pet: Pet
    let namespace: Namespace.ID
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(pet.type.accent.opacity(0.14))
                    .frame(width: 56, height: 56)
                Text(pet.type.emoji).font(.system(size: 30))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(pet.name)
                    .font(PCFont.subhead().weight(.bold))
                    .foregroundStyle(Color.pcText1)
                Text(pet.breed)
                    .font(PCFont.caption())
                    .foregroundStyle(Color.pcText2)
                    .lineLimit(1)
                Text(pet.age)
                    .font(PCFont.micro())
                    .foregroundStyle(Color.pcText3)
            }
        }
        .padding(14)
        .frame(width: 120)
        .liquidGlass(radius: PCRadius.xl)
        .scaleEffect(appeared ? 1 : 0.85)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.pcBounce.delay(0.05)) { appeared = true }
        }
    }
}

struct HealthSummaryRow: View {
    let icon: String; let iconBg: Color; let iconFg: Color
    let title: String; let value: String
    let trailing: AnyView

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(iconBg).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(iconFg)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(PCFont.caption()).foregroundStyle(Color.pcText2)
                Text(value).font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
            }
            Spacer()
            trailing
        }
        .padding(.vertical, 8)
    }
}

#Preview { HomeView().environmentObject(AppViewModel()) }
