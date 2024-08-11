//
//  GroupJoinAlarmViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 7/25/24.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class GroupJoinAlarmViewModel: ViewModelType {
    struct Input {
        let alarmName: Observable<String>
        let timeSelected: Observable<Date>
        let weekdaySelection: Observable<[Bool]>
        let vibrationEnabled: Observable<Bool>
        let joinButtonTapped: Observable<Void>
        let roomId: Int
        let missionId: Int
        let missionObjectId: Int
    }
    
    struct Output {
        let isJoinButtonEnabled: Observable<Bool>
        let joinGroupResponse: Observable<Result<GroupAlarmRequest, NetWorkingError>>
    }
    
    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()
    
    func transform(input: Input) -> Output {
        let isJoinButtonEnabled = Observable.combineLatest(input.alarmName, input.weekdaySelection)
            .map { alarmName, weekdays in
                !alarmName.isEmpty && weekdays.contains(true)
            }
            .startWith(false)
        
        let combinedInputs = Observable.combineLatest(
            input.alarmName.startWith(""),
            input.timeSelected.startWith(Date()),
            input.weekdaySelection.startWith([false, false, false, false, false, false, false]),
            input.vibrationEnabled.startWith(false)
        )

        let joinGroupResponse = input.joinButtonTapped
            .withLatestFrom(combinedInputs)
            .flatMapLatest { alarmName, timeSelected, weekdays, vibrationEnabled -> Observable<Result<GroupAlarmRequest, NetWorkingError>> in
                let finalAlarmName = alarmName.isEmpty ? "알람" : alarmName
                let formattedTime = self.formatDate(date: timeSelected)
                let request = GroupAlarmRequest(
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
                    missionId: input.missionId,
                    missionObjectId: input.missionObjectId
                )
                return self.networkManager.handleAPIRequest(self.provider.rx.request(.joinGroup(roomId: input.roomId, request: request)), dataType: GroupAlarmRequest.self)
                    .asObservable()
                    .do(onNext: { response in
                        print("Response data: \(response)")
                    })
                    .map { $0 }
                    .catch { error in
                        print("Error: \(error.localizedDescription)")
                        return .just(.failure(error as? NetWorkingError ?? .parsingError))
                    }
            }
        
        return Output(isJoinButtonEnabled: isJoinButtonEnabled, joinGroupResponse: joinGroupResponse)
        
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
