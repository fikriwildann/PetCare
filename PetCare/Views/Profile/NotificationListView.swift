// MARK: - NotificationListView.swift
// PetCare — Notification List

import SwiftUI

struct NotificationListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    @State private var appeared = false

    var body: some View {
        ZStack {
            PCMeshBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.pcText1)
                    }
                    Spacer()
                    Text("Notifikasi")
                        .font(PCFont.headline()).foregroundStyle(Color.pcText1)
                    Spacer()
                }
                .padding(.horizontal, PCSpace.lg)
                .padding(.vertical, PCSpace.sm)

                if vm.notifications.isEmpty {
                    Spacer()
                    PCEmptyState(icon: "bell.slash", title: "Tidak Ada Notifikasi",
                                 message: "Notifikasi jadwal hewan akan muncul di sini")
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(vm.notifications) { n in
                                NotificationRow(notification: n) {
                                    withAnimation(.pcSpring) {
                                        if let i = vm.notifications.firstIndex(where: { $0.id == n.id }) {
                                            vm.notifications[i].isRead = true
                                        }
                                    }
                                }
                                .padding(.horizontal, PCSpace.lg)
                            }
                            Spacer().frame(height: 100)
                        }
                        .padding(.top, PCSpace.sm)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { withAnimation(.pcSpring) { appeared = true } }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                        .lineLimit(2)
                    Text(notification.message)
                        .font(PCFont.caption()).foregroundStyle(Color.pcText2).lineLimit(2)
                    Text(notification.date.relative)
                        .font(PCFont.micro()).foregroundStyle(Color.pcText3)
                }
                Spacer()
                if !notification.isRead {
                    Circle().fill(Color.pcIndigo).frame(width: 8, height: 8)
                        .shadow(color: Color.pcIndigo.opacity(0.5), radius: 4)
                }
            }
            .padding(14)
            .liquidGlass(radius: PCRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                    .stroke(notification.isRead ? Color.clear : Color.pcIndigo.opacity(0.20), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview { NotificationListView().environmentObject(AppViewModel()) }
