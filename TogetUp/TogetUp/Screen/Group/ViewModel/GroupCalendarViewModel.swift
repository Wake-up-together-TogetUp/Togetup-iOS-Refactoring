//
//  GroupCalendarViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 6/20/24.
//

import RxSwift
import RxCocoa
import FSCalendar
import Moya

class GroupCalendarViewModel: ViewModelType {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let dateSelected: Observable<Date>
    }

    struct Output {
        let currentMonth: Driver<String>
        let selectedDateImages: Driver<[UserLog]>
    }
    
    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()
    private let currentMonthRelay = BehaviorRelay<String>(value: "")
    private let calendarScopeRelay = BehaviorRelay<FSCalendarScope>(value: .month)
    var selectedDateImagesRelay = BehaviorRelay<[UserLog]>(value: [])
    
    func transform(input: Input) -> Output {
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                self?.fetchData(for: Date())
            })
            .disposed(by: disposeBag)
        
        input.dateSelected
            .subscribe(onNext: { [weak self] date in
                self?.fetchData(for: date)
            })
            .disposed(by: disposeBag)
        
        return Output(
            currentMonth: currentMonthRelay.asDriver(),
            selectedDateImages: selectedDateImagesRelay.asDriver()
        )
    }
    
    private func fetchData(for date: Date) {
        let roomId = 1
        let localDate = formatDate(date)
        networkManager.handleAPIRequest(provider.rx.request(.getMissionLog(roomId: roomId, localDate: localDate)), dataType: GroupCalendarResponse.self)
            .subscribe(onSuccess: { [weak self] result in
                switch result {
                case .success(let response):
                    let userLogs = response.result.userLogList
                    self?.selectedDateImagesRelay.accept(userLogs)
                case .failure(let error):
                    let errorMessage = self?.networkManager.errorMessage(for: error)
                }
            }, onFailure: { error in
                let errorMessage = self.networkManager.errorMessage(for: error)
            })
            .disposed(by: disposeBag)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
