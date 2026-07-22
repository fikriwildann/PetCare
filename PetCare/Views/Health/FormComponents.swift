// MARK: - FormComponents.swift
// PetCare — Shared form helper views

import SwiftUI

// MARK: - Pet Picker Chip
struct PetPickerChip: View {
    let pet: Pet; let selected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(pet.type.emoji).font(.system(size: 18))
                Text(pet.name).font(PCFont.subhead().weight(.semibold))
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .foregroundStyle(selected ? .white : Color.pcText2)
            .background(
                Capsule()
                    .fill(selected ? AnyShapeStyle(Color.primaryGradient) : AnyShapeStyle(Color.clear))
                    .overlay(Capsule().stroke(selected ? Color.clear : Color.pcBorder, lineWidth: 1))
            )
            .shadow(color: selected ? Color.pcIndigo.opacity(0.30) : .clear, radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Form Card Helper
func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 16) { content() }
        .padding(PCSpace.xl)
        .modifier(ElevatedGlassCard(radius: PCRadius.xxl))
        .padding(.horizontal, PCSpace.lg)
}

// MARK: - Section Label
struct PCSectionLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(PCFont.micro())
            .foregroundStyle(Color.pcText3)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Date Row Helper
func dateRow(_ label: String, selection: Binding<Date>) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label.uppercased())
            .font(PCFont.micro()).foregroundStyle(Color.pcText3).tracking(0.5)
        HStack {
            Spacer()
            DatePicker("", selection: selection, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(Color.pcIndigo)
            Spacer()
        }
    }
}

// MARK: - Note Editor Helper
func noteEditor(text: Binding<String>) -> some View {
    TextEditor(text: text)
        .font(PCFont.subhead())
        .frame(height: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: PCRadius.md, style: .continuous)
                    .stroke(Color.pcBorder, lineWidth: 0.5)))
        .scrollContentBackground(.hidden)
}
