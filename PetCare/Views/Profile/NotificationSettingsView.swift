// MARK: - NotificationSettingsView.swift
// PetCare — Notification Settings

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    @State private var vaccineNotif = true
    @State private var feedingNotif = true
    @State private var medicationNotif = true
    @State private var permissionGranted = false
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Permission card
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(Color.pcOrange.opacity(0.12)).frame(width: 44, height: 44)
                                    Image(systemName: permissionGranted ? "bell.badge.fill" : "bell.slash.fill")
                                        .font(.system(size: 20)).foregroundStyle(Color.pcOrange)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Izin Notifikasi")
                                        .font(PCFont.subhead().weight(.semibold)).foregroundStyle(Color.pcText1)
                                    Text(permissionGranted ? "Notifikasi diizinkan" : "Notifikasi diblokir")
                                        .font(PCFont.caption()).foregroundStyle(permissionGranted ? Color.pcGreen : Color.pcRed)
                                }
                                Spacer()
                                if !permissionGranted {
                                    Button("Izinkan") {
                                        Task {
                                            permissionGranted = await NotificationService.shared.requestPermission()
                                            if !permissionGranted {
                                                showPermissionAlert = true
                                            }
                                        }
                                    }
                                    .font(PCFont.caption().weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(Color.pcOrange)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(PCSpace.md)
                            .elevatedGlass(radius: PCRadius.xl)
                        }
                        .padding(.horizontal, PCSpace.lg)

                        // Notification types
                        VStack(spacing: 12) {
                            PCSectionLabel(text: "Jenis Notifikasi")
                                .padding(.horizontal, PCSpace.lg)
                            VStack(spacing: 0) {
                                notifToggleRow(emoji: "💉", title: "Vaksin", color: .pcOrange, isOn: $vaccineNotif)
                                Divider().padding(.leading, 58)
                                notifToggleRow(emoji: "🍖", title: "Jadwal Makan", color: .pcGreen, isOn: $feedingNotif)
                                Divider().padding(.leading, 58)
                                notifToggleRow(emoji: "💊", title: "Obat", color: .pcPurple, isOn: $medicationNotif)
                            }
                            .padding(PCSpace.md)
                            .elevatedGlass(radius: PCRadius.xl)
                            .padding(.horizontal, PCSpace.lg)
                        }

                        // Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ketuk untuk mengaktifkan atau menonaktifkan jenis notifikasi.")
                                .font(PCFont.caption()).foregroundStyle(Color.pcText3)
                            Text("Notifikasi akan muncul sesuai jadwal yang telah ditambahkan.")
                                .font(PCFont.caption()).foregroundStyle(Color.pcText3)
                        }
                        .padding(.horizontal, PCSpace.lg)

                        Spacer().frame(height: 40)
                    }
                    .padding(.top, PCSpace.sm)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }.foregroundStyle(Color.pcIndigo)
                }
                ToolbarItem(placement: .principal) {
                    Text("Pengaturan Notifikasi").font(PCFont.headline()).foregroundStyle(Color.pcText1)
                }
            }
        }
        .onAppear {
            checkPermission()
        }
        .alert("Izin Ditolak", isPresented: $showPermissionAlert) {
            Button("Buka Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Notifikasi diblokir. Buka Settings untuk mengizinkan notifikasi dari PetCare.")
        }
    }

    private func notifToggleRow(emoji: String, title: String, color: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Text(emoji).font(.system(size: 18))
            }
            Text(title).font(PCFont.subhead()).foregroundStyle(Color.pcText1)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Color.pcIndigo)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }

    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                permissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
}

#Preview { NotificationSettingsView().environmentObject(AppViewModel()) }
