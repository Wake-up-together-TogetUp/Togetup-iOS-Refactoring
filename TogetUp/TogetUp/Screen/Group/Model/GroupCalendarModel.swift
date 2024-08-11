//
//  GroupCalendarModel.swift
//  TogetUp
//
//  Created by nayeon  on 6/20/24.
//

struct GroupCalendarResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: GroupCalendarResult
}

struct GroupCalendarResult: Codable {
    let name: String
    let theme: String
    let userLogList: [UserLog]
}

struct UserLog: Codable {
    let userId: Int
    let userName: String
    let userCompleteType: String
    let missionPicLink: String
}

struct GroupDetailResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: GroupResultData
}

struct GroupResultData: Codable {
    let roomData: RoomData
    let missionData: MissionData
    let userProfileData: [UserProfileData]
}

struct RoomData: Codable {
    let name: String
    let intro: String
    let createdAt: String
    let headCount: Int
    let invitationCode: String
}

struct MissionData: Codable {
    let icon: String
    let missionKr: String
}

struct UserProfileData: Codable {
    let userId: Int
    let userName: String
    let theme: String
    let level: Int
}
