//
//  GroupListViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/18.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class GroupListViewController: BaseVC, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // 상단 레이블
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "그룹"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    // 추가 버튼
    let addButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "user-plus-01")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    // 메시지 추가 버튼
    let messageButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "message-plus-square")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    // collectionView
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 50) // 한 줄에 하나의 셀만 표시
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        // 레이블 추가
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.leading.equalToSuperview().offset(16)
        }
        
        // 추가 버튼 추가
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        // 메시지 추가 버튼 추가
        view.addSubview(messageButton)
        messageButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(addButton.snp.leading).offset(-10)
        }
        
        // collectionView 추가
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 // 셀 개수
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        // 셀 설정
        cell.backgroundColor = .lightGray
        return cell
    }
}
