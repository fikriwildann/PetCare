# 🐾 PetCare — iOS App

**PetCare** adalah aplikasi iOS premium untuk mengelola kesehatan dan aktivitas hewan peliharaan, dibangun dengan **SwiftUI** dan **Liquid Glass Design System**.

---

## 📁 Struktur Proyek

```
PetCare/
│
├── PetCareApp.swift               ← App entry point (@main)
├── RootView.swift                 ← Root navigation: Splash → Onboarding → Auth → Main
│
├── Models/
│   ├── PetModels.swift            ← Pet, Vaccine, Medication, Feeding, HealthRecord, Weight, Notification, User
│   └── SampleData.swift           ← Dummy data untuk Preview & development
│
├── ViewModels/
│   └── AppViewModel.swift         ← @MainActor ObservableObject — central state manager
│
├── Views/
│   ├── Authentication/
│   │   ├── SplashView.swift       ← Animated gradient splash screen
│   │   ├── OnboardingView.swift   ← 3-slide swipeable onboarding
│   │   └── AuthViews.swift        ← LoginView + RegisterView (Liquid Glass cards)
│   │
│   ├── Home/
│   │   └── HomeView.swift         ← Dashboard: hero card, stats grid, pets scroll, schedule, health summary
│   │
│   ├── Pets/
│   │   ├── PetsView.swift         ← PetsListView + AddPetView + PetDetailView
│   │   └── EditViews.swift        ← EditPetView + EditProfileView
│   │
│   ├── Schedule/
│   │   └── ScheduleView.swift     ← ScheduleView (all) + FeedingDetailView
│   │
│   ├── Health/
│   │   ├── HealthView.swift       ← HealthView hub + VaccineListView + MedicationListView
│   │   │                            + HealthHistoryView (timeline) + WeightChartView (Swift Charts)
│   │   └── FormViews.swift        ← AddVaccineView + AddMedicationView + AddHealthRecordView + AddFeedingView
│   │
│   └── Profile/
│       └── ProfileView.swift      ← ProfileView + NotificationsView
│
├── Components/
│   ├── Components.swift           ← Full Liquid Glass UI kit:
│   │                                  PCPrimaryButton, PCSecondaryButton, PCDestructiveButton
│   │                                  PCFAB, PCTextField, PCBadge, PCSectionHeader
│   │                                  PCPillFilter, PCSegmentControl, PCToggleRow, PCMenuRow
│   │                                  PCProgressBar, PCEmptyState, PCIconBox
│   │                                  PCGlassSearchBar, PCScheduleRow, PCMiniBarChart
│   └── FloatingTabBar.swift       ← Liquid Glass floating capsule tab bar + PCNavigationBar + PCIconNavButton
│
├── Services/
│   ├── SheetCoordinator.swift     ← GlobalSheetModifier for all form modals
│   ├── NotificationService.swift  ← UNUserNotificationCenter scheduling
│   └── PersistenceService.swift   ← Simple JSON local storage
│
└── Resources/
    └── DesignSystem.swift         ← Colors, Typography, Spacing, Radius, Liquid Glass modifiers,
                                      PCMeshBackground, Animations, Date/Number helpers
```

---

## 🎨 Design System — Liquid Glass

Semua komponen menggunakan **Liquid Glass** sebagai fondasi visual:

| Modifier | Material | Penggunaan |
|---|---|---|
| `.liquidGlass()` | `.ultraThinMaterial` | Card standar, row items |
| `.elevatedGlass()` | `.thinMaterial` | Form cards, hero panels |
| `.solidGlass()` | `.regularMaterial` | Deep background panels |

### Warna Utama
| Token | Hex | Penggunaan |
|---|---|---|
| `pcIndigo` | `#4F46E5` | Primary, tab active, CTA |
| `pcPurple` | `#8B5CF6` | Secondary, medication |
| `pcGreen` | `#10B981` | Success, health status |
| `pcOrange` | `#F59E0B` | Warning, upcoming |
| `pcRed` | `#EF4444` | Danger, overdue |

### Animasi
```swift
.pcSpring  // spring(response: 0.45, dampingFraction: 0.72) — default
.pcBounce  // spring(response: 0.38, dampingFraction: 0.60) — playful
.pcSmooth  // easeInOut(0.30) — subtle transitions
.pcFast    // easeOut(0.20) — micro interactions
```

---

## 🚀 Setup & Requirements

### Requirements
- **Xcode 16.0+**
- **iOS 17.0+** (untuk Swift Charts + Material APIs)
- **Swift 5.10+**

### Cara Setup
1. Buat project baru di Xcode: **File → New → Project → App**
2. Nama: `PetCare`, Bundle ID: `com.yourname.petcare`
3. Language: **Swift**, Interface: **SwiftUI**
4. Copy semua file dari folder ini ke project Xcode sesuai struktur
5. Pastikan **Swift Charts** tersedia (sudah built-in di iOS 16+)
6. Build & Run!

### Capabilities yang Diperlukan
Di `Signing & Capabilities`, tambahkan:
- **Push Notifications** — untuk notifikasi pengingat
- **Background Modes** → Background fetch — untuk sync background

---

## 📱 Halaman yang Tersedia

| # | Halaman | File |
|---|---|---|
| 1 | Splash Screen | `SplashView.swift` |
| 2 | Onboarding (3 slides) | `OnboardingView.swift` |
| 3 | Login | `AuthViews.swift` |
| 4 | Register | `AuthViews.swift` |
| 5 | Dashboard Beranda | `HomeView.swift` |
| 6 | Daftar Hewan | `PetsView.swift` |
| 7 | Tambah Hewan | `PetsView.swift` |
| 8 | Detail Hewan | `PetsView.swift` |
| 9 | Manajemen Vaksin | `HealthView.swift` |
| 10 | Jadwal Makan | `ScheduleView.swift` |
| 11 | Manajemen Obat | `HealthView.swift` |
| 12 | Riwayat Kesehatan | `HealthView.swift` |
| 13 | Grafik Berat Badan | `HealthView.swift` |
| 14 | Notifikasi | `ProfileView.swift` |
| 15 | Profil | `ProfileView.swift` |
| + | Edit Hewan | `EditViews.swift` |
| + | Edit Profil | `EditViews.swift` |
| + | Add Vaccine/Med/Feeding/Record | `FormViews.swift` |

---

## 🏗️ Arsitektur

```
MVVM + Single Source of Truth

Views  ←→  AppViewModel (ObservableObject)
               ↕
          PersistenceService (JSON)
               ↕
          NotificationService (UNUserNotificationCenter)
```

- **Models** — Pure data structs, `Codable + Identifiable`
- **AppViewModel** — `@MainActor ObservableObject`, semua state dan actions
- **Views** — `@EnvironmentObject var vm: AppViewModel` di semua views
- **Services** — Singleton services untuk persistence dan notifications

---

## 🔮 Roadmap / Fitur Lanjutan

- [ ] CloudKit sync untuk backup data
- [ ] WidgetKit — jadwal hewan di Home Screen
- [ ] Siri Shortcuts integrasi
- [ ] Export PDF riwayat kesehatan
- [ ] Multi-language support (EN/ID)
- [ ] Vet appointment booking
- [ ] Pet community feed

---

*PetCare v1.0.0 — Dibangun dengan ❤️ menggunakan SwiftUI + Liquid Glass Design System*
