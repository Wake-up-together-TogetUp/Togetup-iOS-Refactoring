//
//  MissionService.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/11.
//

import Foundation
import Moya
import UIKit

enum MissionService {
    case getMissionList(missionId: Int)
    case missionDetection(objectName: String, missionImage: UIImage)
}

extension MissionService: TargetType {
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getMissionList(let missionId):
            return URLConstant.getMissionList + "\(missionId)"
        case .missionDetection(let objectName, _):
            return URLConstant.missionDetection + objectName
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMissionList:
            return .get
        case .missionDetection:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMissionList:
            return .requestPlain
        case .missionDetection(_, let missionImage):
            guard let imageData = missionImage.jpegData(compressionQuality: 1.0) else {
                print("jpeg 변환 실패")
                return .requestPlain
            }
            let imagePart = MultipartFormData(provider: .data(imageData), name: "missionImage", fileName: "missionImage.jpg", mimeType: "image/jpeg")
            return .uploadMultipart([imagePart])
        }
    }
    
    var headers: [String : String]? {
        let token = KeyChainManager.shared.getToken()
        switch self {
        case .getMissionList:
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json"
            ]
        case .missionDetection:
            return [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "multipart/form-data"
            ]
        }
    }
}

