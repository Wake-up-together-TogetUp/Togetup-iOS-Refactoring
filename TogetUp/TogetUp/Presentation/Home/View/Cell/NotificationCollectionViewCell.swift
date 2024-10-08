//
//  NotificationCollectionViewCell.swift
//  TogetUp
//
//  Created by nayeon  on 8/18/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class NotificationCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "NotificationCollectionViewCell"
    
    private let timeLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 11)
        $0.textColor = UIColor(named: "neutral300")
        $0.text = "시간전"
    }
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 14)
        $0.textColor = .black
        $0.text = ""
    }
    
    private let isReadView = UIView().then {
        $0.backgroundColor = UIColor(named: "error500")
        $0.layer.cornerRadius = 3
        $0.clipsToBounds = true
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "x"), for: .normal)
        $0.tintColor = .black
    }
    
    var disposeBag = DisposeBag()
    let onDeleteButtonTapped = PublishSubject<Void>()
    let onCellTapped = PublishSubject<Void>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func setupViews() {
        contentView.backgroundColor = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(isReadView)
        contentView.addSubview(deleteButton)
        
        timeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-14)
            $0.leading.equalTo(isReadView.snp.trailing).offset(12)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalTo(isReadView.snp.trailing).offset(12)
        }
        
        isReadView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(14)
            $0.width.height.equalTo(6)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(16)
        }
    }
    
    func configure(with notification: NotificationList) {
        timeLabel.text = notification.body
        messageLabel.text = notification.title
        isReadView.isHidden = notification.isRead

        deleteButton.rx.tap
            .bind(to: onDeleteButtonTapped)
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func cellTapped() {
        onCellTapped.onNext(())
    }

    /// 터치 이벤트 우선순위 처리
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // deleteButton이 터치되었을 경우 우선 처리
        if deleteButton.frame.contains(point) {
            return deleteButton
        }
        return super.hitTest(point, with: event)
    }

    /// deleteButton의 터치 영역을 확대
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let buttonTouchArea = deleteButton.frame.insetBy(dx: -10, dy: -10)
        if buttonTouchArea.contains(point) {
            return true
        }
        return super.point(inside: point, with: event)
    }
}
