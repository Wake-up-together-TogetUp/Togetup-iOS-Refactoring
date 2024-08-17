//
//  PushNotificationViewController.swift
//  TogetUp
//
//  Created by nayeon  on 8/18/24.
//

import UIKit

class PushNotificationViewController: UIViewController {
    
    private var push: [NotificationMessage] = []
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 68)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchData()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NotificationCollectionViewCell.self, forCellWithReuseIdentifier: NotificationCollectionViewCell.identifier)
    }
    
    private func fetchData() {
        push = [
            NotificationMessage(message: "알림 내용 1", date: Date(), isRead: false),
            NotificationMessage(message: "알림 내용 2", date: Date(), isRead: true),
            NotificationMessage(message: "알림 내용 3", date: Date(), isRead: false)
        ]
        collectionView.reloadData()
    }
}

extension PushNotificationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return push.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationCollectionViewCell.identifier, for: indexPath) as! NotificationCollectionViewCell
        let notification = push[indexPath.item]
//        cell.configure(with: notification)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("알림 선택됨: \(push[indexPath.item].message)")
    }
}

struct NotificationMessage {
    let message: String
    let date: Date
    let isRead: Bool
}
