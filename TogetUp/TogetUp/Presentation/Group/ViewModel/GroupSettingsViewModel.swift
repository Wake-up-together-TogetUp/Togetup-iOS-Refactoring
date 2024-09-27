//
//  GroupSettingsViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 8/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import UIKit

final class GroupSettingsViewModel: ViewModelType {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let inviteCodeButtonTapped: Observable<Void>
        let exitButtonTapped: Observable<Void>
    }
    
    struct Output {
        let groupInfo: Driver<GroupResultData>
        let didInviteCodeButtonTapped: Driver<String>
        let didExitButtonTapped: Signal<Bool>
    }
    
    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let realmManager = RealmAlarmDataManager()
    private let roomId: Int
    
    init(roomId: Int) {
        self.roomId = roomId
    }
    
    func transform(input: Input) -> Output {
        let groupInfo = input.viewDidLoad
            .flatMapLatest { [weak self] _ in
                guard let self = self else { return Observable<GroupResultData>.empty() }
                return provider.rx.request(.getGroupDetail(roomId: roomId))
                    .filterSuccessfulStatusCodes()
                    .do(onSuccess: { response in
                        if let json = try? JSONSerialization.jsonObject(with: response.data, options: []) {
                        } else {
                            print("응답 데이터를 JSON으로 변환할 수 없습니다.")
                        }
                    })
                    .map(GroupDetailResponse.self)
                    .asObservable()
                    .map { $0.result }
                    .catch { error in
                        print("네트워크 또는 디코딩 오류: \(error)")
                        return Observable.empty()
                    }
            }
            .asDriver(onErrorDriveWith: .empty())

        let showInviteCodeAlert = input.inviteCodeButtonTapped
            .withLatestFrom(groupInfo)
            .map { $0.roomData.invitationCode }
            .do(onNext: { code in
                UIPasteboard.general.string = code
            })
            .asDriver(onErrorDriveWith: .empty())
        
        let didExitButtonTapped = input.exitButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                return self.provider.rx.request(.deleteMember(roomId: self.roomId))
                    .filterSuccessfulStatusCodes()
                    .flatMap { _ -> Single<Bool> in
                        self.realmManager.deleteGroupAlarms(forRoomId: self.roomId)
                        return .just(true)
                    }
                    .asObservable()
                    .catchAndReturn(false)
            }
            .asSignal(onErrorJustReturn: false)
        
        let output = Output(
            groupInfo: groupInfo,
            didInviteCodeButtonTapped: showInviteCodeAlert,
            didExitButtonTapped: didExitButtonTapped
        )
        
        return output
    }
}
