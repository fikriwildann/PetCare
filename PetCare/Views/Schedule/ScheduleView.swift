// MARK: - ScheduleView.swift
// PetCare — Jadwal (Makan + Vaksin + Obat) with Liquid Glass

import SwiftUI

// ─────────────────────────────────────────
// MARK: ScheduleView (tab root)
// ─────────────────────────────────────────
struct ScheduleView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var segment = 0
    @State private var appeared = false

    private let segments = ["Semua", "Makan", "Vaksin", "Obat"]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PCMeshBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jadwal")
                            .font(PCFont.title1(.black)).foregroundStyle(Color.pcText1)
                        Text(Date().mediumDate)
                            .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                    }
                    Spacer()
                    PCIconNavButton(icon: "calendar") {}
                }
                .padding(.horizontal, PCSpace.lg)
                .padding(.vertical, PCSpace.sm)

                PCSegmentControl(options: segments, selected: $segment)
                    .padding(.bottom, PCSpace.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if segment == 0 || segment == 1 { feedingSection }
                        if segment == 0 || segment == 2 { vaccineSection }
                        if segment == 0 || segment == 3 { medicationSection }
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, PCSpace.sm)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Menu {
                Button { vm.showAddFeeding = true } label: {
                    Label("Jadwal Makan", systemImage: "fork.knife")
                }
                Button { vm.showAddVaccine = true } label: {
                    Label("Jadwal Vaksin", systemImage: "syringe.fill")
                }
                Button { vm.showAddMedication = true } label: {
                    Label("Jadwal Obat", systemImage: "pills.fill")
                }
            } label: {
                PCFAB(icon: "plus") {}
            }
                .padding(.trailing, PCSpace.lg)
                .padding(.bottom, 100)
        }
        .onAppear { withAnimation(.pcSpring) { appeared = true } }
    }

    // MARK: Feeding Section
    private var feedingSection: some View {
        VStack(spacing: 10) {
            PCSectionHeader(title: "Jadwal Makan Hari Ini")
                .padding(.horizontal, PCSpace.lg)

            // Meal time pills
            HStack(spacing: 10) {
                ForEach(MealType.allCases) { type in
                    let items = vm.feedings.filter { $0.mealType == type }
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(type.color.opacity(0.12))
                                .frame(width: 44, height: 44)
                                .overlay(Circle().stroke(type.color.opacity(0.20), lineWidth: 1))
                            Text(type.emoji).font(.system(size: 20))
                        }
                        Text(type.rawValue)
                            .font(PCFont.micro()).foregroundStyle(Color.pcText2)
                        Text("\(items.count)")
                            .font(PCFont.caption().weight(.bold)).foregroundStyle(type.color)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(PCSpace.md)
            .elevatedGlass(radius: PCRadius.xl)
            .padding(.horizontal, PCSpace.lg)

            ForEach(vm.feedings) { f in
                FeedingRow(feeding: f, petName: vm.petName(for: f.petId))
                    .padding(.horizontal, PCSpace.lg)
                    .onTapGesture { vm.toggleFeedingComplete(f.id) }
            }
        }
    }

    // MARK: Vaccine Section
    private var vaccineSection: some View {
        VStack(spacing: 10) {
            PCSectionHeader(title: "Vaksin", actionTitle: "Semua")
                .padding(.horizontal, PCSpace.lg)
            ForEach(vm.vaccines.prefix(4)) { v in
                VaccineScheduleRow(vaccine: v, petName: vm.petName(for: v.petId))
                    .padding(.horizontal, PCSpace.lg)
            }
        }
    }

    // MARK: Medication Section
    private var medicationSection: some View {
        VStack(spacing: 10) {
            PCSectionHeader(title: "Obat Aktif", actionTitle: "Semua")
                .padding(.horizontal, PCSpace.lg)
            ForEach(vm.activeMedications.prefix(3)) { m in
                MedicationScheduleRow(med: m, petName: vm.petName(for: m.petId))
                    .padding(.horizontal, PCSpace.lg)
            }
        }
    }
}

// MARK: - Row Components

