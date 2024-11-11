//
//  UserRepository.swift
//  TogetUp
//
//  Created by 이예원 on 10/20/24.
//

import RxSwift
import Moya
import KakaoSDKUser
import RxKakaoSDKUser
import Foundation

protocol UserRepository {
    func fetchUserInfo() -> Observable<User>
    func logoutFromKakao() -> Observable<Bool>
    func deleteUserFromKakao() -> Observable<WithdrawlResponse>
    func logoutFromApple () -> Observable<Bool>
    func deleteUserFromApple() -> Observable<WithdrawlResponse>
}

class DefaultUserRepository: UserRepository {
    private let provider = MoyaProvider<UserAPI>()
    private let disposeBag = DisposeBag()
    private let appleAuthManager = AppleAuthManager()
    
    private func clearSessionData() {
        KeyChainManager.shared.removeToken()
        AppStatusManager.shared.markAsLoginedToFalse()
    }
    
    func fetchUserInfo() -> Observable<User> {
        return Observable.create { observer in
            let userInfo = KeyChainManager.shared.getUserInformation()
            let name = userInfo.name ?? " "
            let email = userInfo.email ?? " "
            
            let loginMethodString = UserDefaults.standard.string(forKey: "loginMethod") ?? "Kakao"
            let loginMethod: User.LoginMethod = loginMethodString == "Apple" ? .apple : .kakao
            
            let user = User(name: name, email: email, loginMethod: loginMethod)
            observer.onNext(user)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func logoutFromKakao() -> Observable<Bool> {
        return Observable.create { observer in
            UserApi.shared.rx.logout()
                .subscribe(onCompleted: {
                    observer.onNext(true)
                    observer.onCompleted()
                    self.clearSessionData()
                }, onError: { error in
                    print("카카오 로그아웃 실패: \(error)")
                    observer.onNext(false)
                    observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func deleteUserFromKakao() -> Observable<WithdrawlResponse> {
        return Observable.create { observer in
            UserApi.shared.rx.unlink()
                .andThen(
                    self.provider.rx.request(.deleteUser)
                        .filterSuccessfulStatusCodes()
                        .map(WithdrawlResponse.self)
                )
                .subscribe(onSuccess: { response in
                    observer.onNext(response)
                    observer.onCompleted()
                    self.clearSessionData()
                }, onFailure: { error in
                    print("카카오 탈퇴 실패: \(error)")
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func logoutFromApple() -> Observable<Bool> {
        return Observable.create { observer in
            self.clearSessionData()
            observer.onNext(true)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func deleteUserFromApple() -> Observable<WithdrawlResponse> {
        return appleAuthManager.performAuthorization()
            .flatMap { [unowned self] authorizationCode -> Observable<WithdrawlResponse> in
                guard let code = authorizationCode else {
                    return Observable.error(NSError(domain: "AppleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple 인증 실패"]))
                }
                return self.provider.rx.request(.deleteAppleUser(code: code))
                    .filterSuccessfulStatusCodes()
                    .map(WithdrawlResponse.self)
                    .asObservable()
            }
            .do(onNext: { [weak self] _ in
                self?.clearSessionData()
            })
    }
}
