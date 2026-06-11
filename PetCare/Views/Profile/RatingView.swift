// MARK: - RatingView.swift
// PetCare — Rating screen

import SwiftUI

struct RatingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedRating: Int = 0
    @State private var review: String = ""
    @State private var appeared = false
    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            PCMeshBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Star Rating
                    ratingStarsSection

                    // Review TextField
                    reviewSection

                    // Submit Button
                    submitButton

                    Spacer().frame(height: 100)
                }
                .padding(.top, PCSpace.lg)
            }

            // Success Overlay
            if showSuccess {
                successOverlay
            }

            // Close button
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.pcText2)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(PCSpace.lg)
        }
        .navigationBarHidden(true)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear { withAnimation(.pcSpring.delay(0.05)) { appeared = true } }
    }

    // MARK: Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.pcIndigo.opacity(0.4), radius: 16, x: 0, y: 6)

                Text("⭐")
                    .font(.system(size: 36))
            }

            VStack(spacing: 6) {
                Text("Beri Rating")
                    .font(PCFont.display(.black))
                    .foregroundStyle(Color.pcText1)

                Text("Bagaimana pengalaman Anda dengan PetCare?")
                    .font(PCFont.subhead())
                    .foregroundStyle(Color.pcText2)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, PCSpace.xl)
    }

    // MARK: Rating Stars
    private var ratingStarsSection: some View {
        VStack(spacing: 16) {
            Text("Tap untuk memberi rating")
                .font(PCFont.caption())
                .foregroundStyle(Color.pcText3)

            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(.pcSpring) {
                            selectedRating = star
                        }
                    } label: {
                        Image(systemName: star <= selectedRating ? "star.fill" : "star")
                            .font(.system(size: 44))
                            .foregroundStyle(star <= selectedRating ? Color.pcOrange : Color.pcText3)
                            .shadow(
                                color: star <= selectedRating ? Color.pcOrange.opacity(0.4) : .clear,
                                radius: 8, x: 0, y: 4
                            )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(star <= selectedRating ? 1.1 : 1.0)
                }
            }
            .padding(.vertical, PCSpace.md)

            Text(ratingText)
                .font(PCFont.subhead().weight(.semibold))
                .foregroundStyle(Color.pcOrange)
                .animation(.pcSpring, value: selectedRating)
        }
        .padding(PCSpace.xl)
        .elevatedGlass(radius: PCRadius.xxl)
        .padding(.horizontal, PCSpace.lg)
    }

    private var ratingText: String {
        switch selectedRating {
        case 1: return "Sangat Buruk 😞"
        case 2: return "Buruk 😕"
        case 3: return "Biasa saja 😐"
        case 4: return "Baik 😊"
        case 5: return "Sangat Baik 😍"
        default: return "Pilih rating Anda"
        }
    }

    // MARK: Review Section
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ulasan (Opsional)")
                .font(PCFont.subhead().weight(.semibold))
                .foregroundStyle(Color.pcText1)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                    .fill(Color.pcText1.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                            .stroke(Color.pcText3.opacity(0.2), lineWidth: 1)
                    )

                if review.isEmpty {
                    Text("Tulis pengalaman Anda di sini...")
                        .font(PCFont.subhead())
                        .foregroundStyle(Color.pcText3)
                        .padding(.horizontal, PCSpace.md)
                        .padding(.vertical, PCSpace.md + 4)
                        .padding(.top, PCSpace.sm)
                }

                TextEditor(text: $review)
                    .font(PCFont.subhead())
                    .foregroundStyle(Color.pcText1)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, PCSpace.md)
                    .padding(.vertical, PCSpace.sm)
                    .frame(minHeight: 120)
            }
        }
        .padding(.horizontal, PCSpace.lg)
    }

    // MARK: Submit Button
    private var submitButton: some View {
        PCPrimaryButton(
            isSubmitting ? "Mengirim..." : "Kirim Rating",
            icon: "paperplane.fill"
        ) {
            submitRating()
        }
        .disabled(selectedRating == 0 || isSubmitting)
        .opacity((selectedRating > 0 && !isSubmitting) ? 1.0 : 0.55)
        .padding(.horizontal, PCSpace.lg)
    }

    // MARK: Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.pcGreen.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.pcGreen)
                }

                VStack(spacing: 8) {
                    Text("Terima Kasih! 🎉")
                        .font(PCFont.title2(.black))
                        .foregroundStyle(Color.pcText1)

                    Text("Rating Anda telah dikirim")
                        .font(PCFont.subhead())
                        .foregroundStyle(Color.pcText2)
                }
            }
            .padding(PCSpace.xl)
            .background(
                RoundedRectangle(cornerRadius: PCRadius.xxl, style: .continuous)
                    .fill(Color.pcBG)
                    .shadow(color: .black.opacity(0.2), radius: 20)
            )
            .padding(.horizontal, PCSpace.xl)
        }
        .transition(.opacity)
    }

    // MARK: Submit Rating
    private func submitRating() {
        isSubmitting = true

        let rating = FirebaseRatingService.Rating(
            userId: vm.currentUser.id.uuidString,
            userName: vm.currentUser.name,
            rating: selectedRating,
            review: review.isEmpty ? nil : review
        )

        Task {
            do {
                try await FirebaseRatingService.shared.submitRating(rating)
                await MainActor.run {
                    withAnimation(.pcSpring) {
                        showSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.pcSpring) {
                            showSuccess = false
                        }
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                }
            }
        }
    }
}

#Preview("Rating") { RatingView().environmentObject(AppViewModel()) }
