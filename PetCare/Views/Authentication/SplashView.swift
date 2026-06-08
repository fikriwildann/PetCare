// MARK: - SplashView.swift
// PetCare — Premium Animated Splash Screen

import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0
    @State private var bgRotation: Double = 0

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedSplashBG(rotation: bgRotation)

            // Decorative circles
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 300)
                .offset(x: -80, y: -180)
            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 220)
                .offset(x: 120, y: 220)

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white.opacity(0.18))
                        .frame(width: 108, height: 108)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.35), lineWidth: 1.5))
                        .shadow(color: .black.opacity(0.20), radius: 24, x: 0, y: 12)

                    Text("🐾")
                        .font(.system(size: 52))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Spacer().frame(height: 28)

                // App name
                VStack(spacing: 8) {
                    Text("PetCare")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)

                    Text("Sahabat Terbaik untuk Kesehatan\nHewan Peliharaan Anda")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)

                Spacer()

                // Loading dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        SplashDot(index: i)
                    }
                }
                .opacity(textOpacity)
                .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea()
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.15)) {
            logoScale = 1.0; logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.45)) {
            textOffset = 0; textOpacity = 1
        }
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            bgRotation = 360
        }
        // Dismiss after 2.2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
        }
    }
}

private struct AnimatedSplashBG: View {
    let rotation: Double
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#312E81"), Color(hex: "#4F46E5"), Color(hex: "#6D28D9"), Color(hex: "#8B5CF6")],
                startPoint: .topLeading, endPoint: .bottomTrailing)
            // Rotating overlay
            LinearGradient(
                colors: [Color(hex: "#7C3AED").opacity(0.5), .clear, Color(hex: "#2563EB").opacity(0.3)],
                startPoint: .top, endPoint: .bottom)
                .rotationEffect(.degrees(rotation))
        }
        .ignoresSafeArea()
    }
}

private struct SplashDot: View {
    let index: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .fill(.white.opacity(opacity))
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.2)
                ) {
                    scale = 1.0; opacity = 1.0
                }
            }
    }
}

#Preview { SplashView(showSplash: .constant(true)) }
