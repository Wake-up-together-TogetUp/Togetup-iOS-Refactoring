//
//  AlarmModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/10.
//

import Foundation

struct GetAlarmListResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: [GetAlarmResult]?
}

struct GetSingleAlarmResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: GetAlarmResult?
}

struct CreateEditDeleteAlarmResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: Int?
}

struct CreateOrEditAlarmRequest: Codable {
    let missionId: Int
    let missionObjectId: Int?
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
}

struct GetAlarmResult: Codable {
    let id: Int
    let userId: Int?
    let name: String
    let alarmTime: String
    let monday, tuesday, wednesday, thursday, friday, saturday, sunday: Bool
    let isVibrate, isActivated: Bool
    let missionRes: MissionRes?
    let missionObjectRes: MissionObjectRes?
    let alarmRoomRes: RoomRes?
}

struct MissionRes: Codable {
    let id: Int
    let name: String
    let createdAt: String
    let isActive: Bool
}

struct MissionObjectRes: Codable {
    let id: Int
    let name, kr, icon: String
}

struct RoomRes: Codable {
    let id: Int?
    let name, intro, groupProfileImgLink, password: String?
    let state: Int?
}
