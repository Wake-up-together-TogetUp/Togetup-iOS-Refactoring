//
//  CreateAlarmViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 6/3/24.
//

import RxSwift
import RxCocoa
import Foundation
import Moya

class CreateAlarmViewModel: ViewModelType {
    struct Input {
        let alarmName: Observable<String>
        let timeSelected: Observable<Date>
        let weekdaySelection: Observable<[Bool]>
        let vibrationEnabled: Observable<Bool>
        let createButtonTapped: Observable<Void>
        let groupName: Observable<String>
        let groupIntro: Observable<String>
        let missionId: Observable<Int>
        let missionObjectId: Observable<Int?>
    }
    
    struct Output {
        let isCreateButtonEnabled: Observable<Bool>
        let createAlarmResponse: Observable<Result<CreateGroupResponse, NetWorkingError>>
    }
    
    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()
    
    func transform(input: Input) -> Output {
        let isCreateButtonEnabled = Observable.combineLatest(input.alarmName, input.timeSelected, input.weekdaySelection, input.vibrationEnabled)
            .map { alarmName, _, weekdays,_ in
                !alarmName.isEmpty || weekdays.contains(true)
            }
            .startWith(false)
        
        let combinedInputs = Observable.combineLatest(
            input.alarmName.startWith(""),
            input.timeSelected.startWith(Date()),
            input.weekdaySelection.startWith([false, false, false, false, false, false, false]),
            input.vibrationEnabled.startWith(false),
            input.groupName,
            input.groupIntro,
            input.missionId,
            input.missionObjectId
        )
        let createAlarmResponse = input.createButtonTapped
            .withLatestFrom(combinedInputs)
            .flatMapLatest { alarmName, timeSelected, weekdays,vibrationEnabled, groupName, groupIntro,missionId, missionObjectId   -> Observable<Result<CreateGroupResponse, NetWorkingError>> in
                let finalAlarmName = alarmName.isEmpty ? "알람" : alarmName
                let formattedTime = self.formatDate(date: timeSelected)
                let request = CreateGroupRequest(
                    name: groupName,
                    intro: groupIntro,
                    alarmCreateReq: GroupAlarmRequest(
                        name: finalAlarmName,
                        alarmTime: formattedTime,
                        monday: weekdays[0],
                        tuesday: weekdays[1],
                        wednesday: weekdays[2],
                        thursday: weekdays[3],
                        friday: weekdays[4],
                        saturday: weekdays[5],
                        sunday: weekdays[6],
                        isVibrate: vibrationEnabled,
                        missionId: missionId,
                        missionObjectId: missionObjectId
                    )
                )
                return self.networkManager.handleAPIRequest(self.provider.rx.request(.createGroup(request)), dataType: CreateGroupResponse.self)
                    .asObservable()
                    .map { $0 }
                    .catch { error in
                        let networkError = error as? NetWorkingError ?? .parsingError
                        return .just(.failure(networkError))
                    }
            }

        return Output(isCreateButtonEnabled: isCreateButtonEnabled, createAlarmResponse: createAlarmResponse)
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
