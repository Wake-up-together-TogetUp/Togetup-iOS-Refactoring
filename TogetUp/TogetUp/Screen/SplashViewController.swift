//
//  SplashViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/14.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import AuthenticationServices
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser
import KakaoSDKCommon

class SplashViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.isLoggedIn {
                    self.checkLoginMethodAndNavigate()
            } else {
                    self.navigateToLoginScreen()
            }
        }
    }
    
    private func checkLoginMethodAndNavigate() {
        if UserDefaults.standard.string(forKey: "loginMethod") == "Apple" {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: KeyChainManager.shared.getUserIdentifier()!) { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    self.navigateToMainScreen()
                case .revoked, .notFound:
                    self.navigateToLoginScreen()
                default:
                    print(error?.localizedDescription as Any)
                }
            }
        } else if UserDefaults.standard.string(forKey: "loginMethod") == "Kakao" {
            if (AuthApi.hasToken()) {
                UserApi.shared.rx.accessTokenInfo()
                    .subscribe(onSuccess:{ (_) in
                        self.navigateToMainScreen()
                    }, onFailure: {error in
                        if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                            self.navigateToLoginScreen()
                        } else {
                            print(error.localizedDescription)
                        }
                    })
                    .disposed(by: disposeBag)
            } else {
                navigateToLoginScreen()
            }
        }
    }
    
    private func navigateToMainScreen() {
        DispatchQueue.main.async {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else {
                return
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    private func navigateToLoginScreen() {
        DispatchQueue.main.async {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else {
                return
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}

