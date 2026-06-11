// MARK: - AboutPetCareView.swift
// PetCare — About screen

import SwiftUI

struct AboutPetCareView: View {
    @Environment(\.dismiss) var dismiss
    @State private var appeared = false

    var body: some View {
        ZStack {
            PCMeshBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // App Logo & Title
                    appHeader

                    // App Description
                    descriptionCard

                    // Features
                    featuresSection

                    // Developer Info
                    developerCard

                    Spacer().frame(height: 100)
                }
                .padding(.top, PCSpace.lg)
            }
        }
        .navigationBarHidden(true)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear { withAnimation(.pcSpring.delay(0.05)) { appeared = true } }
    }

    // MARK: App Header
    private var appHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.pcIndigo.opacity(0.4), radius: 20, x: 0, y: 8)

                Text("🐾")
                    .font(.system(size: 48))
            }

            VStack(spacing: 6) {
                Text("PetCare")
                    .font(PCFont.display(.black))
                    .foregroundStyle(Color.pcText1)

                Text("Versi 1.0.0")
                    .font(PCFont.subhead())
                    .foregroundStyle(Color.pcText2)
            }
        }
        .padding(.vertical, PCSpace.xl)
    }

    // MARK: Description Card
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tentang Aplikasi")
                .font(PCFont.title3(.black))
                .foregroundStyle(Color.pcText1)

            Text("PetCare adalah aplikasi manajemen kesehatan hewan peliharaan yang membantu Anda menjaga kesejahteraan hewan kesayangan Anda. Dengan fitur lengkap untuk mencatat vaksin, jadwal makan, dan pengobatan, PetCare menjadi asisten terpercaya dalam merawat hewan peliharaan Anda.")
                .font(PCFont.subhead())
                .foregroundStyle(Color.pcText2)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PCSpace.xl)
        .elevatedGlass(radius: PCRadius.xxl)
        .padding(.horizontal, PCSpace.lg)
    }

    // MARK: Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fitur Utama")
                .font(PCFont.title3(.black))
                .foregroundStyle(Color.pcText1)

            VStack(spacing: 12) {
                featureRow(icon: "💉", color: Color.pcPurple, title: "Manajemen Vaksin", desc: "Catat dan ingat jadwal vaksinasi hewan peliharaan")
                featureRow(icon: "🍖", color: Color.pcOrange, title: "Jadwal Makan", desc: "Atur waktu dan porsi makan yang tepat")
                featureRow(icon: "💊", color: Color.pcGreen, title: "Pengingat Obat", desc: "Notifikasi untuk jadwal pengobatan")
                featureRow(icon: "📊", color: Color.pcIndigo, title: "Statistik Kesehatan", desc: "Pantau kesehatan hewan secara keseluruhan")
            }
        }
        .padding(.horizontal, PCSpace.lg)
    }

    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)

                Text(icon)
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(PCFont.subhead().weight(.semibold))
                    .foregroundStyle(Color.pcText1)

                Text(desc)
                    .font(PCFont.caption())
                    .foregroundStyle(Color.pcText2)
            }

            Spacer()
        }
        .padding(PCSpace.md)
        .liquidGlass(radius: PCRadius.lg)
    }

    // MARK: Developer Card
    private var developerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text("👨‍💻")
                            .font(.system(size: 28))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tim Pengembang")
                        .font(PCFont.subhead().weight(.semibold))
                        .foregroundStyle(Color.pcText1)

                    Text("iCodeWave Community")
                        .font(PCFont.caption())
                        .foregroundStyle(Color.pcText2)
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                contactRow(icon: "envelope.fill", text: "icodewave@petcare.app")
                contactRow(icon: "globe", text: "www.petcare.app")
                contactRow(icon: "location.fill", text: "Indonesia")
            }
        }
        .padding(PCSpace.xl)
        .elevatedGlass(radius: PCRadius.xxl)
        .padding(.horizontal, PCSpace.lg)
    }

    private func contactRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.pcIndigo)
                .frame(width: 20)

            Text(text)
                .font(PCFont.caption())
                .foregroundStyle(Color.pcText2)
        }
    }
}

#Preview("About PetCare") { AboutPetCareView() }
