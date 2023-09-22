//
//  CreateAlarmModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/04.
//

import Foundation

struct CreateAlarmRequest: Codable {
    let missionId: Int
    let missionObjectId: Int?
    let isSnoozeActivated: Bool
    let name: String
    let icon: String
    let isVibrate: Bool
    let alarmTime: String
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
    let isActivated: Bool
    let roomId: Int?
}

struct CreateOrDeleteAlarmResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: Int?
}

