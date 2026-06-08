// MARK: - FloatingTabBar.swift
// PetCare — Liquid Glass Floating Capsule Tab Bar

import SwiftUI

struct FloatingTabBar: View {
    @Binding var selected: Int
    @Namespace private var ns

    private let items: [(icon: String, activeIcon: String, label: String)] = [
        ("house",             "house.fill",          "Beranda"),
        ("pawprint",          "pawprint.fill",        "Hewan"),
        ("calendar",          "calendar",             "Jadwal"),
        ("heart",             "heart.fill",           "Kesehatan"),
        ("person.crop.circle","person.crop.circle.fill","Profil")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                tabItem(index: i)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.45), .white.opacity(0.10)],
                                startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tabItem(index i: Int) -> some View {
        let isActive = selected == i
        Button { withAnimation(.pcSpring) { selected = i } } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isActive {
                        Capsule()
                            .fill(Color.primaryGradient)
                            .frame(width: 44, height: 28)
                            .shadow(color: Color.pcIndigo.opacity(0.40), radius: 8, x: 0, y: 3)
                            .matchedGeometryEffect(id: "tabBg", in: ns)
                    }
                    Image(systemName: isActive ? items[i].activeIcon : items[i].icon)
                        .font(.system(size: 16, weight: isActive ? .semibold : .regular))
                        .foregroundStyle(isActive ? .white : Color.pcText3)
                        .scaleEffect(isActive ? 1.08 : 1.0)
                        .animation(.pcSpring, value: isActive)
                }
                .frame(width: 44, height: 28)

                Text(items[i].label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .medium, design: .rounded))
                    .foregroundStyle(isActive ? Color.pcIndigo : Color.pcText3)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PCNavigationBar
struct PCNavigationBar: View {
    let title: String
    var subtitle: String? = nil
    var leadingAction: (() -> Void)? = nil
    var leadingIcon: String = "chevron.left"
    var trailingView: AnyView? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if let action = leadingAction {
                Button(action: action) {
                    Image(systemName: leadingIcon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.pcIndigo)
                        .frame(width: 36, height: 36)
                        .liquidGlass(radius: 12)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
            Spacer()
            VStack(spacing: 1) {
                Text(title)
                    .font(PCFont.title3())
                    .foregroundStyle(Color.pcText1)
                if let s = subtitle {
                    Text(s).font(PCFont.caption()).foregroundStyle(Color.pcText2)
                }
            }
            Spacer()
            if let tv = trailingView {
                tv
            } else if leadingAction != nil {
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, PCSpace.lg)
        .padding(.vertical, PCSpace.sm)
    }
}

// MARK: - PCIconNavButton
struct PCIconNavButton: View {
    let icon: String
    var badge: Int = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.pcText2)
                    .frame(width: 38, height: 38)
                    .liquidGlass(radius: 12)
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Color.pcRed)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
