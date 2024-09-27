//
//  GroupListCollectionViewCell.swift
//  TogetUp
//
//  Created by nayeon  on 2/22/24.
//

import UIKit
import SnapKit

final class GroupListCollectionViewCell: UICollectionViewCell {
    //MARK: - Property
    static let identifier = "GroupListCollectionViewCell"
        
    var img: UILabel = {
        let img = UILabel()
        img.text = "⏰"
        img.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 32)
        return img
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "그룹방 이름"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let missionLable: UILabel = {
        let label = UILabel()
        label.text = "MISSION"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 8)
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "인증 내용"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var allStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, missionStackView])
        stackView.spacing = 6
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var missionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [missionLable, subTitleLabel])
        stackView.spacing = 8
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .white
         self.layer.cornerRadius = 10
         self.layer.masksToBounds = true
         self.layer.borderWidth = 2
         self.layer.borderColor = UIColor.black.cgColor
        
        contentView.addSubview(img)
        contentView.addSubview(allStackView)
        
        img.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(14)
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }
        
        allStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(img.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - Configuration
    func configure(with groupResult: GroupResult) {
        img.text = groupResult.icon
        titleLabel.text = groupResult.name
        subTitleLabel.text = groupResult.kr
    }
}
