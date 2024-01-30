//
//  AlarmNetworkManager.swift
//  TogetUp
//
//  Created by 이예원 on 1/22/24.
//

import Foundation
import RxSwift
import Moya

enum CreateAlarmError: Error {
    case network(MoyaError)
    case server(Int)
    case parsingError
    case timeout
    case authenticationError
    case noInternetConnection
}

class NetworkManager {
    func handleAPIRequest<T: Decodable>(_ request: Single<Response>, dataType: T.Type) -> Single<Result<T, CreateAlarmError>> {
        return request
            .do(onSuccess: { response in
                print("API Request \(response.request?.httpMethod?.description ?? "") succeeded with status code \(response.statusCode)")
            }, onError: { error in
                print("API Request Error: \(error.localizedDescription)")
            })
            .filterSuccessfulStatusAndRedirectCodes()
            .map(dataType)
            .map(Result.success)
            .catch { error -> Single<Result<T, CreateAlarmError>> in
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        return .just(.failure(.server(response.statusCode)))
                    case .underlying(let underlyingError, _):
                        if (underlyingError as NSError).code == NSURLErrorNotConnectedToInternet {
                            return .just(.failure(.noInternetConnection))
                        } else if (underlyingError as NSError).code == NSURLErrorTimedOut {
                            return .just(.failure(.timeout))
                        }
                        return .just(.failure(.network(moyaError)))
                    default:
                        return .just(.failure(.network(moyaError)))
                    }
                } else {
                    return .just(.failure(.parsingError))
                }
            }
    }
}

