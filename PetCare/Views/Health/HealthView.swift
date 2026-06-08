// MARK: - HealthView.swift
// PetCare — Health Hub: Vaccine, Medication, History, Weight Chart

import SwiftUI
import Charts

// ─────────────────────────────────────────
// MARK: HealthView (tab root)
// ─────────────────────────────────────────
struct HealthView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var segment = 0
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

                PCSegmentControl(options: ["Vaksin","Obat","Riwayat","Berat"], selected: $segment)
                    .padding(.bottom, PCSpace.sm)

                Group {
                    switch segment {
                    case 0: VaccineListView()
                    case 1: MedicationListView()
                    case 2: HealthHistoryView(pet: vm.selectedPet ?? SampleData.buddy)
                    case 3: WeightChartView(pet: vm.selectedPet ?? SampleData.buddy)
                    default: EmptyView()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                .animation(.pcSpring, value: segment)
            }
        }
        .onAppear { withAnimation(.pcSpring) { appeared = true } }
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
                        sectionLabel("Aktif")
                        ForEach(vm.activeMedications) { m in
                            MedicationCard(med: m, petName: vm.petName(for: m.petId))
                                .padding(.horizontal, PCSpace.lg)
                        }
                    }
                    let inactive = vm.medications.filter { !$0.isActive }
                    if !inactive.isEmpty {
                        sectionLabel("Selesai").opacity(0.7)
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

    private func sectionLabel(_ t: String) -> some View {
        Text(t.uppercased())
            .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, PCSpace.lg)
            .padding(.top, PCSpace.xs)
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
    let pet: Pet
    @EnvironmentObject var vm: AppViewModel
    @State private var expanded: UUID? = nil

    private var records: [HealthRecord] { vm.healthRecords(for: pet.id) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(records.indices, id: \.self) { i in
                        TimelineItem(record: records[i],
                                     isLast: i == records.count - 1,
                                     expanded: $expanded)
                        .padding(.horizontal, PCSpace.lg)
                    }
                    if records.isEmpty {
                        PCEmptyState(icon: "clipboard", title: "Belum Ada Riwayat",
                                     message: "Catat pemeriksaan pertama \(pet.name)")
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
                VStack(spacing: 0) {
                    Text("Riwayat Penimbangan")
                        .font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 12)

                    ForEach(records.reversed()) { r in
                        HStack {
                            Text(r.date.monthYear)
                                .font(PCFont.subhead()).foregroundStyle(Color.pcText2)
                            Spacer()
                            Text(String(format: "%.1f kg", r.weight))
                                .font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText1)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.pcGreen)
                        }
                        .padding(.vertical, 10)
                        if r.id != records.first?.id {
                            Divider()
                        }
                    }
                }
                .padding(PCSpace.lg)
                .elevatedGlass(radius: PCRadius.xxl)
                .padding(.horizontal, PCSpace.lg)

                Spacer().frame(height: 120)
            }
            .padding(.top, PCSpace.sm)
        }
        .onAppear { withAnimation(.pcSpring.delay(0.2)) { appeared = true } }
    }
}

#Preview { HealthView().environmentObject(AppViewModel()) }