struct FeedingRow: View {
    let feeding: FeedingSchedule
    let petName: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(feeding.mealType.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(feeding.mealType.emoji).font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("\(feeding.mealType.rawValue) — \(petName)")
                    .font(PCFont.subhead().weight(.semibold))
                    .foregroundStyle(Color.pcText1)
                Text("\(feeding.foodName) • \(feeding.portion)")
                    .font(PCFont.caption()).foregroundStyle(Color.pcText2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(feeding.time.timeOnly)
                    .font(PCFont.caption().weight(.bold)).foregroundStyle(Color.pcText2)
                PCBadge(
                    text: feeding.isCompleted ? "Selesai ✓" : "Belum",
                    color: feeding.isCompleted ? .pcGreen : .pcOrange,
                    small: true)
            }
        }
        .padding(14)
        .liquidGlass(radius: PCRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .stroke(feeding.isCompleted ? Color.pcGreen.opacity(0.20) : Color.clear, lineWidth: 1)
        )
    }
}

struct VaccineScheduleRow: View {
    let vaccine: Vaccine; let petName: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(vaccine.status.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: vaccine.status.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(vaccine.status.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("\(vaccine.name) — \(petName)")
                    .font(PCFont.subhead().weight(.semibold)).foregroundStyle(Color.pcText1)
                Text(vaccine.nextDate?.relative ?? vaccine.date.shortDate)
                    .font(PCFont.caption()).foregroundStyle(Color.pcText2)
            }
            Spacer()
            PCBadge(text: vaccine.status.rawValue, color: vaccine.status.color, small: true)
        }
        .padding(14)
        .liquidGlass(radius: PCRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .stroke(vaccine.status.color.opacity(0.18), lineWidth: 1)
        )
    }
}

struct MedicationScheduleRow: View {
    let med: Medication; let petName: String

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.pcPurple.opacity(0.12)).frame(width: 44, height: 44)
                    Text("💊").font(.system(size: 20))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(med.name) — \(petName)")
                        .font(PCFont.subhead().weight(.semibold)).foregroundStyle(Color.pcText1)
                    Text("\(med.dosage) • \(med.frequency.rawValue)")
                        .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                }
                Spacer()
                PCBadge(text: med.isActive ? "Aktif" : "Selesai",
                        color: med.isActive ? .pcPurple : .pcText3, small: true)
            }
            if let total = med.totalDays, total > 0 {
                VStack(spacing: 4) {
                    PCProgressBar(progress: med.progress, color: .pcPurple, height: 5)
                    HStack {
                        Text("\(med.daysCompleted) hari").font(PCFont.micro()).foregroundStyle(Color.pcText3)
                        Spacer()
                        Text("\(total) hari").font(PCFont.micro()).foregroundStyle(Color.pcText3)
                    }
                }
            }
        }
        .padding(14)
        .liquidGlass(radius: PCRadius.lg)
    }
}

// ─────────────────────────────────────────
// MARK: FeedingDetailView
// ─────────────────────────────────────────
struct FeedingDetailView: View {
    let pet: Pet
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    private var petFeedings: [FeedingSchedule] { vm.feedings(for: pet.id) }

    private func mealTypeSummaryCell(for type: MealType) -> some View {
        let count = petFeedings.filter { $0.mealType == type }.count
        return VStack(spacing: 6) {
            Text(type.emoji).font(.system(size: 24))
            Text(type.rawValue)
                .font(PCFont.micro()).foregroundStyle(Color.pcText2).lineLimit(1)
            Text(count > 0 ? "✓" : "—")
                .font(PCFont.caption().weight(.bold))
                .foregroundStyle(count > 0 ? Color.pcGreen : Color.pcText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .liquidGlass(radius: PCRadius.lg)
    }

    var body: some View {
        ZStack {
            PCMeshBackground()
            VStack(spacing: 0) {
                PCNavigationBar(title: "Jadwal Makan",
                                subtitle: pet.name,
                                leadingAction: { dismiss() })
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Summary row
                        HStack(spacing: 10) {
                            mealTypeSummaryCell(for: .breakfast)
                            mealTypeSummaryCell(for: .lunch)
                            mealTypeSummaryCell(for: .dinner)
                            mealTypeSummaryCell(for: .snack)
                        }
                        .padding(.horizontal, PCSpace.lg)

                        ForEach(petFeedings) { f in
                            FeedingRow(feeding: f, petName: pet.name)
                                .padding(.horizontal, PCSpace.lg)
                                .onTapGesture { vm.toggleFeedingComplete(f.id) }
                        }

                        if petFeedings.isEmpty {
                            PCEmptyState(icon: "fork.knife", title: "Belum Ada Jadwal",
                                         message: "Tambah jadwal makan untuk \(pet.name)")
                        }
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, PCSpace.sm)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview { ScheduleView().environmentObject(AppViewModel()) }
