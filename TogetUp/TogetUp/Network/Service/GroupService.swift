//
//  GroupService.swift
//  TogetUp
//
//  Created by nayeon  on 4/20/24.
//

import Foundation
import Moya
import RxSwift

class GroupService {
    
    private let provider: MoyaProvider<GroupAPI>
    private let networkManager = NetworkManager()
    
    init(provider: MoyaProvider<GroupAPI> = MoyaProvider<GroupAPI>()) {
        self.provider = provider
    }
    
    // 그룹 리스트 조회
    func getGroupList() -> Single<Result<GetGroupListResponse, NetWorkingError>> {
        let request = provider.rx.request(.getGroupList)
        return networkManager.handleAPIRequest(request, dataType: GetGroupListResponse.self)
    }
}

