//
//  HomeService.swift
//  TogetUp
//
//  Created by 이예원 on 11/26/23.
//

import Foundation
import Moya

enum AvatarService {
    case getAvatarSpeech(avatarId: Int)
}

extension AvatarService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {

        case .getAvatarSpeech(let avatarId):
            return URLConstant.getAvatarSpeech + "/\(avatarId)/speeches"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAvatarSpeech:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getAvatarSpeech(let avatarId):
            return .requestParameters(parameters: ["avatarId" : avatarId], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getAvatarSpeech:
            let token = KeyChainManager.shared.getToken()
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
}
