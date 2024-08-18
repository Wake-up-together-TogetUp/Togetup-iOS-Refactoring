//
//  NotificationModel.swift
//  TogetUp
//
//  Created by nayeon  on 8/18/24.
//

import Foundation

struct NotificationResponse: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
    let result: NotificationResult
}


struct NotificationResult: Codable {
    let notificationListRes: [NotificationList]
}


struct NotificationList: Codable {
    let id: Int
    let title: String
    let body: String
    let dataMap: NotificationDataMap
    let isRead: Bool
}


struct NotificationDataMap: Codable {
    let link: String
    let roomId: String?
}

