//
//  SettingViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit
import RxSwift
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
    private let loginMethodImageView = UIImageView()
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
    
    private let viewModel: SettingViewModel
    private let disposeBag = DisposeBag()
    private let realmManger = RealmAlarmDataManager()
    private let personalnfoURL = "https://togetup.notion.site/TogetUp-47ab1dff223e403db68fbf90b8715b17"
    private let termsAndConditionsURL = "https://togetup.notion.site/33a5e6556541426b998423370b63397b"
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = SettingViewModel(userUseCase: DefaultUserUseCase(userRepository: DefaultUserRepository()))
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupStackView()
        addTargets()
        bindViewModel()
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(withdrawlButton)
    }
    
    private func bindViewModel() {
        viewModel.userName
            .bind(to: userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userEmail
            .bind(to: userEmailLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.loginMethod
            .map { loginMethod -> UIImage? in
                switch loginMethod {
                case .apple:
                    return UIImage(named: "Apple ID mini")
                case .kakao:
                    return UIImage(named: "Kakao ID mini")
                }
            }
            .bind(to: loginMethodImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.isLoggedOut
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.switchView()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.userDeleted
            .subscribe(onNext: { [weak self] message in
                print("탈퇴 성공:", message)
                self?.switchView()
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] errorMessage in
                let alert = UIAlertController(title: "오류", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
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
    
    private func navigate(to url: String) {
        let vc = WebkitViewController()
        vc.urlString = url
        self.present(vc, animated: true)
    }
    
    @objc private func logout(_ sender: Any) {
        let sheet = UIAlertController(title: "로그아웃", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            if UserDefaults.standard.string(forKey: "loginMethod") == "Kakao" {
                self.viewModel.logout()
            }
        }
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
    
    @objc private func withdrawl(_ sender: Any) {
        let sheet = UIAlertController(title: "회원 탈퇴", message: "탈퇴하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
            self.viewModel.deleteUser()
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
