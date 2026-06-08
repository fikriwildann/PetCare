// MARK: - RootView.swift
// PetCare — Root Navigation: Splash → Onboarding → Auth → Main

import SwiftUI

struct RootView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
                    .transition(.opacity)
                    .zIndex(3)
            } else if vm.showOnboarding {
                OnboardingView(showOnboarding: $vm.showOnboarding)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)))
                    .zIndex(2)
            } else if !vm.isLoggedIn {
                LoginView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity))
                    .zIndex(1)
            } else {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity))
                    .zIndex(0)
            }
        }
        .animation(.pcSpring, value: showSplash)
        .animation(.pcSpring, value: vm.showOnboarding)
        .animation(.pcSpring, value: vm.isLoggedIn)
    }
}

// MARK: - MainTabView
struct MainTabView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showNotifications = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch vm.selectedTab {
                case 0:
                    NavigationStack { HomeView() }
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                case 1:
                    NavigationStack { PetsListView() }
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                case 2:
                    NavigationStack { ScheduleView() }
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                case 3:
                    NavigationStack { HealthView() }
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                case 4:
                    NavigationStack { ProfileView() }
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                default:
                    NavigationStack { HomeView() }
                }
            }
            .animation(.pcSpring, value: vm.selectedTab)

            // Floating Tab Bar
            FloatingTabBar(selected: $vm.selectedTab)
                .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject({
            let vm = AppViewModel()
            vm.showOnboarding = false
            vm.isLoggedIn = true
            return vm
        }())
}
