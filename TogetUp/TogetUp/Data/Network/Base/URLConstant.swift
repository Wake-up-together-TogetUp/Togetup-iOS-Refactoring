//
//  URLConstant.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/31.
//

import Foundation

struct URLConstant {
    // MARK: - Base URL
    static var baseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BaseUrl") as? String else {
            fatalError("BASE_URL not found in Info.plist")
        }
        return url
    }()
    
    // MARK: - Auth 로그인
    static let login = "auth/login"
    
    // MARK: - User
    static let withdrawl = "users"
    static let appleWithdrawl = "users/apple"
    static let sendFcmToken = "users/fcm-token"
    static let getAvatarList = "users/avatars"
    static let changeAvatar = "users/avatars"
    static let agreePush = "users/push"
    
    // MARK: - 알람
    static let getAlarmList = "alarms"
    static let createAlarm = "alarms"
    static let deleteAlarm = "alarms/"
    static let editAlarm = "alarms/"
    static let getSingleAlarm = "alarms/"
    static let deactivateAlarms = "alarms/deactivate"
    static let getTimeline = "alarms/timeline"
    
    // MARK: - noti
    static let getNotification = "notification"
    static let deleteNotification = "notification"
    static let patchNotification = "notification"
    
    // MARK: - 미션
    static let missionDetection = "mission/"
    static let getMissionList = "mission/"
    static let missionComplete = "mission/complete"
    
    // MARK: - 그룹
    static let getGroupList = "room/"
    static let createGroup = "room/"
    static let getMissionLog = "room/user/mission-log"
    static let getGroupDetail = "room/"
    static let joinGroup = "room/join/"
    static let deleteMember = "room/"
    static let getGroupDetailWithCode = "room/information"
    
    // MARK: - 아바타
    static let getAvatarSpeech = "avatars"
    
    // MARK: - 개발용
    static let versionCheck = "a-dev/version/check"
}
