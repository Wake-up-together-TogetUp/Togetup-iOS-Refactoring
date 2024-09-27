//
//  GroupMemberListCell.swift
//  TogetUp
//
//  Created by nayeon  on 8/6/24.
//

import UIKit
import SnapKit
import Then

class GroupMemberListCell: UITableViewCell {
    
    static let identifier = "GroupMemberListCell"
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFill
    }
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 14)
        $0.text = "hi"
        $0.textColor = .black
    }
    
    private let levelLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 11)
        $0.text = "hello"
        $0.textColor = UIColor(named: "neutral400")
    }
    
    private let badgeMe = UIImageView().then {
        $0.image = UIImage(named: "badge-me")
        $0.contentMode = .center
        $0.isHidden = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(levelLabel)
        contentView.addSubview(badgeMe)
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(36)
        }
        
        nameLabel.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView.snp.bottom)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        
        levelLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(nameLabel.snp.leading)
        }
        
        badgeMe.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.width.height.equalTo(16)
        }
    }
    
    func configure(with data: UserProfileData, isCurrentUser: Bool) {
        nameLabel.text = data.userName
        profileImageView.image = UIImage(named: "P_\(data.theme)")
        levelLabel.text = "Lv.\(data.level)"
        badgeMe.isHidden = !isCurrentUser
    }
}
