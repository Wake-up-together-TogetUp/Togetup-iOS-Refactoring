//
//  DefaultUserUseCase.swift
//  TogetUp
//
//  Created by 이예원 on 10/28/24.
//

import RxSwift

protocol UserUseCase {
    func fetchUserInfo() -> Observable<User>
    func logout() -> Observable<Bool>
    func deleteUser() -> Observable<WithdrawlResponse>
}

class DefaultUserUseCase: UserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func fetchUserInfo() -> Observable<User> {
        return userRepository.fetchUserInfo()
    }
    
    func logout() -> Observable<Bool> {
        return userRepository.fetchUserInfo()
            .flatMap { user in
                if user.loginMethod == .kakao {
                    return self.userRepository.logoutFromKakao()
                } else {
                    return self.userRepository.logoutFromApple()
                }
            }
    }
    
    func deleteUser() -> Observable<WithdrawlResponse> {
        return userRepository.fetchUserInfo()
            .flatMap { user in
                if user.loginMethod == .kakao {
                    return self.userRepository.deleteUserFromKakao()
                } else {
                    return self.userRepository.deleteUserFromApple()
                }
            }
    }
}


