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
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        return button
    }()
    
    let groupTitle: UILabel = {
        let label = UILabel()
        label.text = "그룹 생성"
        label.font = UIFont(name: "AppleSDGothicNeo-ExtraBold", size: 18)
        label.textAlignment = .center
        return label
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        return button
    }()
    
    let groupNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "그룹의 이름을 작성해주세요"
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 10
        textField.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
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
    
    let groupNameCountLabel = UILabel().then {
        $0.text = "0/10"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        $0.textColor = UIColor(named: "neutral500")
    }
    
    let groupIntroLabel: UILabel = {
        let label = UILabel()
        label.text = "소개"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    let groupIntroCountLabel = UILabel().then {
        $0.text = "0/30"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        $0.textColor = UIColor(named: "neutral500")
    }
    
    let groupIntroTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 12)
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 10
        textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return textView
    }()
    
    let missionSettingLabel: UILabel = {
        let label = UILabel()
        label.text = "미션"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
        return label
    }()
    
    private let missionSubLabel = UILabel().then {
        $0.text = "그룹 참여자가 수행할 미션을 선택해주세요"
        $0.textColor = UIColor(named: "neutral500")
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    }
    
    let addMissionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "secondary025")
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return button
    }()
    
    let circleView: UIView = {
        let circleView = UIView()
        circleView.backgroundColor = UIColor.white
        circleView.layer.cornerRadius = 30
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1).cgColor
        return circleView
    }()
    
    var missionImageLabel: UILabel = {
        let img = UILabel()
        img.text = "👤"
        img.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 36)
        return img
    }()
    
    var missionTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.text = "사람"
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
        addSubview(groupTitle)
        addSubview(cancelButton)
        addSubview(nextButton)
        addSubview(groupNameTextField)
        addSubview(groupNameLabel)
        groupNameTextField.addSubview(groupNameCountLabel)
        addSubview(groupIntroTextView)
        addSubview(groupIntroCountLabel)
        addSubview(groupIntroLabel)
        addSubview(missionSubLabel)
        addSubview(missionSettingLabel)
        addSubview(addMissionButton)
        addMissionButton.addSubview(circleView)
        addMissionButton.addSubview(missionTextLabel)
        circleView.addSubview(missionImageLabel)
    
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        groupNameTextField.translatesAutoresizingMaskIntoConstraints = false
        groupIntroLabel.translatesAutoresizingMaskIntoConstraints = false
        groupIntroTextView.translatesAutoresizingMaskIntoConstraints = false
        missionSubLabel.translatesAutoresizingMaskIntoConstraints = false
        
        groupTitle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(groupTitle)
            make.leading.equalTo(self.snp.leading).offset(10)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(groupTitle)
            make.trailing.equalTo(self.snp.trailing).offset(-10)
        }

        groupNameLabel.snp.makeConstraints { make in
            make.top.equalTo(groupTitle.snp.bottom).offset(20)
            make.leading.equalTo(self.snp.leading).offset(37)
            make.width.equalTo(groupNameLabel.intrinsicContentSize.width + 15)
        }

        groupNameTextField.snp.makeConstraints {
            $0.top.equalTo(groupNameLabel.snp.bottom).offset(-10)
            $0.leading.equalTo(self.snp.leading).offset(20)
            $0.trailing.equalTo(self.snp.trailing).offset(-20)
            $0.height.equalTo(54)
        }
        
        groupNameCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(groupNameTextField.snp.centerY)
            $0.trailing.equalTo(groupNameTextField.snp.trailing).offset(-20)
        }


        groupIntroLabel.snp.makeConstraints {
            $0.top.equalTo(groupNameTextField.snp.bottom).offset(25)
            $0.leading.equalTo(self.snp.leading).offset(37)
            $0.width.equalTo(groupIntroLabel.intrinsicContentSize.width + 15)
        }
        
        groupIntroCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(groupIntroTextView.snp.bottom).offset(-16)
            $0.trailing.equalTo(groupIntroTextView.snp.trailing).offset(-20)
        }

        groupIntroTextView.snp.makeConstraints { make in
            make.top.equalTo(groupIntroLabel.snp.bottom).offset(-10)
            make.leading.equalTo(self.snp.leading).offset(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
        }
        
        missionSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(groupIntroTextView.snp.bottom).offset(20)
            make.leading.equalTo(self.snp.leading).offset(20)
        }
        
        missionSubLabel.snp.makeConstraints { make in
            make.top.equalTo(missionSettingLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.snp.leading).offset(20)
        }
        
        addMissionButton.snp.makeConstraints { make in
            make.top.equalTo(missionSubLabel.snp.bottom).offset(20)
            make.leading.equalTo(self.snp.leading).offset(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
            make.height.equalTo(82)
        }
        
        circleView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.width.height.equalTo(60)
        }

        missionImageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        missionTextLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(circleView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
    }
}
