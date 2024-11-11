//
//  SettingViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/03.
//

import RxSwift
import RxCocoa

class SettingViewModel {
    private let userUseCase: UserUseCase
    private let disposeBag = DisposeBag()
    
    let isLoggedOut = PublishSubject<Bool>()
    let userDeleted = PublishSubject<String>()
    let errorMessage = PublishSubject<String>()
    
    let userName = BehaviorRelay<String>(value: "")
    let userEmail = BehaviorRelay<String>(value: "")
    let loginMethod = BehaviorRelay<User.LoginMethod>(value: .kakao)
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
        fetchUserInfo()
    }
    
    private func fetchUserInfo() {
        userUseCase.fetchUserInfo()
            .subscribe(onNext: { [weak self] user in
                self?.userName.accept(user.name)
                self?.userEmail.accept(user.email)
                self?.loginMethod.accept(user.loginMethod)
            })
            .disposed(by: disposeBag)
    }
    
    func logout() {
        userUseCase.logout()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.isLoggedOut.onNext(true)
                } else {
                    self?.errorMessage.onNext("로그아웃 실패")
                }
            }, onError: { [weak self] error in
                self?.errorMessage.onNext("로그아웃 중 오류 발생: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func deleteUser() {
        userUseCase.deleteUser()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                self?.userDeleted.onNext(response.message)
            }, onError: { [weak self] error in
                self?.errorMessage.onNext("회원 탈퇴 중 오류 발생: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
