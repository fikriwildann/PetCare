// MARK: - ProfileView.swift
// PetCare — Profile + Notifications

import SwiftUI

// ─────────────────────────────────────────
// MARK: ProfileView
// ─────────────────────────────────────────
struct ProfileView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var darkMode = false
    @State private var notifEnabled = true
    @State private var appeared = false

    var body: some View {
        ZStack {
            PCMeshBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Profil")
                        .font(PCFont.title1(.black)).foregroundStyle(Color.pcText1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, PCSpace.lg).padding(.vertical, PCSpace.sm)

                    // Profile Hero Card
                    profileHeroCard

                    // Stats
                    statsRow

                    // Account Settings
                    menuSection(title: "Akun") {
                        PCMenuRow(icon: "pencil", iconBg: Color.pcIndigo,
                                  title: "Edit Profil") {}
                        PCMenuRow(icon: "bell.fill", iconBg: Color.pcOrange,
                                  title: "Pengaturan Notifikasi",
                                  badge: "\(vm.unreadCount)") {}
                        toggleRow
                    }

                    // Help & Info
                    menuSection(title: "Bantuan & Info") {
                        PCMenuRow(icon: "questionmark.circle.fill", iconBg: Color.pcGreen,
                                  title: "Bantuan & FAQ") {}
                        PCMenuRow(icon: "info.circle.fill", iconBg: Color.pcPurple,
                                  title: "Tentang PetCare",
                                  subtitle: "Versi 1.0.0") {}
                        PCMenuRow(icon: "star.fill", iconBg: Color.pcOrange,
                                  title: "Beri Rating") {}
                    }

                    // Logout
                    PCDestructiveButton(title: "Keluar dari Akun") {
                        withAnimation(.pcSpring) { vm.logout() }
                    }
                    .padding(.horizontal, PCSpace.lg)

                    // Footer
                    VStack(spacing: 4) {
                        Text("🐾 PetCare").font(PCFont.subhead().weight(.bold)).foregroundStyle(Color.pcText3)
                        Text("Versi 1.0.0 • Dibuat dengan susah")
                            .font(PCFont.caption()).foregroundStyle(Color.pcText3)
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear { withAnimation(.pcSpring) { appeared = true } }
    }

    // MARK: Profile Hero
    private var profileHeroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 84, height: 84)
                    .shadow(color: Color.pcIndigo.opacity(0.35), radius: 16, x: 0, y: 6)
                Text("🧑").font(.system(size: 40))
            }
            VStack(spacing: 6) {
                Text(vm.currentUser.name)
                    .font(PCFont.title3(.black)).foregroundStyle(Color.pcText1)
                Text(vm.currentUser.email)
                    .font(PCFont.subhead()).foregroundStyle(Color.pcText2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PCSpace.xl)
        .elevatedGlass(radius: PCRadius.xxl)
        .padding(.horizontal, PCSpace.lg)
    }

    // MARK: Stats
    private var statsRow: some View {
        HStack(spacing: 0) {
            ForEach([
                ("\(vm.pets.count)", "Hewan", Color.pcIndigo),
                ("\(vm.vaccines.count)", "Vaksin", Color.pcPurple),
                ("\(vm.feedings.count)", "Jadwal", Color.pcGreen)
            ], id: \.0) { item in
                VStack(spacing: 5) {
                    Text(item.0)
                        .font(PCFont.title2(.black)).foregroundStyle(item.2)
                    Text(item.1)
                        .font(PCFont.caption()).foregroundStyle(Color.pcText2)
                }
                .frame(maxWidth: .infinity)
                if item.1 != "Jadwal" { Divider().frame(height: 32) }
            }
        }
        .padding(PCSpace.md)
        .liquidGlass(radius: PCRadius.xl)
        .padding(.horizontal, PCSpace.lg)
    }

    // MARK: Toggle row
    private var toggleRow: some View {
        PCToggleRow(icon: "moon.fill", iconBg: Color.pcIndigo.opacity(0.8),
                    title: "Tampilan Gelap", isOn: $darkMode)
    }

    // MARK: Menu Section
    @ViewBuilder
    private func menuSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
                .padding(.horizontal, PCSpace.lg)

            VStack(spacing: 0) {
                content()
                    .padding(.horizontal, 4)
            }
            .padding(PCSpace.md)
            .elevatedGlass(radius: PCRadius.xl)
            .padding(.horizontal, PCSpace.lg)
        }
    }
}

// ─────────────────────────────────────────
// MARK: NotificationsView
// ─────────────────────────────────────────
struct NotificationsView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var segment = 0

    private let types: [NotificationType?] = [nil, .vaccine, .feeding, .medication]
    private let labels = ["Semua", "💉 Vaksin", "🍖 Makan", "💊 Obat"]

    private var filtered: [AppNotification] {
        guard let t = types[segment] else { return vm.notifications }
        return vm.notifications.filter { $0.type == t }
    }

    private var todayItems: [AppNotification] { filtered.filter { $0.date.isToday } }
    private var olderItems: [AppNotification] { filtered.filter { !$0.date.isToday } }

    var body: some View {
        ZStack {
            PCMeshBackground()
            VStack(spacing: 0) {
                PCNavigationBar(
                    title: "Notifikasi",
                    leadingAction: { dismiss() },
                    trailingView: AnyView(
                        Button {
                            vm.markAllRead()
                        } label: {
                            Text("Tandai Dibaca")
                                .font(PCFont.caption().weight(.semibold))
                                .foregroundStyle(Color.pcIndigo)
                        }
                        .buttonStyle(.plain)
                        .opacity(vm.unreadCount > 0 ? 1 : 0)
                    )
                )

                PCSegmentControl(options: labels, selected: $segment)
                    .padding(.bottom, PCSpace.sm)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if !todayItems.isEmpty {
                            notifSection("Hari Ini", items: todayItems)
                        }
                        if !olderItems.isEmpty {
                            notifSection("Sebelumnya", items: olderItems)
                        }
                        if filtered.isEmpty {
                            PCEmptyState(icon: "bell.slash", title: "Tidak Ada Notifikasi",
                                         message: "Semua notifikasi akan muncul di sini")
                        }
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, PCSpace.sm)
                }
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func notifSection(_ title: String, items: [AppNotification]) -> some View {
        Text(title.uppercased())
            .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
            .padding(.horizontal, PCSpace.lg)

        ForEach(items) { n in
            NotifRow(notification: n)
                .padding(.horizontal, PCSpace.lg)
        }
    }
}

struct NotifRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(notification.type.color.opacity(0.12))
                    .frame(width: 46, height: 46)
                Text(notification.type.emoji).font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(PCFont.subhead().weight(.semibold))
                    .foregroundStyle(Color.pcText1)
                Text(notification.message)
                    .font(PCFont.caption()).foregroundStyle(Color.pcText2).lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(notification.date.timeOnly)
                    .font(PCFont.micro()).foregroundStyle(Color.pcText3)
                if !notification.isRead {
                    Circle().fill(Color.pcIndigo).frame(width: 8, height: 8)
                        .shadow(color: Color.pcIndigo.opacity(0.5), radius: 4)
                }
            }
        }
        .padding(14)
        .liquidGlass(radius: PCRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                .stroke(notification.isRead ? Color.clear : Color.pcIndigo.opacity(0.20), lineWidth: 1)
        )
    }
}

#Preview("Profile") { ProfileView().environmentObject(AppViewModel()) }
#Preview("Notifications") { NotificationsView().environmentObject(AppViewModel()) }
