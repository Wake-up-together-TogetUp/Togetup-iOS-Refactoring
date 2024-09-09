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
import Then
import SnapKit

class SettingViewController: UIViewController {
    private let titleLabel = UILabel().then {
        $0.text = "설정"
        $0.font = .titleMLarge
    }
    private let userNameLabel = UILabel().then {
        $0.font = .titleMedium
    }
    private let loginMethodImageView = UIImageView().then {
        $0.image = UIImage(named: "Kakao ID mini")
    }
    private let userEmailLabel = UILabel().then {
        $0.font = .labelLarge
    }
    private let emptyView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.clipsToBounds = true
        $0.backgroundColor = .white
    }
    private let alertConsentLabel = UILabel().then {
        $0.text = "알림 수신 동의"
        $0.font = .buttonMedium
    }
    private let alertConsentDescriptionLabel = UILabel().then {
        $0.text = "기기 설정 > 알림 > TogetUp!"
        $0.font = .labelLarge
        $0.textColor = UIColor(named: "neutral600")
    }
    private let personalInfoLabel = UILabel().then {
        $0.text = "개인정보처리방침"
        $0.font = .buttonMedium
    }
    private let personalInfoButton = UIButton().then {
        let image = UIImage(named: "right_thin")
        $0.setImage(image, for: .normal)
    }
    private let termsAndConditionLabel = UILabel().then {
        $0.font = .buttonMedium
        $0.text = "이용약관"
    }
    private let termsAndConditionsButton = UIButton().then {
        let image = UIImage(named: "right_thin")
        $0.setImage(image, for: .normal)
    }
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.distribution = .fillEqually
    }
    private let logoutButton = UIButton().then {
        $0.setTitle("로그아웃", for: .normal)
        $0.titleLabel?.font = .buttonSmall
        $0.setTitleColor(UIColor(named: "neutral400"), for: .normal)
        $0.backgroundColor = .clear
    }
    private let withdrawlButton = UIButton().then {
        $0.setTitle("서비스 탈퇴", for: .normal)
        $0.titleLabel?.font = .buttonSmall
        $0.setTitleColor(UIColor(named: "neutral400"), for: .normal)
        $0.backgroundColor = .clear
    }
    
    private let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()
    private let realmManger = RealmAlarmDataManager()
    private let personalnfoURL = "https://togetup.notion.site/TogetUp-47ab1dff223e403db68fbf90b8715b17"
    private let termsAndConditionsURL = "https://togetup.notion.site/33a5e6556541426b998423370b63397b"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupStackView()
        configureUserInfo()
        addTargets()
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(withdrawlButton)
    }
    
    private func configureUserInfo() {
        let userInfo = KeyChainManager.shared.getUserInformation()
        userNameLabel.text = userInfo.name
        userEmailLabel.text = userInfo.email
        
        if let loginMethod = UserDefaults.standard.string(forKey: "loginMethod"), loginMethod == "Apple" {
            loginMethodImageView.image = UIImage(named: "Apple ID mini")
        }
    }
    
    private func addTargets() {
        personalInfoButton.addTarget(self, action: #selector(moveToPersonalInfoPage), for: .touchUpInside)
        termsAndConditionsButton.addTarget(self, action: #selector(moveTotermsAndConditionsPage), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        withdrawlButton.addTarget(self, action: #selector(withdrawl), for: .touchUpInside)
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
    
    private func navigate(to url: String) {
        let vc = WebkitViewController()
        vc.urlString = url
        self.present(vc, animated: true)
    }
    
    @objc private func logout(_ sender: Any) {
        let sheet = UIAlertController(title: "로그아웃", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            if UserDefaults.standard.string(forKey: "loginMethod") == "Kakao" {
                UserApi.shared.rx.logout()
                    .subscribe(onCompleted:{
                        self?.setUpUserDefaultsAndNavigate()
                    }, onError: { error in
                        print(error.localizedDescription)
                    })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            } else {
                self?.setUpUserDefaultsAndNavigate()
            }
        }
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
    
    @objc private func withdrawl(_ sender: Any) {
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
    
    @objc private func moveToPersonalInfoPage(_ sender: UIButton) {
        navigate(to: personalnfoURL)
    }
    
    
    @objc private func moveTotermsAndConditionsPage(_ sender: UIButton) {
        navigate(to: termsAndConditionsURL)
    }
}

extension SettingViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller :ASAuthorizationController ,didCompleteWithError error :Error){
        print("Sign in with Apple errored:", error.localizedDescription )
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
}

extension SettingViewController {
    private func setupConstraints() {
        [titleLabel, userNameLabel, loginMethodImageView, userEmailLabel, emptyView, stackView].forEach {
            view.addSubview($0)
        }
        
        [alertConsentLabel, alertConsentDescriptionLabel, personalInfoLabel, personalInfoButton, termsAndConditionLabel, termsAndConditionsButton].forEach {
            emptyView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            make.left.equalToSuperview().offset(20)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(38)
        }
        
        loginMethodImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.left.equalTo(userNameLabel.snp.right).offset(8)
            make.centerY.equalTo(userNameLabel)
        }
        
        userEmailLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(loginMethodImageView.snp.right).offset(4)
            make.centerY.equalTo(loginMethodImageView)
        }
        
        emptyView.snp.makeConstraints { make in
            make.height.equalTo(160)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(userNameLabel.snp.bottom).offset(24)
        }
        
        alertConsentLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(20)
        }
        
        alertConsentDescriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(alertConsentLabel)
        }
        
        personalInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        
        personalInfoButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.right.equalTo(alertConsentDescriptionLabel.snp.right)
            make.centerY.equalTo(personalInfoLabel)
        }
        
        termsAndConditionLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        termsAndConditionsButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.right.equalTo(personalInfoButton.snp.right)
            make.centerY.equalTo(termsAndConditionLabel)
        }
        
        stackView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.width.equalTo(194)
            make.centerX.equalToSuperview()
        }
    }
}
