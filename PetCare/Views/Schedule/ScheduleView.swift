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
                    LazyVStack(spacing: 0) {
                        if segment == 0 {
                            if vm.feedings.isEmpty && vm.vaccines.isEmpty && vm.medications.isEmpty {
                                PCEmptyState(icon: "calendar", title: "Belum Ada Jadwal",
                                             message: "Tambahkan jadwal makan, vaksin, atau obat untuk hewan peliharaan Anda")
                                    .padding(.top, PCSpace.xxxl)
                            } else {
                                feedingSectionContent
                                if !vm.vaccines.isEmpty { vaccineSectionContent }
                                if !vm.activeMedications.isEmpty { medicationSectionContent }
                            }
                        } else if segment == 1 {
                            if vm.feedings.isEmpty {
                                PCEmptyState(icon: "fork.knife", title: "Belum Ada Jadwal Makan",
                                             message: "Tambah jadwal makan untuk hewan peliharaan Anda")
                            } else { feedingSectionContent }
                        } else if segment == 2 {
                            if vm.vaccines.isEmpty {
                                PCEmptyState(icon: "syringe.fill", title: "Belum Ada Jadwal Vaksin",
                                             message: "Tambah jadwal vaksin untuk hewan peliharaan Anda")
                            } else { vaccineSectionContent }
                        } else if segment == 3 {
                            if vm.activeMedications.isEmpty {
                                PCEmptyState(icon: "pills.fill", title: "Belum Ada Jadwal Obat",
                                             message: "Tambah jadwal obat untuk hewan peliharaan Anda")
                            } else { medicationSectionContent }
                        }
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
    @ViewBuilder
    private var feedingSectionContent: some View {
        PCSectionHeader(title: "Jadwal Makan Hari Ini")
            .padding(.horizontal, PCSpace.lg)
            .padding(.top, 5)

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

        VStack(spacing: 0) {
            ForEach(vm.feedings) { f in
                FeedingRow(feeding: f, petName: vm.petName(for: f.petId))
            }
        }
        .padding(.horizontal, PCSpace.lg)
        .padding(.top, PCSpace.sm)
    }

    // MARK: Vaccine Section
    @ViewBuilder
    private var vaccineSectionContent: some View {
        PCSectionHeader(title: "Vaksin")
            .padding(.horizontal, PCSpace.lg)
            .padding(.top, 5)
        VStack(spacing: 0) {
            ForEach(vm.vaccines.prefix(4)) { v in
                VaccineScheduleRow(vaccine: v, petName: vm.petName(for: v.petId))
            }
        }
        .padding(.horizontal, PCSpace.lg)
    }

    // MARK: Medication Section
    @ViewBuilder
    private var medicationSectionContent: some View {
        PCSectionHeader(title: "Obat Aktif")
            .padding(.horizontal, PCSpace.lg)
            .padding(.top, 5)
        VStack(spacing: 0) {
            ForEach(vm.activeMedications.prefix(3)) { m in
                MedicationScheduleRow(med: m, petName: vm.petName(for: m.petId))
            }
        }
        .padding(.horizontal, PCSpace.lg)
    }
}

// MARK: - Row Components

struct FeedingRow: View {
    let feeding: FeedingSchedule
    let petName: String
    @EnvironmentObject var vm: AppViewModel

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
        .padding(.horizontal, PCSpace.lg)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .fill(Color.pcCard.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .stroke(feeding.isCompleted ? Color.pcGreen.opacity(0.20) : Color.pcBorder, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                vm.editingFeeding = feeding
                vm.showEditFeeding = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                vm.deleteFeeding(feeding)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                vm.deleteFeeding(feeding)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                vm.editingFeeding = feeding
                vm.showEditFeeding = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .onTapGesture { vm.toggleFeedingComplete(feeding.id) }
    }
}

struct VaccineScheduleRow: View {
    let vaccine: Vaccine; let petName: String
    @EnvironmentObject var vm: AppViewModel

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
                Text(vaccine.status == .done ? vaccine.date.shortDate : (vaccine.nextDate?.relative ?? vaccine.date.shortDate))
                    .font(PCFont.caption()).foregroundStyle(Color.pcText2)
            }
            Spacer()
            PCBadge(text: vaccine.status.rawValue, color: vaccine.status.color, small: true)
        }
        .padding(.horizontal, PCSpace.lg)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .fill(Color.pcCard.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .stroke(vaccine.status.color.opacity(0.18), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                vm.editingVaccine = vaccine
                vm.showEditVaccine = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                vm.deleteVaccine(vaccine)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                vm.deleteVaccine(vaccine)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                vm.editingVaccine = vaccine
                vm.showEditVaccine = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

struct MedicationScheduleRow: View {
    let med: Medication; let petName: String
    @EnvironmentObject var vm: AppViewModel

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
        .padding(.horizontal, PCSpace.lg)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .fill(Color.pcCard.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .stroke(Color.pcPurple.opacity(0.18), lineWidth: 1)
        )
        .contextMenu {
            Button {
                vm.editingMedication = med
                vm.showEditMedication = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                vm.deleteMedication(med)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                vm.deleteMedication(med)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                vm.editingMedication = med
                vm.showEditMedication = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

#Preview { ScheduleView().environmentObject(AppViewModel()) }
