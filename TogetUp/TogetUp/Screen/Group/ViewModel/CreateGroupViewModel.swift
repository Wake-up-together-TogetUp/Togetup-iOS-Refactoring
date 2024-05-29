//
//  CreateGroupViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 3/26/24.
//

import Foundation
import RxSwift
import RxCocoa

class CreateGroupViewModel: ViewModelType {

    struct Input {
        let didGroupNameTextFieldChange: Observable<String>
        let didExplanationTextViewChange: Observable<String>
        let tapMissionButton: Signal<Void>
        let tapCompleteButton: Signal<Void>
        let tapCancleButton: Signal<Void>
    }

    struct Output {
        let didCancleButtonTapped: Signal<Void>
        let didCompleteButtonTapped: Signal<Void>
        let groupName: BehaviorRelay<String>
        let groupIntro: BehaviorRelay<String>
        let error: Driver<String>
    }

    var disposeBag = DisposeBag()

    private let groupService: GroupService

    init(groupService: GroupService) {
        self.groupService = groupService
    }

    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<String>()
        let groupNameRelay = BehaviorRelay<String>(value: "")
        let explanationRelay = BehaviorRelay<String>(value: "")

        input.didGroupNameTextFieldChange
            .bind(to: groupNameRelay)
            .disposed(by: disposeBag)

        input.didExplanationTextViewChange
            .bind(to: explanationRelay)
            .disposed(by: disposeBag)

        let combinedInput = Observable.combineLatest(groupNameRelay, explanationRelay)

        let createGroupResult = input.tapCompleteButton
            .withLatestFrom(combinedInput.asSignal(onErrorJustReturn: ("", "")))
            .flatMapLatest { [unowned self] groupName, explanation -> Signal<Result<CreateGroupResponse, NetWorkingError>> in
                let param = CreateGroupRequest(
                    name: groupName,
                    intro: explanation,
                    postAlarmReq: GroupAlarmRequest(
                        name: "Default Alarm",
                        icon: "⏰",
                        snoozeInterval: 5,
                        snoozeCnt: 3,
                        alarmTime: "08:00",
                        monday: true,
                        tuesday: true,
                        wednesday: true,
                        thursday: true,
                        friday: true,
                        saturday: false,
                        sunday: false,
                        isSnoozeActivated: true,
                        isVibrate: true,
                        missionId: 1,
                        missionObjectId: nil,
                        roomId: nil
                    )
                )
                return self.groupService.requestGroupAPI(api: .createGroup(param), responseType: CreateGroupResponse.self)
                    .asSignal(onErrorJustReturn: .failure(.network(.underlying(NSError(domain: "", code: -1, userInfo: nil), nil))))
            }

        createGroupResult
            .emit(onNext: { result in
                switch result {
                case .success(let response):
                    print("Group created successfully: \(response)")
                case .failure(let error):
                    errorSubject.onNext(self.networkManager.errorMessage(for: error))
                }
            })
            .disposed(by: disposeBag)

        let error = errorSubject.asDriver(onErrorJustReturn: "알 수 없는 에러가 발생했습니다.")
        let didCompleteButtonTapped = input.tapCompleteButton
        let didCancleButtonTapped = input.tapCancleButton

        return Output(
            didCancleButtonTapped: didCancleButtonTapped,
            didCompleteButtonTapped: didCompleteButtonTapped,
            groupName: groupNameRelay,
            groupIntro: explanationRelay,
            error: error
        )
    }

    private var networkManager: NetworkManager {
        return NetworkManager()
    }
}
