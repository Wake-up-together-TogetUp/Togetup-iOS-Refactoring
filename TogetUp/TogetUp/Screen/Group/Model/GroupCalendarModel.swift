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
