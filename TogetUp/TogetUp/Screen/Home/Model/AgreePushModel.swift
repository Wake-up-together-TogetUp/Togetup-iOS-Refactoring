//
//  AgreePushModel.swift
//  TogetUp
//
//  Created by 이예원 on 9/4/24.
//

import Foundation

struct AgreePushModel: Codable {
    let httpStatusCode: Int
    let httpReasonPhrase: String
    let message: String
}
