//
//  InviteViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 6/29/24.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class InviteViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: ControlEvent<Void>
        let tapBackButton: Signal<Void>
        let tapAcceptButton: Signal<Void>
    }

    struct Output {
        let groupInfo: Driver<GroupInfo>
        let didBackButtonTapped: Signal<Void>
        let didAcceptButtonTapped: Signal<Void>
    }

    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()
    private let invitationCode: String
    
    init(invitationCode: String) {
        self.invitationCode = invitationCode
    }
    
    func transform(input: Input) -> Output {
        let groupInfo = input.viewWillAppear
            .flatMapLatest { [weak self] _ in
                guard let self = self else { return Observable<GroupInfo>.empty() }
                return self.provider.rx.request(.getGroupDetailWithCode(invitationCode: self.invitationCode))
                    .asObservable()
                    .map(GroupResponse.self)
                    .map { $0.result }
            }
            .asDriver(onErrorDriveWith: .empty())

        let didBackButtonTapped = input.tapBackButton.asSignal()
        let didAcceptButtonTapped = input.tapAcceptButton.asSignal()

        return Output(groupInfo: groupInfo,
                      didBackButtonTapped: didBackButtonTapped,
                      didAcceptButtonTapped: didAcceptButtonTapped)
    }
}
