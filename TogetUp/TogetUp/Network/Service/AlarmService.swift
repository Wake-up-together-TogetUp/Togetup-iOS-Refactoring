//
//  AlarmService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/04.
//

import Foundation
import Moya


enum AlarmService {
    case createAlarm(param: CreateAlarmRequest)
    case getAlarmList(type: String)
    case deleteAlarm(alarmId: Int)
    case getSingleAlarm(alarmId: Int)
}

extension AlarmService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .createAlarm, .getAlarmList:
            return URLConstant.createAlarm
        case .deleteAlarm(let id), .getSingleAlarm(let id):
            return URLConstant.deleteAlarm + "\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createAlarm:
            return .post
        case .getAlarmList:
            return .get
        case .deleteAlarm:
            return .delete
        case .getSingleAlarm:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .createAlarm(let param):
            return .requestJSONEncodable(param)
        case .getAlarmList(let type):
            return .requestParameters(parameters: ["type" : type], encoding: URLEncoding.queryString)
        case .deleteAlarm:
            return .requestPlain
        case .getSingleAlarm(let id):
            return .requestParameters(parameters: ["alarmId" : id], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createAlarm, .getAlarmList, .deleteAlarm, .getSingleAlarm:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
        
    }
}
