//
//  SettingViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit
import RxSwift
import KakaoSDKUser
import AuthenticationServices
import RealmSwift

class SettingViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var loginMethodImageView: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var withdrawlButton: UIButton!
    
    private let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()
    private let realmManger = RealmAlarmDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    private func customUI() {
        let userInfo = KeyChainManager.shared.getUserInformation()
        userNameLabel.text = userInfo.name
        userEmailLabel.text = userInfo.email
        
        if UserDefaults.standard.string(forKey: "loginMethod") == "Apple" {
            loginMethodImageView.image = UIImage(named: "Apple ID mini")
        }
        
        emptyView.layer.cornerRadius = 12
        emptyView.layer.borderWidth = 2
        emptyView.clipsToBounds = true
        
        logoutButton.layer.cornerRadius = 12
        withdrawlButton.layer.cornerRadius = 12
    }
    
    private func switchView() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func setUpUserDefaultsAndNavigate() {
        KeyChainManager.shared.removeToken()
        AppStatusManager.shared.markAsLoginedToFalse()
        self.realmManger.deleteAllDataFromRealm()
        AlarmScheduleManager.shared.removeAllScheduledNotifications()
        self.switchView()
    }
    
    @IBAction func logout(_ sender: Any) {
        let sheet = UIAlertController(title: "로그아웃", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            if UserDefaults.standard.string(forKey: "loginMethod") == "Kakao" {
                UserApi.shared.rx.logout()
                    .subscribe(onCompleted:{
                        self.setUpUserDefaultsAndNavigate()
                    }, onError: { error in
                        print(error.localizedDescription)
                    })
                    .disposed(by: self.disposeBag)
            } else {
                self.setUpUserDefaultsAndNavigate()
            }
        }
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
    
    @IBAction func withdrawl(_ sender: Any) {
        let sheet = UIAlertController(title: "회원 탈퇴", message: "탈퇴하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
            if UserDefaults.standard.string(forKey: "loginMethod") == "Kakao" {
                UserApi.shared.rx.unlink()
                    .subscribe(onCompleted: { [weak self] in
                        self?.viewModel.deleteUser()
                            .subscribe(onNext: { [weak self] response in
                                if response.httpStatusCode == 200 {
                                    self?.setUpUserDefaultsAndNavigate()
                                }
                            }, onError: { error in
                                print("Failed to delete user on our server:", error)
                            }).disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print(error.localizedDescription)
                    })
                    .disposed(by: self.disposeBag)
            } else {
                let provider = ASAuthorizationAppleIDProvider()
                let request = provider.createRequest()
                request.requestedScopes = [.fullName, .email]
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.presentationContextProvider = self
                controller.performRequests()
            }
        }
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let authorizationCode = appleIDCredential.authorizationCode
            let authorizationCodeString = String(data: authorizationCode!, encoding:.utf8)
            viewModel.deleteAppleUser(authorizationCode: authorizationCodeString!)
                .subscribe(onNext:{ [weak self] response in
                    if response.httpStatusCode == 200 {
                        self?.setUpUserDefaultsAndNavigate()
                    }
                }, onError:{ error in
                    print("Failed to delete user on our server:", error)
                })
                .disposed(by:disposeBag)
        }
    }
    
    func authorizationController(controller :ASAuthorizationController ,didCompleteWithError error :Error){
        print("Sign in with Apple errored:", error.localizedDescription )
    }
}

