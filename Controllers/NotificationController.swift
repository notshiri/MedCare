//
//  NotificationController.swift
//  MedCare
//

import Foundation
import UserNotifications
import Combine

private enum NotificationConstants {
    static let reminderCategory = "MEDICATION_REMINDER"
    static let snoozeAction = "SNOOZE_ACTION"
    static let snoozeInterval: TimeInterval = 15 * 60
    static let prescriptionIdKey = "prescriptionId"
    static let prescriptionNameKey = "prescriptionName"
    static let dosageKey = "dosage"
}

final class NotificationController: NSObject, ObservableObject {

    @Published var isAuthorized: Bool = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
    }

    // MARK: - Permission
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }

    private func registerCategories() {
        let snooze = UNNotificationAction(
            identifier: NotificationConstants.snoozeAction,
            title: "Snooze 15 min",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: NotificationConstants.reminderCategory,
            actions: [snooze],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Scheduling daily reminders
    func scheduleReminders(for prescription: Prescription) {
        guard prescription.isActive else { return }

        for (index, comps) in prescription.reminderTimes.enumerated() {
            let content = makeContent(for: prescription)

            var trigger = DateComponents()
            trigger.hour = comps.hour
            trigger.minute = comps.minute

            let request = UNNotificationRequest(
                identifier: identifier(for: prescription.id, index: index),
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelReminders(for prescriptionId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(prescriptionId.uuidString) }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    private func makeContent(for prescription: Prescription) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(prescription.name)"
        content.body = "Take your \(prescription.dosage) dose now."
        content.sound = .default
        content.categoryIdentifier = NotificationConstants.reminderCategory
        content.userInfo = [
            NotificationConstants.prescriptionIdKey: prescription.id.uuidString,
            NotificationConstants.prescriptionNameKey: prescription.name,
            NotificationConstants.dosageKey: prescription.dosage
        ]
        return content
    }

    private func identifier(for prescriptionId: UUID, index: Int) -> String {
        "\(prescriptionId.uuidString)-reminder-\(index)"
    }

    // MARK: - Refill alerts

    static func sendRefillAlert(for prescription: Prescription) {
        let content = UNMutableNotificationContent()
        content.title = "Refill Reminder"
        content.body = "You're running low on \(prescription.name). Time to request a refill."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(prescription.id.uuidString)-refill-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationController: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == NotificationConstants.snoozeAction {
            let originalContent = response.notification.request.content
            let snoozedContent = UNMutableNotificationContent()
            snoozedContent.title = originalContent.title
            snoozedContent.body = originalContent.body
            snoozedContent.sound = originalContent.sound
            snoozedContent.categoryIdentifier = originalContent.categoryIdentifier
            snoozedContent.userInfo = originalContent.userInfo

            let request = UNNotificationRequest(
                identifier: "\(response.notification.request.identifier)-snoozed-\(UUID().uuidString)",
                content: snoozedContent,
                trigger: UNTimeIntervalNotificationTrigger(
                    timeInterval: NotificationConstants.snoozeInterval,
                    repeats: false
                )
            )
            center.add(request)
        }
        completionHandler()
    }
}
