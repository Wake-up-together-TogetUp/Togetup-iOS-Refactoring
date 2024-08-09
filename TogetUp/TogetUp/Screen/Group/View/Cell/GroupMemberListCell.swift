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
        $0.backgroundColor = UIColor(named: "neutral300")
        $0.contentMode = .scaleAspectFill
    }
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 14)
        $0.text = "hi"
        $0.textColor = .black
    }
    
    private let LevelLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 11)
        $0.text = "hello"
        $0.textColor = UIColor(named: "neutra400")
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
        contentView.addSubview(LevelLabel)
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
        
        LevelLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(nameLabel.snp.leading)
        }
    }
}

#Preview {
    GroupMemberListCell()
}
