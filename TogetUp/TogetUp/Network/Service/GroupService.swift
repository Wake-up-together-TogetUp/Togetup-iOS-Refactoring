//
//  GroupService.swift
//  TogetUp
//
//  Created by nayeon  on 4/20/24.
//

import Foundation
import RxSwift
import Moya

class GroupService {
    
    private let provider: MoyaProvider<GroupAPI>
    private let networkManager = NetworkManager()
    
    init(provider: MoyaProvider<GroupAPI> = MoyaProvider<GroupAPI>()) {
        self.provider = provider
    }
    
    func requestGroupAPI<T: Decodable>(api: GroupAPI, responseType: T.Type) -> Single<Result<T, NetWorkingError>> {
        switch api {
        case .getGroupList:
            let request = provider.rx.request(api)
            return networkManager.handleAPIRequest(request, dataType: T.self)
        case .createGroup:
            // CreateGroupResponse를 사용하는 요청에 대한 처리 추가
            let request = provider.rx.request(api)
            return networkManager.handleAPIRequest(request, dataType: T.self)
        }
    }
}

