//
//  GroupAPI.swift
//  TogetUp
//
//  Created by nayeon  on 5/20/24.
//

import Foundation
import Moya

enum GroupAPI {
    case getGroupList
    case createGroup(CreateGroupRequest)
    case getMissionLog(roomId: Int, localDate: String)
    case getGroupDetailWithCode(invitationCode: Int)
}

extension GroupAPI: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getGroupList:
            return URLConstant.getGroupList
        case .createGroup:
            return URLConstant.createGroup
        case .getMissionLog:
            return URLConstant.getMissionLog
        case .getGroupDetailWithCode:
            return URLConstant.getGroupDetailWithCode
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getGroupList,.getMissionLog,.getGroupDetailWithCode:
            return .get
        case .createGroup:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getGroupList:
            return .requestPlain
        case .createGroup(let param):
            return .requestJSONEncodable(param)
        case .getMissionLog(let roomId, let localDate):
            return .requestParameters(parameters: ["roomId": roomId, "localDate": localDate], encoding: URLEncoding.queryString)
        case .getGroupDetailWithCode(let invitationCode):
                   return .requestParameters(parameters: ["invitationCode": invitationCode], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getGroupList, .createGroup, .getMissionLog, .getGroupDetailWithCode:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
