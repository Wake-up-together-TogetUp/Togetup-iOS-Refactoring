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
    let missionObjectId: Int?
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
