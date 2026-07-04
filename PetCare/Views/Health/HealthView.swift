// MARK: - HealthView.swift
// PetCare — Health Hub: Vaccine, Medication, History, Weight Chart

import SwiftUI
import Charts

// ─────────────────────────────────────────
// MARK: HealthView (tab root)
// ─────────────────────────────────────────
struct HealthView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var appeared = false

    var body: some View {
        ZStack {
            PCMeshBackground()
            VStack(spacing: 0) {
                HStack {
                    Text("Kesehatan")
                        .font(PCFont.title1(.black)).foregroundStyle(Color.pcText1)
                    Spacer()
                    PCIconNavButton(icon: "heart.fill") {}
                }
                .padding(.horizontal, PCSpace.lg).padding(.vertical, PCSpace.sm)

                PCSegmentControl(options: ["Vaksin","Obat","Riwayat","Berat"], selected: $vm.selectedHealthSegment)
                    .padding(.bottom, PCSpace.sm)

                Group {
                    switch vm.selectedHealthSegment {
                    case 0:
                        if vm.vaccines.isEmpty {
                            PCEmptyState(icon: "syringe.fill", title: "Belum Ada Vaksin",
                                        message: "Tambah jadwal vaksin untuk hewan peliharaan Anda")
                        } else {
                            VaccineListView()
                        }
                    case 1:
                        if vm.medications.isEmpty {
                            PCEmptyState(icon: "pills.fill", title: "Belum Ada Obat",
                                        message: "Tambah jadwal obat untuk hewan peliharaan Anda")
                        } else {
                            MedicationListView()
                        }
                    case 2: HealthHistoryView()
                    case 3:
                        if let pet = vm.selectedPet ?? vm.pets.first {
                            WeightChartView(pet: pet)
                        } else {
                            PCEmptyState(icon: "scalemass", title: "Belum Ada Data",
                                        message: "Tambahkan hewan terlebih dahulu untuk melihat berat")
                        }
                    default: EmptyView()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                .animation(.pcSpring, value: vm.selectedHealthSegment)
            }
        }
        .onAppear {
            withAnimation(.pcSpring) { appeared = true }
            if vm.navigateToWeightChart {
                vm.selectedHealthSegment = 3
                vm.navigateToWeightChart = false
            }
        }
        .sheet(isPresented: $vm.showAddHealthRecord) {
            AddHealthRecordView()
        }
        .sheet(isPresented: $vm.showAddWeight) {
            AddWeightRecordView()
        }
        .overlay(alignment: .bottomTrailing) {
            if vm.selectedHealthSegment == 3 {
                PCFAB(icon: "plus") { vm.showAddWeight = true }
                    .padding(.trailing, PCSpace.lg)
                    .padding(.bottom, 100)
            }
        }
    }
}

// ─────────────────────────────────────────
// MARK: VaccineListView
// ─────────────────────────────────────────
struct VaccineListView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var filterStatus: VaccineStatus? = nil

    private var filtered: [Vaccine] {
        guard let s = filterStatus else { return vm.vaccines }
        return vm.vaccines.filter { $0.status == s }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(label: "Semua", active: filterStatus == nil) { filterStatus = nil }
                        ForEach([VaccineStatus.upcoming, .done, .overdue], id: \.self) { s in
                            FilterPill(label: s.rawValue, active: filterStatus == s) { filterStatus = s }
                        }
                    }.padding(.horizontal, PCSpace.lg)
                }.padding(.bottom, PCSpace.sm)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(filtered) { v in
                            VaccineCard(vaccine: v, petName: vm.petName(for: v.petId))
                                .padding(.horizontal, PCSpace.lg)
                        }
                        Spacer().frame(height: 120)
                    }.padding(.top, PCSpace.xs)
                }
            }
            PCFAB(icon: "plus") { vm.showAddVaccine = true }
                .padding(.trailing, PCSpace.lg).padding(.bottom, 100)
        }
    }
}

