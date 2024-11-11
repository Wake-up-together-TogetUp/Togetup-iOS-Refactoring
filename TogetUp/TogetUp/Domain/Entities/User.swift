//
//  User.swift
//  TogetUp
//
//  Created by 이예원 on 10/27/24.
//

import Foundation

struct User: Equatable {
    enum LoginMethod {
        case kakao
        case apple
    }

    let name: String
    let email: String
    let loginMethod: LoginMethod
}
