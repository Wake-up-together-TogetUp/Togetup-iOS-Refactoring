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
        
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
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
