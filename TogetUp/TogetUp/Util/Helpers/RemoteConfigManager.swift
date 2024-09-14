//
//  RemoteConfigManager.swift
//  TogetUp
//
//  Created by nayeon  on 9/13/24.
//

import FirebaseRemoteConfigInternal

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    private init() {}
    
    func fetchRemoteConfig(completion: @escaping () -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1시간 간격으로 fetch
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { status, error in
            if status == .success {
                remoteConfig.activate { _, _ in
                    // Fetch가 성공한 경우
                    self.updateBaseURL()
                    completion()
                }
            } else {
                print("Failed to fetch remote config: \(String(describing: error))")
                completion()
            }
        }
    }
    
    private func updateBaseURL() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let isProd = remoteConfig.configValue(forKey: "isProdEnvironment").boolValue
        if isProd {
            URLConstant.baseURL = remoteConfig.configValue(forKey: "api_base_url_prod").stringValue ?? URLConstant.baseURL
        } else {
            URLConstant.baseURL = remoteConfig.configValue(forKey: "api_base_url_dev").stringValue ?? URLConstant.baseURL
        }
        print("Updated baseURL to: \(URLConstant.baseURL)")
    }
}
