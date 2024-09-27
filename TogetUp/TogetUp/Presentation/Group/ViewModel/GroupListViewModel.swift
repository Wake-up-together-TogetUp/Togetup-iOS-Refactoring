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
        let okButtonTap: Signal<Void>
        let invitationCode: Signal<String>
    }
    
    struct Output {
        let groupList: Driver<[GroupResult]>
        let error: Driver<String>
        let didOkButtonTapped: Signal<Bool>
    }
    
    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()
    
    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<String>()
        let changeAlertColorSubject = PublishSubject<Bool>()
        
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
        
        let didOkButtonTapped = input.okButtonTap
            .withLatestFrom(input.invitationCode)
            .flatMapLatest { [unowned self] code -> Signal<Bool> in
                return self.validateInvitationCode(code)
            }
        
        let error = errorSubject.asDriver(onErrorJustReturn: "알 수 없는 에러가 발생했습니다.")
        return Output(groupList: groupListResult,
                      error: error,
                      didOkButtonTapped: didOkButtonTapped)
    }
    
    private func validateInvitationCode(_ code: String) -> Signal<Bool> {
        guard !code.isEmpty else {
            return .just(false)
        }
        
        let request = self.provider.rx.request(.getGroupDetailWithCode(invitationCode: code))
        return self.networkManager.handleAPIRequest(request, dataType: GroupResponse.self)
            .map { result -> Bool in
                switch result {
                case .success:
                    return true
                case .failure:
                    return false
                }
            }
            .asSignal(onErrorJustReturn: false)
    }
}
