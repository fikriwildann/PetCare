// MARK: - OnboardingView.swift
// PetCare — 3-Page Swipeable Onboarding with Liquid Glass

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @Namespace private var ns

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "🐶",
            gradient: [Color(hex: "#4F46E5"), Color(hex: "#7C3AED")],
            title: "Kelola Hewan Peliharaan\ndengan Mudah",
            description: "Simpan seluruh informasi hewan peliharaan dalam satu tempat yang aman dan praktis.",
            accentColor: Color.pcIndigo),
        OnboardingPage(
            emoji: "💉",
            gradient: [Color(hex: "#059669"), Color(hex: "#3B82F6")],
            title: "Pantau Kesehatan\nSetiap Saat",
            description: "Catat vaksinasi, obat, pemeriksaan dokter, dan perkembangan kesehatan hewan.",
            accentColor: Color.pcGreen),
        OnboardingPage(
            emoji: "🔔",
            gradient: [Color(hex: "#D97706"), Color(hex: "#7C3AED")],
            title: "Jangan Lewatkan\nJadwal Penting",
            description: "Dapatkan pengingat otomatis untuk jadwal makan, vaksin, dan pemberian obat.",
            accentColor: Color.pcOrange)
    ]

    var body: some View {
        ZStack {
            // Animated background
            ZStack {
                Color.pcBG.ignoresSafeArea()
                PCMeshBackground().opacity(0.6)
            }

            VStack(spacing: 0) {
                // Skip
                HStack {
                    Spacer()
                    Button { finish() } label: {
                        Text("Lewati")
                            .font(PCFont.subhead().weight(.semibold))
                            .foregroundStyle(Color.pcText2)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .liquidGlass(radius: PCRadius.full)
                    }
                    .buttonStyle(.plain)
                    .opacity(currentPage < 2 ? 1 : 0)
                    .animation(.pcFast, value: currentPage)
                }
                .padding(.horizontal, PCSpace.lg)
                .padding(.top, PCSpace.lg)

                // Slides
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { i in
                        OnboardingSlide(page: pages[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.pcSpring, value: currentPage)

                // Bottom controls
                VStack(spacing: 28) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage
                                      ? AnyShapeStyle(Color.primaryGradient)
                                      : AnyShapeStyle(Color.pcText3.opacity(0.3)))
                                .frame(width: i == currentPage ? 28 : 8, height: 8)
                                .animation(.pcSpring, value: currentPage)
                        }
                    }

                    // Action buttons
                    HStack(spacing: 12) {
                        if currentPage > 0 {
                            PCSecondaryButton(title: "Kembali") {
                                withAnimation(.pcSpring) { currentPage -= 1 }
                            }
                            .frame(width: 110)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }

                        PCPrimaryButton(currentPage < 2 ? "Selanjutnya" : "Mulai Sekarang 🎉",
                                        icon: currentPage < 2 ? "arrow.right" : nil) {
                            if currentPage < 2 {
                                withAnimation(.pcSpring) { currentPage += 1 }
                            } else {
                                finish()
                            }
                        }
                    }
                    .animation(.pcSpring, value: currentPage)
                }
                .padding(.horizontal, PCSpace.lg)
                .padding(.bottom, PCSpace.xxxl)
            }
        }
    }

    private func finish() {
        withAnimation(.easeInOut(duration: 0.4)) { showOnboarding = false }
    }
}

// MARK: - Page Data
struct OnboardingPage {
    let emoji: String
    let gradient: [Color]
    let title: String
    let description: String
    let accentColor: Color
}

// MARK: - Slide
struct OnboardingSlide: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero visual
            ZStack {
                // Glowing blob
                Circle()
                    .fill(
                        LinearGradient(colors: page.gradient.map { $0.opacity(0.20) },
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 220, height: 220)
                    .blur(radius: 30)

                // Outer glass ring
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 190, height: 190)
                    .overlay(
                        Circle().stroke(
                            LinearGradient(colors: [.white.opacity(0.4), .white.opacity(0.05)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5))
                    .shadow(color: page.accentColor.opacity(0.25), radius: 24, x: 0, y: 10)

                // Inner card
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(
                        LinearGradient(colors: page.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 130, height: 130)
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .stroke(.white.opacity(0.3), lineWidth: 1.5))
                    .shadow(color: page.accentColor.opacity(0.40), radius: 20, x: 0, y: 8)

                Text(page.emoji)
                    .font(.system(size: 58))
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .animation(.pcBounce.delay(0.15), value: appeared)
            }
            .scaleEffect(appeared ? 1.0 : 0.85)
            .animation(.pcSpring, value: appeared)

            Spacer().frame(height: 44)

            // Text
            VStack(spacing: 14) {
                Text(page.title)
                    .font(PCFont.title1(.black))
                    .foregroundStyle(Color.pcText1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Text(page.description)
                    .font(PCFont.subhead())
                    .foregroundStyle(Color.pcText2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 28)
            }
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)
            .animation(.pcSpring.delay(0.1), value: appeared)

            Spacer()
        }
        .onAppear {
            appeared = false
            withAnimation { appeared = true }
        }
        .onDisappear { appeared = false }
    }
}

#Preview { OnboardingView(showOnboarding: .constant(true)) }
