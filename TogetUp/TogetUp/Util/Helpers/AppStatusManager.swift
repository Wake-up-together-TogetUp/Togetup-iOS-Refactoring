//
//  AppStatusManager.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/18.
//

import Foundation
import UserNotifications

class AppStatusManager {
    static let shared = AppStatusManager()

    private init() { }

    var isFirstLaunch: Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstLaunch")
    }

    func markAsLaunched() {
        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
    }
    
    var isFirstLogin: Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstLogin")
    }
    
    func markAsLogined() {
        UserDefaults.standard.set(true, forKey: "isFirstLogin")
    }
    
    func markAsLoginedToFalse() {
        UserDefaults.standard.set(false, forKey: "isFirstLogin")
    }

    func clearSensitiveDataOnFirstLaunch() {
        if isFirstLaunch {
            KeyChainManager.shared.clearAll()
        }
    }
    
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    completion(true)
                case .denied, .notDetermined:
                    completion(false)
                default:
                    completion(false)
                }
            }
        }
    }
}
