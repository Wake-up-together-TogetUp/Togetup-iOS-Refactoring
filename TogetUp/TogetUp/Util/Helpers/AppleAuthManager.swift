//
//  AppleAuthManager.swift
//  TogetUp
//
//  Created by 이예원 on 10/28/24.
//

import AuthenticationServices
import RxSwift

class AppleAuthManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let authorizationSubject = PublishSubject<String?>()
    
    func performAuthorization() -> Observable<String?> {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
        return authorizationSubject.asObservable()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let authorizationCode = appleIDCredential.authorizationCode,
           let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) {
            authorizationSubject.onNext(authorizationCodeString)
        } else {
            authorizationSubject.onNext(nil)
        }
        authorizationSubject.onCompleted()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("애플 인증 실패:", error.localizedDescription)
        authorizationSubject.onNext(nil)
        authorizationSubject.onCompleted()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}