struct VaccineCard: View {
    let vaccine: Vaccine; let petName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vaccine.name)
                        .font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
                    Text("🐾 \(petName)")
                        .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                }
                Spacer()
                PCBadge(text: vaccine.status.rawValue, color: vaccine.status.color)
            }
            HStack(spacing: 16) {
                Label(vaccine.date.shortDate, systemImage: "calendar")
                    .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                if let clinic = vaccine.clinic {
                    Label(clinic, systemImage: "cross.case")
                        .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                        .lineLimit(1)
                }
            }
            if let days = vaccine.daysUntilNext {
                HStack(spacing: 6) {
                    Image(systemName: days < 0 ? "exclamationmark.circle.fill" : "clock.fill")
                        .foregroundStyle(vaccine.status.color)
                        .font(.system(size: 12))
                    Text(days < 0 ? "\(-days) hari terlambat" : (days == 0 ? "Hari ini!" : "\(days) hari lagi"))
                        .font(PCFont.caption().weight(.semibold))
                        .foregroundStyle(vaccine.status.color)
                }
            }
        }
        .padding(16)
        .liquidGlass(radius: PCRadius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: PCRadius.xl, style: .continuous)
                .stroke(vaccine.status.color.opacity(0.25), lineWidth: 1)
        )
    }
}

// ─────────────────────────────────────────
// MARK: MedicationListView
// ─────────────────────────────────────────
struct MedicationListView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    if !vm.activeMedications.isEmpty {
                        PCSectionLabel(text: "Aktif")
                            .padding(.horizontal, PCSpace.lg)
                            .padding(.top, PCSpace.xs)
                        ForEach(vm.activeMedications) { m in
                            MedicationCard(med: m, petName: vm.petName(for: m.petId))
                                .padding(.horizontal, PCSpace.lg)
                        }
                    }
                    let inactive = vm.medications.filter { !$0.isActive }
                    if !inactive.isEmpty {
                        PCSectionLabel(text: "Selesai")
                            .padding(.horizontal, PCSpace.lg)
                            .padding(.top, PCSpace.xs)
                            .opacity(0.7)
                        ForEach(inactive) { m in
                            MedicationCard(med: m, petName: vm.petName(for: m.petId))
                                .padding(.horizontal, PCSpace.lg)
                                .opacity(0.6)
                        }
                    }
                    Spacer().frame(height: 120)
                }
                .padding(.top, PCSpace.sm)
            }
            PCFAB(icon: "plus") { vm.showAddMedication = true }
                .padding(.trailing, PCSpace.lg).padding(.bottom, 100)
        }
    }
}

struct MedicationCard: View {
    let med: Medication; let petName: String

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                // Accent bar
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(med.isActive ? Color.pcPurple : Color.pcText3)
                    .frame(width: 4)
                    .padding(.trailing, 14)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(med.name)
                                .font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
                            Text("🐾 \(petName)")
                                .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                        }
                        Spacer()
                        PCBadge(text: med.isActive ? "Aktif" : "Selesai",
                                color: med.isActive ? .pcPurple : .pcText3)
                    }
                    HStack(spacing: 12) {
                        Label(med.dosage, systemImage: "pills")
                            .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                        Label(med.frequency.rawValue, systemImage: "clock")
                            .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                    }
                    if let total = med.totalDays, total > 0 {
                        VStack(spacing: 4) {
                            PCProgressBar(progress: med.progress, color: .pcPurple, height: 6)
                            HStack {
                                Text("\(med.daysCompleted) hari").font(PCFont.micro()).foregroundStyle(Color.pcText3)
                                Spacer()
                                Text("\(total) hari").font(PCFont.micro()).foregroundStyle(Color.pcText3)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .liquidGlass(radius: PCRadius.xl)
    }
}

// ─────────────────────────────────────────
// MARK: HealthHistoryView
// ─────────────────────────────────────────
struct HealthHistoryView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var expanded: UUID? = nil
    @State private var selectedPetId: UUID? = nil

    private var filteredRecords: [HealthRecord] {
        if let pid = selectedPetId {
            return vm.healthRecords.filter { $0.petId == pid }
        }
        return vm.healthRecords
    }

    private var selectedPetName: String {
        if let pid = selectedPetId, let pet = vm.pets.first(where: { $0.id == pid }) {
            return pet.name
        }
        return "Semua Hewan"
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Pet filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(label: "Semua", active: selectedPetId == nil) {
                                withAnimation(.pcSpring) { selectedPetId = nil }
                            }
                            ForEach(vm.pets) { p in
                                FilterPill(label: "\(p.type.emoji) \(p.name)", active: selectedPetId == p.id) {
                                    withAnimation(.pcSpring) { selectedPetId = p.id }
                                }
                            }
                        }
                        .padding(.horizontal, PCSpace.lg)
                    }
                    .padding(.bottom, PCSpace.sm)

                    ForEach(filteredRecords.indices, id: \.self) { i in
                        TimelineItem(record: filteredRecords[i],
                                     isLast: i == filteredRecords.count - 1,
                                     expanded: $expanded)
                        .padding(.horizontal, PCSpace.lg)
                    }
                    if filteredRecords.isEmpty {
                        PCEmptyState(icon: "clipboard", title: "Belum Ada Riwayat",
                                     message: selectedPetId == nil ? "Catat pemeriksaan kesehatan pertama" : "Belum ada riwayat untuk \(selectedPetName)")
                    }
                    Spacer().frame(height: 120)
                }
                .padding(.top, PCSpace.sm)
            }
            PCFAB(icon: "plus") { vm.showAddHealthRecord = true }
                .padding(.trailing, PCSpace.lg).padding(.bottom, 100)
        }
    }
}

