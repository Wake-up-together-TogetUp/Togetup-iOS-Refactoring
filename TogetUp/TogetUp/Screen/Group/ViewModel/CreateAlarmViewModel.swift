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
                    name: "테스트입니다.",
                    intro: "테스트중임",
                    alarmCreateReq: GroupAlarmRequest(
                        name: "테스트입니다",
                        alarmTime: "16:00",
                        monday: weekdays[0],
                        tuesday: weekdays[1],
                        wednesday: weekdays[2],
                        thursday: weekdays[3],
                        friday: weekdays[4],
                        saturday: weekdays[5],
                        sunday: weekdays[6],
                        isVibrate: true,
                        missionId: 2,
                        missionObjectId: 1
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
