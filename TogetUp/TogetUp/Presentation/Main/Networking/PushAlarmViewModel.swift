//
//  PushAlarmViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 11/20/23.
//

import Foundation
import RxSwift
import RxMoya
import Moya

class PushAlarmViewModel {
    private let provider = MoyaProvider<UserService>()
    
    func sendFcmToken(token: String) -> Observable<PushAlarmResponse> {
        return provider.rx.request(.sendFcmToken(fcmToken: token))
            .filterSuccessfulStatusCodes()
            .map(PushAlarmResponse.self)
            .asObservable()
    }
    
    func sendPushAgreement(agree: Bool) {
        provider.rx.request(.agreePush(agree: agree))
            .filterSuccessfulStatusCodes()
            .subscribe(onSuccess: { response in
                print(response)
            }, onFailure: { error in
                print(error.localizedDescription)
            })
    }
}
