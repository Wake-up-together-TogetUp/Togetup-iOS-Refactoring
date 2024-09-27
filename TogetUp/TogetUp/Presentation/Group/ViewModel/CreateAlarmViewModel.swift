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
        let missionEndpoint: Observable<String>
        let missionKoreanName: Observable<String>
        let icon: Observable<String>
    }
    
    struct Output {
        let isCreateButtonEnabled: Observable<Bool>
        let createAlarmResponse: Observable<Result<CreateGroupResponse, NetWorkingError>>
    }
    
    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()
    private let realmManager = RealmAlarmDataManager()
    
    func transform(input: Input) -> Output {
        let isCreateButtonEnabled = Observable.combineLatest(
            input.alarmName,
            input.timeSelected,
            input.weekdaySelection,
            input.vibrationEnabled
        ).map { alarmName, _, weekdays, _ in
            !alarmName.isEmpty || weekdays.contains(true)
        }
        .startWith(false)
        
        let combinedInputs1 = Observable.combineLatest(
            input.alarmName.startWith(""),
            input.timeSelected.startWith(Date()),
            input.weekdaySelection.startWith([false, false, false, false, false, false, false]),
            input.vibrationEnabled.startWith(false)
        )
        
        let combinedInputs2 = Observable.combineLatest(
            input.groupName,
            input.groupIntro,
            input.missionId,
            input.missionObjectId.startWith(nil)
        )
        
        let combinedInputs3 = Observable.combineLatest(
            input.missionEndpoint.startWith(""),
            input.missionKoreanName.startWith(""),
            input.icon
        )
        
        let combinedInputs = Observable.combineLatest(
            combinedInputs1,
            combinedInputs2,
            combinedInputs3
        )
        
        let createAlarmResponse = input.createButtonTapped
            .withLatestFrom(combinedInputs)
            .flatMap { (inputs: (
                (alarmName: String, timeSelected: Date, weekdays: [Bool], vibrationEnabled: Bool),
                (groupName: String, groupIntro: String, missionId: Int, missionObjectId: Int?),
                (missionEndpoint: String, missionKoreanName: String, icon: String)
            )) -> Observable<Result<CreateGroupResponse, NetWorkingError>> in
                
                let (alarmName, timeSelected, weekdays, vibrationEnabled) = inputs.0
                let (groupName, groupIntro, missionId, missionObjectId) = inputs.1
                let (missionEndpoint, missionKoreanName, icon) = inputs.2
        
                let finalAlarmName = alarmName.isEmpty ? "알람" : alarmName
                let formattedTime = self.formatDate(date: timeSelected)
                
                let networkRequest = CreateGroupRequest(
                    name: groupName,
                    intro: groupIntro,
                    alarmCreateReq: GroupAlarmRequest(
                        name: finalAlarmName,
                        alarmTime: formattedTime,
                        monday: weekdays[1],
                        tuesday: weekdays[2],
                        wednesday: weekdays[3],
                        thursday: weekdays[4],
                        friday: weekdays[5],
                        saturday: weekdays[6],
                        sunday: weekdays[0],
                        isVibrate: vibrationEnabled,
                        missionId: missionId,
                        missionObjectId: missionObjectId ?? 1
                    )
                )
                
                let localRequest = CreateOrEditAlarmRequest(
                    missionId: missionId,
                    missionObjectId: missionObjectId,
                    name: finalAlarmName,
                    icon: icon,
                    isVibrate: vibrationEnabled,
                    alarmTime: formattedTime,
                    monday: weekdays[1],
                    tuesday: weekdays[2],
                    wednesday: weekdays[3],
                    thursday: weekdays[4],
                    friday: weekdays[5],
                    saturday: weekdays[6],
                    sunday: weekdays[0],
                    isActivated: true
                )
                
                return self.networkManager.handleAPIRequest(self.provider.rx.request(.createGroup(networkRequest)), dataType: CreateGroupResponse.self)
                    .asObservable()
                    .flatMap { result -> Observable<Result<CreateGroupResponse, NetWorkingError>> in
                        switch result {
                        case .success(let response):
                            let alarmId = response.result?.alarmId
                            let roomId = response.result?.roomId
                            self.realmManager.updateAlarm(with: localRequest, for: alarmId ?? 0, missionEndpoint: missionEndpoint, missionKoreanName: missionKoreanName, isPersonalAlarm: false, roomId: roomId)
                            AlarmScheduleManager.shared.scheduleNotification(for: alarmId ?? 0)
                            return .just(.success(response))
                        case .failure(let error):
                            return .just(.failure(error))
                        }
                    }
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