struct TimelineItem: View {
    let record: HealthRecord
    let isLast: Bool
    @Binding var expanded: UUID?

    private var isExpanded: Bool { expanded == record.id }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline spine
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(record.type.color.opacity(0.15)).frame(width: 36, height: 36)
                    Text(record.type.emoji).font(.system(size: 16))
                }
                if !isLast {
                    Rectangle()
                        .fill(Color.pcBorder)
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            .frame(width: 36)

            // Card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.date.shortDate)
                            .font(PCFont.micro()).foregroundStyle(Color.pcText3)
                        Text(record.type.rawValue)
                            .font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.pcText3)
                }

                if let clinic = record.clinic {
                    Label(clinic, systemImage: "cross.case")
                        .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                        infoRow("Diagnosa", record.diagnosis)
                        if let t = record.treatment { infoRow("Pengobatan", t) }
                        if let d = record.doctorName { infoRow("Dokter", d) }
                        if let n = record.notes { infoRow("Catatan", n) }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .liquidGlass(radius: PCRadius.lg)
            .onTapGesture {
                withAnimation(.pcSpring) {
                    expanded = isExpanded ? nil : record.id
                }
            }
        }
        .padding(.bottom, 12)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.4)
            Text(value).font(PCFont.caption()).foregroundStyle(Color.pcText1)
        }
    }
}

// ─────────────────────────────────────────
// MARK: WeightChartView
// ─────────────────────────────────────────
struct WeightChartView: View {
    let pet: Pet
    @EnvironmentObject var vm: AppViewModel
    @State private var appeared = false

