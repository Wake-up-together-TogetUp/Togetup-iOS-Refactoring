//
//  GroupModel.swift
//  TogetUp
//
//  Created by nayeon  on 5/20/24.
//

struct CreateGroupResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: Int
}

struct CreateGroupRequest: Codable {
    let name: String
    let intro: String
    let alarmCreateReq: GroupAlarmRequest
}

struct GroupAlarmRequest: Codable {
    let name: String
    let alarmTime: String
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
    let isVibrate: Bool
    let missionId: Int
    let missionObjectId: Int
}

struct GetGroupListResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: [GroupResult]
}

struct GroupResult: Codable {
    let roomId: Int
    let icon: String
    let name: String
    let mission: String
    let kr: String
}

struct GroupResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: GroupInfo
}

struct GroupInfo: Codable {
    let id: Int
    let icon: String
    let name: String
    let intro: String
    let createdAt: String
    let headCount: Int
    let missionObjectId: Int
    let missionKr: String
    let missionName: String
}
