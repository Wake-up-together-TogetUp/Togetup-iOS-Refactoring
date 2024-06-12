//
//  CreateAlarmView.swift
//  TogetUp
//
//  Created by nayeon  on 3/26/24.
//

import UIKit
import RxSwift
import RxCocoa

class CreateAlarmView: UIView {
    
    private let disposeBag = DisposeBag()
    var vibrationToggle = UISwitch()
    
    lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.backgroundColor = UIColor.white
        
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        return picker
    }()
    
    private let topLabel: UIButton = {
        let button = UIButton()
        button.setTitle("미션을 언제 진행하고 싶으신가요?", for: .normal)
        button.setTitleColor(UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1), for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(named: "neutral050")
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 2
        return view
    }()
    
    private let weekdayButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let alarmNameLabel: UILabel = {
        let label = UILabel()
        label.text = "알람명"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return label
    }()
    
    private let vibrationLabel: UILabel = {
        let label = UILabel()
        label.text = "진동"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return label
    }()
    
    var alarmNameTextField: UITextField = {
        let alarmNameTextField = UITextField()
        alarmNameTextField.placeholder = "알람"
        alarmNameTextField.borderStyle = .roundedRect
        alarmNameTextField.borderStyle = .none
        alarmNameTextField.textAlignment = .right
        return alarmNameTextField
    }()
    
    let openedButton: UIButton = {
       let button = UIButton()
        button.setTitle("개설하기", for: .normal)
        button.backgroundColor = UIColor(named: "primary400")
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return button
    }()
    
    var weekdayButtons: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .white
        addSubview(topLabel)
        addSubview(timePicker)
        addSubview(containerView)
        containerView.addSubview(weekdayButtonsStackView)
        containerView.addSubview(alarmNameLabel)
        containerView.addSubview(vibrationLabel)
        containerView.addSubview(alarmNameTextField)
        containerView.addSubview(vibrationToggle)
        containerView.addSubview(openedButton)
        
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        topLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        timePicker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(topLabel.snp.bottom).offset(15)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(timePicker.snp.bottom).offset(20)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(20)
        }
            
        weekdayButtonsStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
        }
        
        alarmNameLabel.snp.makeConstraints {
            $0.top.equalTo(weekdayButtonsStackView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            
        }
        
        alarmNameTextField.snp.makeConstraints {
            $0.centerY.equalTo(alarmNameLabel.snp.centerY)
            $0.leading.equalTo(alarmNameLabel.snp.trailing).offset(10)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
        }
        
        vibrationLabel.snp.makeConstraints {
            $0.top.equalTo(alarmNameLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        vibrationToggle.snp.makeConstraints {
            $0.centerY.equalTo(vibrationLabel.snp.centerY)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
        }
        
        openedButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-50)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
            $0.height.equalTo(56)
        }
        setupWeekdayButtons()
    }
    
    private func setupWeekdayButtons() {
        let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        for (index, weekday) in weekdays.enumerated() {
            let button = UIButton()
            button.setTitle(weekday, for: .normal)
            button.backgroundColor = UIColor(named: "neutral050")
            button.setTitleColor(UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1), for: .normal)
            button.layer.cornerRadius = 17
            button.tag = index
            button.addTarget(self, action: #selector(weekdayButtonTapped(_:)), for: .touchUpInside)
            weekdayButtonsStackView.addArrangedSubview(button)
            button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            weekdayButtons.append(button)
        }
        weekdayButtonsStackView.spacing = 12
    }
    
    @objc private func weekdayButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor(named: "primary400") : UIColor(named: "neutral050")
        sender.setTitleColor(sender.isSelected ? .white : UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1), for: .normal)
    }
}
