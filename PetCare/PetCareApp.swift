// MARK: - PetCareApp.swift
// PetCare — App Entry Point

import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct PetCareApp: App {
    @StateObject private var vm = AppViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
                .onAppear {
                    vm.checkAuthState()
                }
        }
    }
}

// MARK: - AppDelegate for Notification Handling
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set as notification center delegate to handle foreground notifications
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Clear badge when app is opened
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner, sound, and badge even when app is open
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Handle notification tap — navigate to relevant screen based on identifier
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .didReceiveNotificationTap,
                object: nil,
                userInfo: userInfo
            )
        }

        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let didReceiveNotificationTap = Notification.Name("didReceiveNotificationTap")
}
