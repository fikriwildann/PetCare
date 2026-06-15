// MARK: - ChangePasswordSheetView
// PetCare — Change Password Sheet

import SwiftUI

struct ChangePasswordSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var appeared = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var successAlert = false

    // Validation
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }

    private var passwordStrength: PasswordStrength {
        PasswordStrength.evaluate(newPassword)
    }

    var body: some View {
        ZStack {
            PCMeshBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ubah Password")
                            .font(PCFont.display(.black))
                            .foregroundStyle(Color.pcText1)
                        Text("Pastikan password baru Anda berbeda dan mudah diingat")
                            .font(PCFont.subhead())
                            .foregroundStyle(Color.pcText2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PCSpace.lg)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 32)

                    // Form card
                    VStack(spacing: 20) {
                        // Current Password
                        VStack(alignment: .leading, spacing: 8) {
                            PCTextField(
                                label: "Password Saat Ini",
                                placeholder: "Masukkan password saat ini",
                                text: $currentPassword,
                                isSecure: true
                            )
                        }

                        Divider().background(Color.pcText3.opacity(0.3))

                        // New Password
                        VStack(alignment: .leading, spacing: 8) {
                            PCTextField(
                                label: "Password Baru",
                                placeholder: "Minimal 6 karakter",
                                text: $newPassword,
                                isSecure: true
                            )

                            if !newPassword.isEmpty {
                                PasswordStrengthBar(strength: passwordStrength)
                                Text(passwordStrength.hint)
                                    .font(PCFont.micro())
                                    .foregroundStyle(passwordStrength.color)
                            }
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            PCTextField(
                                label: "Konfirmasi Password Baru",
                                placeholder: "Masukkan ulang password baru",
                                text: $confirmPassword,
                                isSecure: true
                            )

                            if !confirmPassword.isEmpty && newPassword != confirmPassword {
                                Text("Password tidak cocok")
                                    .font(PCFont.micro())
                                    .foregroundStyle(Color.pcRed)
                            }
                        }

                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .font(PCFont.caption())
                                .foregroundStyle(Color.pcRed)
                                .multilineTextAlignment(.center)
                        }

                        // Save button
                        PCPrimaryButton(
                            isSaving ? "Menyimpan..." : "Ubah Password",
                            icon: "lock.fill"
                        ) {
                            changePassword()
                        }
                        .disabled(!isFormValid || isSaving)
                        .opacity(isFormValid && !isSaving ? 1.0 : 0.55)
                    }
                    .padding(PCSpace.xl)
                    .elevatedGlass(radius: PCRadius.xxl)
                    .padding(.horizontal, PCSpace.lg)
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)

                    Spacer().frame(height: 40)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.pcText2)
                    }
                    .padding(PCSpace.lg)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.pcSpring.delay(0.1)) { appeared = true }
        }
        .alert("Password Berhasil Diubah", isPresented: $successAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Password akun Anda telah berhasil diperbarui.")
        }
    }

    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Password baru dan konfirmasi tidak cocok"
            return
        }
        guard newPassword.count >= 6 else {
            errorMessage = "Password baru minimal 6 karakter"
            return
        }

        isSaving = true
        errorMessage = nil

        vm.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, error in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    successAlert = true
                } else {
                    errorMessage = error ?? "Gagal mengubah password. Coba lagi nanti."
                }
            }
        }
    }
}

// MARK: - Password Strength
enum PasswordStrength: CaseIterable {
    case weak, fair, strong

    var color: Color {
        switch self {
        case .weak: return Color.pcRed
        case .fair: return Color.pcOrange
        case .strong: return Color.pcGreen
        }
    }

    var hint: String {
        switch self {
        case .weak: return "Lemah — gunakan kombinasi huruf, angka & simbol"
        case .fair: return "Cukup — pertimbangkan menambahkan simbol"
        case .strong: return "Kuat — password yang baik!"
        }
    }

    static func evaluate(_ password: String) -> PasswordStrength {
        let hasLetter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSymbol = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil

        let score = [hasLetter, hasNumber, hasSymbol].filter { $0 }.count

        if password.count < 6 { return .weak }
        switch score {
        case 3: return .strong
        case 2: return .fair
        default: return .weak
        }
    }
}

struct PasswordStrengthBar: View {
    let strength: PasswordStrength

    var body: some View {
        HStack(spacing: 4) {
            ForEach(PasswordStrength.allCases, id: \.self) { s in
                RoundedRectangle(cornerRadius: 2)
                    .fill(strengthColor(s))
                    .frame(height: 4)
            }
        }
    }

    private func strengthColor(_ s: PasswordStrength) -> Color {
        let order = PasswordStrength.allCases.firstIndex(of: strength)!
        let sOrder = PasswordStrength.allCases.firstIndex(of: s)!
        return sOrder <= order ? s.color : Color.pcText3.opacity(0.3)
    }
}

#Preview("ChangePassword") { ChangePasswordSheetView().environmentObject(AppViewModel()) }
