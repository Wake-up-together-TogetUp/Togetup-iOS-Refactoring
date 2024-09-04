//
//  MoveToGroupPopUp.swift
//  TogetUp
//
//  Created by 이예원 on 9/2/24.
//

import UIKit
import SnapKit
import Then

class DialogTypeChoice: UIView {
    // MARK: Properties

    
    // MARK: - Callbacks
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
    
    // MARK: UIComponents
    private var titleLabel = UILabel().then {
        $0.font = .titleMedium
    }
    private var subtitleLabel = UILabel().then {
        $0.font = .bodyMedium
        $0.textColor = UIColor(named: "neutral800")
    }
    private var leftButton = UIButton().then {
        $0.setTitleColor(UIColor(named: "neutral700"), for: .normal)
        $0.titleLabel?.font = .buttonSmall
        $0.backgroundColor = UIColor(named: "neutral025")
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
    }
    private var rightButton = UIButton().then {
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
    init(title: String, subtitle: String, leftButtonTitle: String, rightButtonTitle: String, leftAction: @escaping () -> Void, rightAction: @escaping () -> Void) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.leftButton.setTitle(leftButtonTitle, for: .normal)
        self.rightButton.setTitle(rightButtonTitle, for: .normal)
        self.leftButtonAction = leftAction
        self.rightButtonAction = rightAction
        
        setUpBorderandBackground()
        setConstraints()
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
    
    func startCounting() {
        var counting = 5
        var timer: Timer?
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if counting > 0 {
                counting -= 1
                self.subtitleLabel.text = "\(counting)초후 자동으로 홈 이동"
            } else {
                timer?.invalidate()
                timer = nil
                leftButtonAction?()
            }
        }
    }
    
    @objc private func leftButtonTapped() {
        leftButtonAction?()
    }
    
    @objc private func rightButtonTapped() {
        rightButtonAction?()
    }
}
