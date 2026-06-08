// MARK: - AuthViews.swift
// PetCare — Login + Register with Liquid Glass cards

import SwiftUI

// ─────────────────────────────────────────
// MARK: LoginView
// ─────────────────────────────────────────
struct LoginView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var email    = "fikri@dinuswantara.ac.id"
    @State private var password = "password123"
    @State private var appeared = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                PCMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 60)

                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selamat\nDatang 👋")
                                .font(PCFont.display(.black))
                                .foregroundStyle(Color.pcText1)
                            Text("Masuk untuk melanjutkan ke PetCare")
                                .font(PCFont.subhead())
                                .foregroundStyle(Color.pcText2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, PCSpace.lg)
                        .offset(y: appeared ? 0 : 20)
                        .opacity(appeared ? 1 : 0)

                        Spacer().frame(height: 32)

                        // Glass form card
                        VStack(spacing: 18) {
                            PCTextField(label: "Email", placeholder: "contoh@email.com",
                                        text: $email, keyboardType: .emailAddress)
                            PCTextField(label: "Password", placeholder: "Masukkan password",
                                        text: $password, isSecure: true)

                            HStack {
                                Spacer()
                                Button {
                                } label: {
                                    Text("Lupa Password?")
                                        .font(PCFont.footnote().weight(.semibold))
                                        .foregroundStyle(Color.pcIndigo)
                                }
                                .buttonStyle(.plain)
                            }

                            PCPrimaryButton("Masuk", icon: "arrow.right") {
                                login()
                            }

                            divider

                            // Apple Sign In
                            appleSignInButton
                        }
                        .padding(PCSpace.xl)
                        .elevatedGlass(radius: PCRadius.xxl)
                        .padding(.horizontal, PCSpace.lg)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)

                        Spacer().frame(height: 24)

                        // Register link
                        HStack(spacing: 4) {
                            Text("Belum punya akun?")
                                .font(PCFont.subhead())
                                .foregroundStyle(Color.pcText2)
                            NavigationLink("Daftar") {
                                RegisterView()
                            }
                            .font(PCFont.subhead().weight(.bold))
                            .foregroundStyle(Color.pcIndigo)
                        }
                        .opacity(appeared ? 1 : 0)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.pcSpring.delay(0.1)) { appeared = true }
        }
    }

    private var divider: some View {
        HStack {
            Rectangle().fill(Color.pcBorder).frame(height: 0.5)
            Text("atau").font(PCFont.caption()).foregroundStyle(Color.pcText3).padding(.horizontal, 12)
            Rectangle().fill(Color.pcBorder).frame(height: 0.5)
        }
    }

    private var appleSignInButton: some View {
        Button {
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "applelogo")
                    .font(.system(size: 18, weight: .semibold))
                Text("Masuk dengan Apple")
                    .font(PCFont.headline())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(Color.pcText1)
            .liquidGlass(radius: PCRadius.lg)
        }
        .buttonStyle(.plain)
    }

    private func login() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoading = false
            vm.login(email: email, password: password)
        }
    }
}

// ─────────────────────────────────────────
// MARK: RegisterView
// ─────────────────────────────────────────
struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""
    @State private var appeared = false

    private var passwordStrength: (label: String, color: Color, progress: Double) {
        let len = password.count
        if len == 0 { return ("", .clear, 0) }
        if len < 6  { return ("Terlalu pendek", .pcRed, 0.25) }
        if len < 10 { return ("Cukup", .pcOrange, 0.55) }
        return ("Kuat ✓", .pcGreen, 1.0)
    }

    var body: some View {
        ZStack {
            PCMeshBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 20)

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Buat Akun\nBaru 🐾")
                            .font(PCFont.display(.black))
                            .foregroundStyle(Color.pcText1)
                        Text("Bergabung dengan PetCare sekarang")
                            .font(PCFont.subhead())
                            .foregroundStyle(Color.pcText2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PCSpace.lg)
                    .offset(y: appeared ? 0 : 20).opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 28)

                    // Form
                    VStack(spacing: 18) {
                        PCTextField(label: "Nama Lengkap", placeholder: "Nama lengkap Anda", text: $name)
                        PCTextField(label: "Email", placeholder: "contoh@email.com",
                                    text: $email, keyboardType: .emailAddress)

                        VStack(alignment: .leading, spacing: 8) {
                            PCTextField(label: "Password", placeholder: "Min. 8 karakter",
                                        text: $password, isSecure: true)
                            if !password.isEmpty {
                                VStack(spacing: 4) {
                                    PCProgressBar(progress: passwordStrength.progress,
                                                  color: passwordStrength.color)
                                    Text(passwordStrength.label)
                                        .font(PCFont.micro())
                                        .foregroundStyle(passwordStrength.color)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .transition(.opacity)
                                .animation(.pcFast, value: password)
                            }
                        }

                        PCTextField(label: "Konfirmasi Password", placeholder: "Ulangi password",
                                    text: $confirm, isSecure: true)

                        if !confirm.isEmpty && confirm != password {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text("Password tidak cocok")
                                    .font(PCFont.caption())
                            }
                            .foregroundStyle(Color.pcRed)
                            .transition(.opacity.combined(with: .scale))
                        }

                        PCPrimaryButton("Daftar Sekarang", icon: "checkmark") {
                            vm.login(email: email, password: password)
                        }
                        .disabled(!canSubmit)
                        .opacity(canSubmit ? 1.0 : 0.55)
                    }
                    .padding(PCSpace.xl)
                    .elevatedGlass(radius: PCRadius.xxl)
                    .padding(.horizontal, PCSpace.lg)
                    .offset(y: appeared ? 0 : 30).opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 24)

                    HStack(spacing: 4) {
                        Text("Sudah punya akun?")
                            .font(PCFont.subhead()).foregroundStyle(Color.pcText2)
                        Button { dismiss() } label: {
                            Text("Masuk")
                                .font(PCFont.subhead().weight(.bold))
                                .foregroundStyle(Color.pcIndigo)
                        }
                        .buttonStyle(.plain)
                    }
                    .opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { withAnimation(.pcSpring.delay(0.1)) { appeared = true } }
    }

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 8 && password == confirm
    }
}

#Preview("Login") { LoginView().environmentObject(AppViewModel()) }
#Preview("Register") {
    NavigationStack { RegisterView() }.environmentObject(AppViewModel())
}
