//
//  GroupListViewController.swift
//  TogetUp
//
//  Created by nayeon on 2023/08/18.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class GroupListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: GroupViewModel
    private let fetchGroupList = PublishSubject<Void>()
    private var groupResults = [GroupResult]()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "그룹"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
        return label
    }()
    
    let inviteButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "user-plus-01")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let createButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "message-plus-square")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 68)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GroupListCollectionViewCell.self, forCellWithReuseIdentifier: GroupListCollectionViewCell.identifier)
        return collectionView
    }()
    
    // MARK: - Initializer
    required init?(coder: NSCoder) {
        self.viewModel = GroupViewModel(groupService: GroupService())
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchGroupList.onNext(())
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupButtonActions()
        
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-22)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        view.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(createButton.snp.leading).offset(-10)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Button Actions
    func setupButtonActions() {
        createButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showCreateViewController()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    func showCreateViewController() {
        let createVC = CreateGroupViewController()
        let navigationController = UINavigationController(rootViewController: createVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - ViewModel Bindings
    private func setupBindings() {
        let input = GroupViewModel.Input(fetchGroupList: fetchGroupList)
        let output = viewModel.transform(input: input)
        
        output.groupList
            .drive(onNext: { [weak self] groupResults in
                self?.groupResults = groupResults
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] errorMessage in
                self?.showError(message: errorMessage)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Error Handling
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupListCollectionViewCell.identifier, for: indexPath) as! GroupListCollectionViewCell
        let groupResult = groupResults[indexPath.item]
        cell.configure(with: groupResult)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 40
        let height: CGFloat = 68
        return CGSize(width: width, height: height)
    }
}
