//
//  PushNotificationViewController.swift
//  TogetUp
//
//  Created by nayeon  on 8/18/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class PushNotificationViewController: UIViewController {
    private let viewModel = PushNotificationViewModel()
    private let disposeBag = DisposeBag()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 68)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let noNotificationLabel = UILabel().then {
        $0.text = "알림함이 비어있어요"
        $0.textColor = .black
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let noNotificationSubLabel = UILabel().then {
        $0.text = "수신한 알림은 이곳에 정리됩니다"
        $0.textColor = UIColor(named: "neutral600")
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.title = "알림"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: self, action: #selector(dismissViewController))
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        view.addSubview(noNotificationLabel)
        view.addSubview(noNotificationSubLabel)
        
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        noNotificationLabel.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(-4)
        }
        
        noNotificationSubLabel.snp.makeConstraints {
            $0.top.equalTo(noNotificationLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.register(NotificationCollectionViewCell.self, forCellWithReuseIdentifier: NotificationCollectionViewCell.identifier)
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        let deleteNotificationSubject = PublishSubject<Int>()
        let markAsReadSubject = PublishSubject<Int>()

        let input = PushNotificationViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            deleteNotification: deleteNotificationSubject.asObservable(),
            markAsRead: markAsReadSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.notifications
            .drive(collectionView.rx.items(cellIdentifier: NotificationCollectionViewCell.identifier, cellType: NotificationCollectionViewCell.self)) { [weak self] index, notification, cell in
                guard let cell = cell as? NotificationCollectionViewCell else { return }
                
                cell.configure(with: notification)
                cell.onDeleteButtonTapped
                    .bind(onNext: { [weak self] in
                        deleteNotificationSubject.onNext(notification.id)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.onCellTapped
                    .bind(onNext: { [weak self] in
                        markAsReadSubject.onNext(notification.id)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.notifications
            .drive(onNext: { [weak self] notifications in
                guard let self = self else { return }
                let hasNotifications = !notifications.isEmpty
                self.noNotificationLabel.isHidden = hasNotifications
                self.noNotificationSubLabel.isHidden = hasNotifications
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { error in
                print("Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PushNotificationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 68)
    }
}
