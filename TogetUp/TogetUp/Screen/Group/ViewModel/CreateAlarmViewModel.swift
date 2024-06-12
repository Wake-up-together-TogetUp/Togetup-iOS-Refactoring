//
//  CreateAlarmViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 6/3/24.
//

import RxSwift
import RxCocoa
import Foundation

class CreateAlarmViewModel: ViewModelType {
    struct Input {
        let alarmName: Observable<String>
        let timeSelected: Observable<Date>
        let weekdaySelection: Observable<[Bool]>
        let vibrationEnabled: Observable<Bool>
        let createButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isCreateButtonEnabled: Observable<Bool>
        let createAlarmResponse: Observable<Result<CreateGroupResponse, NetWorkingError>>
    }
    
    private let groupService = GroupService()
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let isCreateButtonEnabled = Observable.combineLatest(input.alarmName, input.timeSelected, input.weekdaySelection)
            .map { _ in true }
            .startWith(true)
        
        let createAlarmResponse = input.createButtonTapped
            .withLatestFrom(input.weekdaySelection)
            .flatMapLatest { weekdays -> Observable<Result<CreateGroupResponse, NetWorkingError>> in
                let request = CreateGroupRequest(
                    name: "",
                    intro: "",
                    postAlarmReq: GroupAlarmRequest(
                        name: "",
                        icon: "alarm",
                        snoozeInterval: 10,
                        snoozeCnt: 3,
                        alarmTime: "3",
                        monday: weekdays[0],
                        tuesday: weekdays[1],
                        wednesday: weekdays[2],
                        thursday: weekdays[3],
                        friday: weekdays[4],
                        saturday: weekdays[5],
                        sunday: weekdays[6],
                        isSnoozeActivated: true,
                        isVibrate: true,
                        missionId: 1,
                        missionObjectId: nil,
                        roomId: nil
                    )
                )
                return self.groupService.requestGroupAPI(api: .createGroup(request), responseType: CreateGroupResponse.self)
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
