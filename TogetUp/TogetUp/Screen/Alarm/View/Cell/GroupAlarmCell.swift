//
//  GroupAlarmCell.swift
//  TogetUp
//
//  Created by nayeon  on 8/12/24.
//

import UIKit
import SnapKit

final class GroupAlarmCell: UICollectionViewCell {
    // MARK: - Property
    static let identifier = "GroupAlarmCell"
    
    private let backgroudView = UIView().then {
        $0.backgroundColor = UIColor(named: "secondary050")
        $0.clipsToBounds = true
    }
    
    private let img = UILabel().then {
        $0.text = "⏰"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 32)
    }
    
    private let timeLabel = UILabel().then {
        $0.text = "am 12:00"
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
    }
    
    private let missionLabel = UILabel().then {
        $0.text = "MISSION"
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 8)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "인증 내용"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        $0.textColor = UIColor(named: "neutral600")
    }
    
    private let topSeparatorLine = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let groupImg = UIImageView().then {
        $0.image = UIImage(named: "GROUP")
        $0.contentMode = .scaleAspectFill
    }
    
    private let groupNameLabel = UILabel().then {
        $0.text = "Group Name"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        
        contentView.addSubview(backgroudView)
        backgroudView.addSubview(img)
        backgroudView.addSubview(timeLabel)
        backgroudView.addSubview(subTitleLabel)
        contentView.addSubview(topSeparatorLine)
        contentView.addSubview(groupImg)
        contentView.addSubview(groupNameLabel)
        
        backgroudView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(subTitleLabel.snp.bottom).offset(18)
        }
        
        img.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(18)
            $0.width.height.equalTo(32)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(img.snp.trailing).offset(16)
            $0.top.equalToSuperview().offset(14)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(img.snp.trailing).offset(16)
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        topSeparatorLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().offset(0)
            $0.top.equalTo(backgroudView.snp.bottom)
            $0.height.equalTo(2)
        }
        
        groupImg.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(topSeparatorLine.snp.bottom).offset(10)
        }
        
        groupNameLabel.snp.makeConstraints {
            $0.leading.equalTo(groupImg.snp.trailing).offset(12)
            $0.centerY.equalTo(groupImg.snp.centerY)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
}
