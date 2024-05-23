//
//  GroupModel.swift
//  TogetUp
//
//  Created by nayeon  on 5/20/24.
//

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
