//
//  PushNotificationViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 8/18/24.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class PushNotificationViewModel: ViewModelType {

    struct Input {
        let viewWillAppear: ControlEvent<Void>
        let deleteNotification: Observable<Int>
        let markAsRead: Observable<Int>
    }

    struct Output {
        let notifications: Driver<[NotificationList]>
        let error: Driver<Error>
    }

    private let provider = MoyaProvider<NotificationAPI>()
    private let notificationsSubject = BehaviorSubject<[NotificationList]>(value: [])
    private let errorSubject = PublishSubject<Error>()
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 초기 데이터 로드
        input.viewWillAppear
            .flatMap { [weak self] in
                self?.fetchNotifications() ?? .empty()
            }
            .bind(to: notificationsSubject)
            .disposed(by: disposeBag)
        
        // 삭제 작업
        input.deleteNotification
            .flatMap { [weak self] notificationId in
                self?.deleteNotification(notificationId: notificationId) ?? .empty()
            }
            .flatMap { [weak self] _ in
                self?.fetchNotifications() ?? .empty()
            }
            .bind(to: notificationsSubject)
            .disposed(by: disposeBag)
        
        // 읽음 표시 작업
        input.markAsRead
            .flatMap { [weak self] notificationId in
                self?.markNotificationAsRead(notificationId: notificationId) ?? .empty()
            }
            .flatMap { [weak self] _ in
                self?.fetchNotifications() ?? .empty()
            }
            .bind(to: notificationsSubject)
            .disposed(by: disposeBag)

        return Output(
            notifications: notificationsSubject.asDriver(onErrorDriveWith: .empty()),
            error: errorSubject.asDriver(onErrorDriveWith: .empty())
        )
    }

    private func deleteNotification(notificationId: Int) -> Observable<Void> {
        return provider.rx.request(.deleteNotification(notificationId: notificationId))
            .filterSuccessfulStatusCodes()
            .map { _ in }
            .asObservable()
            .catch { [weak self] error in
                self?.errorSubject.onNext(error)
                return Observable.never()
            }
    }
    
    private func markNotificationAsRead(notificationId: Int) -> Observable<Void> {
        return provider.rx.request(.patchNotification(notificationId: notificationId))
            .filterSuccessfulStatusCodes()
            .map { _ in }
            .asObservable()
            .catch { [weak self] error in
                self?.errorSubject.onNext(error)
                return Observable.never()
            }
    }

    private func fetchNotifications() -> Observable<[NotificationList]> {
        return provider.rx.request(.getNotification)
            .filterSuccessfulStatusCodes()
            .map(NotificationResponse.self)
            .map { $0.result.notificationListRes ?? [] }
            .asObservable()
            .catch { [weak self] error in
                self?.errorSubject.onNext(error)
                return Observable.never()
            }
    }
}