    private var records: [WeightRecord] { vm.weights(for: pet.id) }
    private var currentWeight: Double { records.last?.weight ?? pet.weight }
    private var trend: Double {
        guard records.count >= 2 else { return 0 }
        return records.last!.weight - records[records.count - 2].weight
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Hero weight card
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Berat Sekarang")
                            .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", currentWeight))
                                .font(.system(size: 40, weight: .black, design: .rounded))
                                .foregroundStyle(Color.pcIndigo)
                            Text("kg")
                                .font(PCFont.subhead()).foregroundStyle(Color.pcText2)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Tren Bulan Ini")
                            .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                        HStack(spacing: 4) {
                            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 14, weight: .bold))
                            Text(String(format: "%.1f kg", abs(trend)))
                                .font(PCFont.subhead().weight(.bold))
                        }
                        .foregroundStyle(trend >= 0 ? Color.pcGreen : Color.pcRed)
                    }
                }
                .padding(PCSpace.xl)
                .elevatedGlass(radius: PCRadius.xxl)
                .padding(.horizontal, PCSpace.lg)

                // Chart card
                if !records.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Perkembangan Berat")
                            .font(PCFont.subhead().weight(.bold))
                            .foregroundStyle(Color.pcText1)

                        Chart {
                            ForEach(records) { r in
                                AreaMark(
                                    x: .value("Bulan", r.date),
                                    y: .value("Berat", r.weight)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.pcIndigo.opacity(0.25), Color.pcIndigo.opacity(0.02)],
                                        startPoint: .top, endPoint: .bottom)
                                )
                                .interpolationMethod(.catmullRom)

                                LineMark(
                                    x: .value("Bulan", r.date),
                                    y: .value("Berat", r.weight)
                                )
                                .foregroundStyle(
                                    LinearGradient(colors: [Color.pcIndigo, Color.pcPurple],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 2.5))
                                .interpolationMethod(.catmullRom)

                                PointMark(
                                    x: .value("Bulan", r.date),
                                    y: .value("Berat", r.weight)
                                )
                                .foregroundStyle(Color.pcIndigo)
                                .symbolSize(30)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .month)) { v in
                                AxisValueLabel(format: .dateTime.month(.abbreviated),
                                               centered: true)
                                    .font(PCFont.micro())
                                    .foregroundStyle(Color.pcText3)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { v in
                                AxisValueLabel()
                                    .font(PCFont.micro())
                                    .foregroundStyle(Color.pcText3)
                                AxisGridLine().foregroundStyle(Color.pcBorder)
                            }
                        }
                        .frame(height: 180)
                        .scaleEffect(appeared ? 1 : 0.95)
                        .opacity(appeared ? 1 : 0)
                    }
                    .padding(PCSpace.lg)
                    .elevatedGlass(radius: PCRadius.xxl)
                    .padding(.horizontal, PCSpace.lg)
                }

                // History table
                if !records.isEmpty {
                    VStack(spacing: 0) {
                        Text("Riwayat Penimbangan")
                            .font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 12)

                        ForEach(Array(records.enumerated()), id: \.element.id) { idx, r in
                            let sorted = records.sorted { $0.date < $1.date }
                            let prev = idx > 0 ? sorted[idx - 1].weight : r.weight
                            let diff = r.weight - prev
                            let trendColor: Color = diff > 0 ? .pcGreen : (diff < 0 ? .pcRed : .pcText3)
                            let trendIcon = diff > 0 ? "arrow.up.right" : (diff < 0 ? "arrow.down.right" : "minus")

                            HStack {
                                Text(r.date.monthYear)
                                    .font(PCFont.subhead()).foregroundStyle(Color.pcText2)
                                Spacer()
                                Text(String(format: "%.1f kg", r.weight))
                                    .font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
                                if diff != 0 {
                                    HStack(spacing: 2) {
                                        Image(systemName: trendIcon)
                                            .font(.system(size: 10, weight: .bold))
                                        Text(String(format: "%.1f", abs(diff)))
                                            .font(PCFont.micro())
                                    }
                                    .foregroundStyle(trendColor)
                                }
                            }
                            .padding(.vertical, 10)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task { try? await FirebaseWeightService.shared.deleteWeight(id: r.id) }
                                    withAnimation(.pcSpring) {
                                        if let i = vm.weightRecords.firstIndex(where: { $0.id == r.id }) {
                                            vm.weightRecords.remove(at: i)
                                        }
                                    }
                                } label: {
                                    Label("Hapus", systemImage: "trash")
                                }
                            }
                            if idx < records.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .padding(PCSpace.lg)
                    .elevatedGlass(radius: PCRadius.xxl)
                    .padding(.horizontal, PCSpace.lg)
                }

                Spacer().frame(height: 120)
            }
            .padding(.top, PCSpace.sm)
        }
        .onAppear { withAnimation(.pcSpring.delay(0.2)) { appeared = true } }
    }
}

#Preview { HealthView().environmentObject(AppViewModel()) }
