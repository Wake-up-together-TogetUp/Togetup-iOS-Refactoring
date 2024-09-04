//
//  MoveToGroupPopUp.swift
//  TogetUp
//
//  Created by 이예원 on 9/2/24.
//

import UIKit
import SnapKit
import Then

class MoveToGroupPopUpView: UIView {
    // MARK: Properties
    var counting = 5
    private var timer: Timer?
    
    // MARK: - Callbacks
    var leftButtonAction: (() -> Void)?
    var rightButtonActoin: (() -> Void)?
    
    // MARK: UIComponents
    private var titleLabel = UILabel().then {
        $0.text = "그룹 게시판 업로드 완료"
        $0.font = .titleMedium
    }
    private var subtitleLabel = UILabel().then {
        $0.font = .bodyMedium
        $0.textColor = UIColor(named: "neutral800")
    }
    private var leftButton = UIButton().then {
        $0.setTitle("홈으로 이동", for: .normal)
        $0.setTitleColor(UIColor(named: "neutral700"), for: .normal)
        $0.titleLabel?.font = .buttonSmall
        $0.backgroundColor = UIColor(named: "neutral025")
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
    }
    private var rightButton = UIButton().then {
        $0.setTitle("보러가기", for: .normal)
        $0.tintColor = .white
        $0.titleLabel?.font = .buttonSmall
        $0.backgroundColor = UIColor(named: "primary400")
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
    }
    private lazy var stackView = UIStackView(arrangedSubviews: [leftButton, rightButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBorderandBackground()
        setConstraints()
        startCounting()
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpBorderandBackground() {
        self.backgroundColor = UIColor(named: "neutral025")
        self.layer.cornerRadius = 16
        self.layer.borderWidth = 2
    }
    
    private func addTargets() {
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }
    
    private func setConstraints() {
        [titleLabel, subtitleLabel, stackView].forEach {
            self.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(22)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        
        stackView.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.width.equalTo(238)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func startCounting() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.counting > 0 {
                self.counting -= 1
                self.subtitleLabel.text = "\(self.counting)초후 자동으로 홈 이동"
            } else {
                self.timer?.invalidate()
                self.timer = nil
                leftButtonAction?()
            }
        }
    }
    
    @objc private func leftButtonTapped() {
        leftButtonAction?()
    }
    
    @objc private func rightButtonTapped() {
        rightButtonActoin?()
    }
}
