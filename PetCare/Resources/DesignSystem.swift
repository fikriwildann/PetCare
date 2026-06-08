// MARK: - DesignSystem.swift
// PetCare — Liquid Glass Design System

import SwiftUI

// ─────────────────────────────────────────
// MARK: Color Palette
// ─────────────────────────────────────────
extension Color {
    static let pcIndigo  = Color(hex: "#4F46E5")
    static let pcPurple  = Color(hex: "#8B5CF6")
    static let pcGreen   = Color(hex: "#10B981")
    static let pcOrange  = Color(hex: "#F59E0B")
    static let pcRed     = Color(hex: "#EF4444")
    static let pcCyan    = Color(hex: "#06B6D4")
    static let pcPink    = Color(hex: "#EC4899")

    static let pcBG      = Color(UIColor.systemGroupedBackground)
    static let pcCard    = Color(UIColor.secondarySystemGroupedBackground)
    static let pcCard2   = Color(UIColor.tertiarySystemGroupedBackground)
    static let pcText1   = Color(UIColor.label)
    static let pcText2   = Color(UIColor.secondaryLabel)
    static let pcText3   = Color(UIColor.tertiaryLabel)
    static let pcBorder  = Color(UIColor.separator)

    static var primaryGradient: LinearGradient {
        LinearGradient(colors: [.pcIndigo, .pcPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var heroGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "#312E81"), Color(hex: "#4F46E5"), Color(hex: "#7C3AED")],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var meshGradient: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#EEF2FF"), Color(hex: "#F5F3FF"), Color(hex: "#EDE9FE")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default: (a,r,g,b) = (255,1,1,1)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// ─────────────────────────────────────────
// MARK: Typography
// ─────────────────────────────────────────
struct PCFont {
    static func display(_ w: Font.Weight = .bold) -> Font   { .system(size: 34, weight: w, design: .rounded) }
    static func title1(_ w: Font.Weight = .bold) -> Font    { .system(size: 28, weight: w, design: .rounded) }
    static func title2(_ w: Font.Weight = .bold) -> Font    { .system(size: 22, weight: w, design: .rounded) }
    static func title3(_ w: Font.Weight = .semibold) -> Font{ .system(size: 20, weight: w, design: .rounded) }
    static func headline() -> Font                           { .system(size: 17, weight: .semibold, design: .rounded) }
    static func body() -> Font                               { .system(size: 17, weight: .regular,  design: .rounded) }
    static func subhead() -> Font                            { .system(size: 15, weight: .regular,  design: .rounded) }
    static func footnote() -> Font                           { .system(size: 13, weight: .regular,  design: .rounded) }
    static func caption() -> Font                            { .system(size: 12, weight: .medium,   design: .rounded) }
    static func micro() -> Font                              { .system(size: 11, weight: .semibold, design: .rounded) }
}

// ─────────────────────────────────────────
// MARK: Spacing & Radius
// ─────────────────────────────────────────
enum PCSpace {
    static let xxs: CGFloat  = 4
    static let xs: CGFloat   = 8
    static let sm: CGFloat   = 12
    static let md: CGFloat   = 16
    static let lg: CGFloat   = 20
    static let xl: CGFloat   = 24
    static let xxl: CGFloat  = 32
    static let xxxl: CGFloat = 48
}

enum PCRadius {
    static let xs: CGFloat   = 8
    static let sm: CGFloat   = 12
    static let md: CGFloat   = 16
    static let lg: CGFloat   = 20
    static let xl: CGFloat   = 24
    static let xxl: CGFloat  = 28
    static let xxxl: CGFloat = 32
    static let full: CGFloat = 999
}

// ─────────────────────────────────────────
// MARK: Liquid Glass Modifiers
// ─────────────────────────────────────────

/// Standard Liquid Glass card — ultra-thin material + white edge highlight
struct LiquidGlassCard: ViewModifier {
    var radius: CGFloat = PCRadius.xl
    var shadowColor: Color = .black.opacity(0.10)
    var shadowRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.45), .white.opacity(0.08)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1)
                    )
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 4)
    }
}

/// Elevated glass — thin material, stronger shadow
struct ElevatedGlassCard: ViewModifier {
    var radius: CGFloat = PCRadius.xxl

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(Color.white.opacity(0.30), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: 8)
    }
}

/// Regular material card — for deeper panels
struct SolidGlassCard: ViewModifier {
    var radius: CGFloat = PCRadius.xl

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 3)
    }
}

extension View {
    func liquidGlass(radius: CGFloat = PCRadius.xl) -> some View {
        modifier(LiquidGlassCard(radius: radius))
    }
    func elevatedGlass(radius: CGFloat = PCRadius.xxl) -> some View {
        modifier(ElevatedGlassCard(radius: radius))
    }
    func solidGlass(radius: CGFloat = PCRadius.xl) -> some View {
        modifier(SolidGlassCard(radius: radius))
    }
}

// ─────────────────────────────────────────
// MARK: Background Views
// ─────────────────────────────────────────

struct PCMeshBackground: View {
    @Environment(\.colorScheme) var cs
    var body: some View {
        ZStack {
            if cs == .dark {
                LinearGradient(
                    colors: [Color(hex: "#0D0D1A"), Color(hex: "#0F0A1E"), Color(hex: "#0A0D1A")],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
            } else {
                LinearGradient(
                    colors: [Color(hex: "#EEF2FF"), Color(hex: "#F5F3FF"), Color(hex: "#EDE9FE")],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            // Decorative blobs
            Circle()
                .fill(Color.pcIndigo.opacity(cs == .dark ? 0.18 : 0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: -120)
            Circle()
                .fill(Color.pcPurple.opacity(cs == .dark ? 0.16 : 0.07))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 140, y: 200)
            Circle()
                .fill(Color.pcCyan.opacity(cs == .dark ? 0.10 : 0.05))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: 60, y: 500)
        }
        .ignoresSafeArea()
    }
}

// ─────────────────────────────────────────
// MARK: Animations
// ─────────────────────────────────────────
extension Animation {
    static let pcSpring  = Animation.spring(response: 0.45, dampingFraction: 0.72)
    static let pcBounce  = Animation.spring(response: 0.38, dampingFraction: 0.60)
    static let pcSmooth  = Animation.easeInOut(duration: 0.30)
    static let pcFast    = Animation.easeOut(duration: 0.20)
}

// ─────────────────────────────────────────
// MARK: Helpers
// ─────────────────────────────────────────
extension Date {
    func pcFormatted(_ fmt: String) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "id_ID"); f.dateFormat = fmt
        return f.string(from: self)
    }
    var shortDate:  String { pcFormatted("d MMM yyyy") }
    var mediumDate: String { pcFormatted("d MMMM yyyy") }
    var timeOnly:   String { pcFormatted("HH:mm") }
    var monthYear:  String { pcFormatted("MMMM yyyy") }

    var isToday:     Bool { Calendar.current.isDateInToday(self) }
    var isTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }

    var relative: String {
        if isToday     { return "Hari ini" }
        if isTomorrow  { return "Besok" }
        if isYesterday { return "Kemarin" }
        let d = Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
        return d > 0 ? "\(d) hari lagi" : "\(-d) hari lalu"
    }
}

var pcGreeting: String {
    let h = Calendar.current.component(.hour, from: Date())
    switch h {
    case 0..<11: return "Selamat Pagi"
    case 11..<15: return "Selamat Siang"
    case 15..<18: return "Selamat Sore"
    default: return "Selamat Malam"
    }
}
