//
//  CreateGroupView.swift
//  TogetUp
//
//  Created by nayeon  on 3/26/24.
//

import UIKit
import SnapKit

class CreateGroupView: UIView {
    // MARK: - Properties
    let groupNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "그룹의 이름을 작성해주세요"
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    let groupNameLabel: UILabel = {
        let label = UILabel()
        label.text = "그룹명"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    let groupIntroLabel: UILabel = {
        let label = UILabel()
        label.text = "소개"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    let groupIntroTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 12)
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 10
        textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return textView
    }()
    
    let alarmSettingLabel: UILabel = {
        let label = UILabel()
        label.text = "미션"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
        return label
    }()
    
    let alarmSubLabel: UILabel = {
       let label = UILabel()
        label.text = "그룹 참여자가 수행할 미션을 선택해주세요"
        label.textColor = .lightGray
        return label
    }()
    
    let addAlarmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "secondary025")
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "미션 내용"
        return label
    }()
    

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(groupNameTextField)
        addSubview(groupNameLabel)
        addSubview(groupIntroTextView)
        addSubview(groupIntroLabel)
        addSubview(alarmSubLabel)
        addSubview(alarmSettingLabel)
        addSubview(addAlarmButton)
        addAlarmButton.addSubview(iconImageView)
        addAlarmButton.addSubview(textLabel)
    
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        groupNameTextField.translatesAutoresizingMaskIntoConstraints = false
        groupIntroLabel.translatesAutoresizingMaskIntoConstraints = false
        groupIntroTextView.translatesAutoresizingMaskIntoConstraints = false
        alarmSubLabel.translatesAutoresizingMaskIntoConstraints = false

        groupNameLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(self.snp.leading).offset(37)
            make.width.equalTo(groupNameLabel.intrinsicContentSize.width + 15)
        }

        groupNameTextField.snp.makeConstraints { make in
            make.top.equalTo(groupNameLabel.snp.bottom).offset(-10)
            make.leading.equalTo(self.snp.leading).offset(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
            make.height.equalTo(54)
        }

        groupIntroLabel.snp.makeConstraints { make in
            make.top.equalTo(groupNameTextField.snp.bottom).offset(25)
            make.leading.equalTo(self.snp.leading).offset(37)
            make.width.equalTo(groupIntroLabel.intrinsicContentSize.width + 15)
        }

        groupIntroTextView.snp.makeConstraints { make in
            make.top.equalTo(groupIntroLabel.snp.bottom).offset(-10)
            make.leading.equalTo(self.snp.leading).offset(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
        }
        
        alarmSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(groupIntroTextView.snp.bottom).offset(20)
            make.leading.equalTo(self.snp.leading).offset(20)
        }
        
        alarmSubLabel.snp.makeConstraints { make in
            make.top.equalTo(alarmSettingLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.snp.leading).offset(20)
        }
        
        addAlarmButton.snp.makeConstraints { make in
            make.top.equalTo(alarmSubLabel.snp.bottom).offset(20)
            make.leading.equalTo(self.snp.leading).offset(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
            make.height.equalTo(82)
        }

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.width.height.equalTo(60)
        }

        textLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
    }
}
