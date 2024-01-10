//
//  GroupListViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/10/12.
//

import Foundation
import Moya
import RxSwift
import RxMoya

struct GroupListViewModel {
    private let provider = MoyaProvider<GroupService>()
    
    //    init() {
    //        self.provider = MoyaProvider<GroupService>(plugins: [NetworkLogger()])
    //    }
    
    func getGroupList() -> Observable<GroupListResponse> {
        return provider.rx.request(.getGroupList)
            .filterSuccessfulStatusCodes()
            .map(GroupListResponse.self)
            .asObservable()
    }
    
    func getGroupDetail(code: String) -> Observable<InviteDetailResponse> {
        return provider.rx.request(.getGroupDetailWithCode(code: code))
            .filterSuccessfulStatusCodes()
            .map(InviteDetailResponse.self)
            .asObservable()
    }
}
