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
        let selectedDateImages: Driver<[UserLog]>
        let groupName: Driver<String>
        let theme: Driver<String>
    }
    
    var disposeBag = DisposeBag()
    private let provider = MoyaProvider<GroupAPI>()
    private let networkManager = NetworkManager()
    private let calendarScopeRelay = BehaviorRelay<FSCalendarScope>(value: .month)
    var selectedDateImagesRelay = BehaviorRelay<[UserLog]>(value: [])
    private let groupNameRelay = BehaviorRelay<String>(value: "")
    private let themeRelay = BehaviorRelay<String>(value: "")
    private let roomId: Int
    
    init(roomId: Int) {
        self.roomId = roomId
    }
    
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
            selectedDateImages: selectedDateImagesRelay.asDriver(),
            groupName: groupNameRelay.asDriver(),
            theme: themeRelay.asDriver()
        )
    }
    
    private func fetchData(for date: Date) {
        let localDate = formatDate(date)
        networkManager.handleAPIRequest(provider.rx.request(.getMissionLog(roomId: roomId, localDate: localDate)), dataType: GroupCalendarResponse.self)
            .subscribe(onSuccess: { [weak self] result in
                switch result {
                case .success(let response):
                    let userLogs = response.result.userLogList
                    let roomName = response.result.name
                    let theme = response.result.theme
                    self?.selectedDateImagesRelay.accept(userLogs)
                    self?.groupNameRelay.accept(roomName)
                    self?.themeRelay.accept(theme)
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
