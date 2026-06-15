// MARK: - Components.swift
// PetCare — Reusable Liquid Glass UI Components

import SwiftUI

// ─────────────────────────────────────────
// MARK: PCButton
// ─────────────────────────────────────────
struct PCPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    @State private var pressed = false

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: 16, weight: .semibold)) }
                Text(title).font(PCFont.headline())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(Color.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous))
            .shadow(color: Color.pcIndigo.opacity(0.35), radius: 16, x: 0, y: 6)
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50,
            pressing: { p in withAnimation(.pcFast) { pressed = p } }, perform: {})
    }
}

struct PCSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(PCFont.headline())
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .foregroundStyle(Color.pcIndigo)
                .liquidGlass(radius: PCRadius.lg)
        }
        .buttonStyle(.plain)
    }
}

struct PCDestructiveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(PCFont.headline())
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .foregroundStyle(Color.pcRed)
                .background(Color.pcRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: PCRadius.lg, style: .continuous)
                        .stroke(Color.pcRed.opacity(0.20), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────
// MARK: Floating Action Button
// ─────────────────────────────────────────
struct PCFAB: View {
    let icon: String
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.pcIndigo.opacity(0.45), radius: 18, x: 0, y: 8)
                .scaleEffect(pressed ? 0.93 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50,
            pressing: { p in withAnimation(.pcBounce) { pressed = p } }, perform: {})
    }
}

// ─────────────────────────────────────────
// MARK: PCTextField
// ─────────────────────────────────────────
struct PCTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var autocapitalization: TextInputAutocapitalization = .never
    @State private var showSecure = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(PCFont.micro())
                .foregroundStyle(Color.pcText3)
                .tracking(0.5)

            ZStack(alignment: .trailing) {
                Group {
                    if isSecure && !showSecure {
                        SecureField(placeholder, text: $text)
                            .textInputAutocapitalization(autocapitalization)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(autocapitalization)
                    }
                }
                .font(PCFont.subhead())
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .padding(.trailing, isSecure ? 48 : 0)
                .background(
                    RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                                .stroke(focused ? Color.pcIndigo : Color.pcBorder, lineWidth: focused ? 1.5 : 0.5)
                        )
                )
                .focused($focused)

                if isSecure {
                    Button { withAnimation(.pcFast) { showSecure.toggle() } } label: {
                        Image(systemName: showSecure ? "eye.slash" : "eye")
                            .foregroundStyle(Color.pcText3)
                            .padding(.trailing, 16)
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────
// MARK: PCBadge
// ─────────────────────────────────────────
struct PCBadge: View {
    let text: String
    let color: Color
    var small: Bool = false

    var body: some View {
        Text(text)
            .font(small ? PCFont.micro() : PCFont.caption())
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, small ? 8 : 10)
            .padding(.vertical, small ? 3 : 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// ─────────────────────────────────────────
// MARK: PCSectionHeader
// ─────────────────────────────────────────
struct PCSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(PCFont.title3())
                .foregroundStyle(Color.pcText1)
            Spacer()
            if let t = actionTitle {
                Button(action: action ?? {}) {
                    Text(t).font(PCFont.subhead().weight(.semibold)).foregroundStyle(Color.pcIndigo)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ─────────────────────────────────────────
// MARK: PCPillFilter
// ─────────────────────────────────────────
struct PCPillFilter<T: Hashable>: View {
    let options: [(label: String, value: T)]
    @Binding var selected: T

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.value) { opt in
                    let isActive = selected == opt.value
                    Button { withAnimation(.pcSpring) { selected = opt.value } } label: {
                        Text(opt.label)
                            .font(PCFont.footnote().weight(.semibold))
                            .foregroundStyle(isActive ? .white : Color.pcText2)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isActive ? AnyShapeStyle(Color.primaryGradient) : AnyShapeStyle(Color.clear))
                                    .overlay(
                                        Capsule().stroke(isActive ? Color.clear : Color.pcBorder, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: isActive ? Color.pcIndigo.opacity(0.30) : .clear, radius: 8, x: 0, y: 3)
                }
            }
            .padding(.horizontal, PCSpace.lg)
        }
    }
}

// ─────────────────────────────────────────
// MARK: PCSegmentControl
// ─────────────────────────────────────────
struct PCSegmentControl: View {
    let options: [String]
    @Binding var selected: Int
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 3) {
            ForEach(options.indices, id: \.self) { i in
                Button { withAnimation(.pcSpring) { selected = i } } label: {
                    Text(options[i])
                        .font(PCFont.footnote().weight(.semibold))
                        .foregroundStyle(selected == i ? Color.pcIndigo : Color.pcText2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if selected == i {
                                RoundedRectangle(cornerRadius: PCRadius.sm, style: .continuous)
                                    .fill(.thinMaterial)
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    .matchedGeometryEffect(id: "seg", in: ns)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                        .stroke(Color.pcBorder, lineWidth: 0.5))
        )
        .padding(.horizontal, PCSpace.lg)
    }
}

// ─────────────────────────────────────────
// MARK: PCToggleRow
// ─────────────────────────────────────────
struct PCToggleRow: View {
    let icon: String
    let iconBg: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconBg)
                    .frame(width: 32, height: 32)
                Image(systemName: icon).font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(title).font(PCFont.subhead()).foregroundStyle(Color.pcText1)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(Color.pcIndigo)
        }
        .padding(.vertical, 2)
    }
}

// ─────────────────────────────────────────
// MARK: PCMenuRow
// ─────────────────────────────────────────
struct PCMenuRow: View {
    let icon: String
    let iconBg: Color
    let title: String
    var subtitle: String? = nil
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconBg)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon).font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(PCFont.subhead()).foregroundStyle(Color.pcText1)
                    if let s = subtitle {
                        Text(s).font(PCFont.caption()).foregroundStyle(Color.pcText3)
                    }
                }
                Spacer()
                if let b = badge {
                    Text(b).font(PCFont.micro()).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.pcRed).clipShape(Capsule())
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.pcText3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────
// MARK: PCProgressBar
// ─────────────────────────────────────────
struct PCProgressBar: View {
    let progress: Double
    var color: Color = .pcIndigo
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height/2, style: .continuous)
                    .fill(color.opacity(0.15))
                RoundedRectangle(cornerRadius: height/2, style: .continuous)
                    .fill(LinearGradient(colors: [color, color.opacity(0.75)],
                                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * min(max(progress, 0), 1))
                    .animation(.pcSmooth, value: progress)
            }
        }
        .frame(height: height)
    }
}

