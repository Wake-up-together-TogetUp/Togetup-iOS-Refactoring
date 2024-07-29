//
//  GroupListViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 5/20/24.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class GroupViewModel: ViewModelType {

    struct Input {
        let fetchGroupList: PublishSubject<Void>
    }

    struct Output {
        let groupList: Driver<[GroupResult]>
        let error: Driver<String>
    }

    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()

    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<String>()
        let request = provider.rx.request(.getGroupList)
        let groupList = input.fetchGroupList
            .flatMapLatest { [unowned self] in
                self.networkManager.handleAPIRequest(request, dataType: GetGroupListResponse.self)
                    .asObservable()
                    .materialize()
            }
            .share()

        let groupListResult = groupList
            .compactMap { event -> [GroupResult]? in
                switch event {
                case .next(let result):
                    switch result {
                    case .success(let response):
                        return response.result
                    case .failure(let error):
                        errorSubject.onNext(self.networkManager.errorMessage(for: error))
                        return nil
                    }
                case .error(let error):
                    errorSubject.onNext(self.networkManager.errorMessage(for: error))
                    return nil
                case .completed:
                    return nil
                }
            }
            .asDriver(onErrorJustReturn: [])

        let error = errorSubject.asDriver(onErrorJustReturn: "알 수 없는 에러가 발생했습니다.")
        return Output(groupList: groupListResult, error: error)
    }
}
