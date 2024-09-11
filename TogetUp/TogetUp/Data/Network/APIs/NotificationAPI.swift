//
//  NotificationAPI.swift
//  TogetUp
//
//  Created by nayeon  on 8/18/24.
//

import Foundation
import Moya

enum NotificationAPI {
    case getNotification
    case deleteNotification(notificationId: Int)
    case patchNotification(notificationId: Int)
}

extension NotificationAPI: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getNotification:
            return URLConstant.getNotification
        case .deleteNotification:
            return URLConstant.deleteNotification
        case .patchNotification:
            return URLConstant.patchNotification
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getNotification:
            return .get
        case .deleteNotification:
            return .delete
        case .patchNotification:
            return .patch
        }
    }
    
    var task: Task {
        switch self {

        case .getNotification:
            return .requestPlain
        case .deleteNotification(let notificationId),.patchNotification(let notificationId):
            return .requestParameters(parameters: ["notificationId": notificationId], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getNotification, .deleteNotification,.patchNotification:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