// ─────────────────────────────────────────
// MARK: PCEmptyState
// ─────────────────────────────────────────
struct PCEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String = "Tambah"

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)
            Image(systemName: icon)
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Color.pcText3)
            Text(title)
                .font(PCFont.title3())
                .foregroundStyle(Color.pcText1)
            Text(message)
                .font(PCFont.subhead())
                .foregroundStyle(Color.pcText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            if let action {
                PCPrimaryButton(actionTitle, icon: "plus", action: action)
                    .frame(width: 200)
            }
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// ─────────────────────────────────────────
// MARK: PCIconBox
// ─────────────────────────────────────────
struct PCIconBox: View {
    let emoji: String
    let color: Color
    var size: CGFloat = 44
    var cornerRadius: CGFloat = 14

    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.55))
            .frame(width: size, height: size)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// ─────────────────────────────────────────
// MARK: PCGlassSearchBar
// ─────────────────────────────────────────
struct PCGlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Cari..."
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.pcText3)
            TextField(placeholder, text: $text)
                .font(PCFont.subhead())
                .focused($focused)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.pcText3)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .liquidGlass(radius: PCRadius.md)
        .animation(.pcFast, value: text)
    }
}

// ─────────────────────────────────────────
// MARK: PCScheduleRow
// ─────────────────────────────────────────
struct PCScheduleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let badge: String
    let badgeColor: Color

    var body: some View {
        HStack(spacing: 14) {
            PCIconBox(emoji: icon, color: iconColor, size: 40, cornerRadius: 12)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(PCFont.subhead().weight(.semibold)).foregroundStyle(Color.pcText1)
                Text(subtitle).font(PCFont.caption()).foregroundStyle(Color.pcText2)
            }
            Spacer()
            PCBadge(text: badge, color: badgeColor)
        }
        .padding(14)
        .liquidGlass(radius: PCRadius.md)
    }
}

// ─────────────────────────────────────────
// MARK: Mini Chart (SVG-style bars)
// ─────────────────────────────────────────
struct PCMiniBarChart: View {
    let values: [Double]
    var color: Color = .pcIndigo
    var height: CGFloat = 32

    private var max: Double { values.max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(values.indices, id: \.self) { i in
                let h = max > 0 ? CGFloat(values[i] / max) * height : 4
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(i == values.count - 1 ? color : color.opacity(0.4))
                    .frame(width: 5, height: Swift.max(h, 4))
            }
        }
        .frame(height: height, alignment: .bottom)
    }
}
