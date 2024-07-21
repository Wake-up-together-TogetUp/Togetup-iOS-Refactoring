//
//  GroupListViewController.swift
//  TogetUp
//
//  Created by nayeon on 2023/08/18.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class GroupListViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: GroupViewModel
    private let fetchGroupList = PublishSubject<Void>()
    private var groupResults = [GroupResult]()
    private let isCodeInvalid = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Component
    private let titleLabel = UILabel().then {
        $0.text = "그룹"
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
    }
    
    private let inviteButton = UIButton().then {
        let image = UIImage(named: "user-plus-01")
        $0.setImage(image, for: .normal)
        $0.tintColor = .black
    }
    
    private let createButton = UIButton().then {
        let image = UIImage(named: "message-plus-square")
        $0.setImage(image, for: .normal)
        $0.tintColor = .black
    }

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
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        $0.alpha = 0
    }
    
    private let alertView = UIView().then {
        $0.backgroundColor = UIColor(named: "secondary025")
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.layer.masksToBounds = true
    }
    
    private let alertTitleLabel = UILabel().then {
        $0.text = "초대코드로 참여하기"
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
        $0.textAlignment = .center
    }
    
    private let textField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.placeholder = "초대코드를 입력해주세요"
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
    }
    
    private let dismissButton = UIButton(type: .system).then {
        $0.setTitle("가입 취소하기", for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
        $0.tintColor = .black
        $0.backgroundColor = UIColor(named: "secondary025")
    }
    
    private let okButton = UIButton(type: .system).then {
        $0.setTitle("계속 진행하기", for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
        $0.tintColor = .white
        $0.backgroundColor = UIColor(named: "primary400")
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = GroupViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchGroupList.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupButtonActions()
        setupTextFieldBinding()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(createButton)
        view.addSubview(inviteButton)
        view.addSubview(collectionView)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalToSuperview().offset(20)
        }
        
        createButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        inviteButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(createButton.snp.leading).offset(-10)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(alertView)
        alertView.addSubview(alertTitleLabel)
        alertView.addSubview(okButton)
        alertView.addSubview(textField)
        alertView.addSubview(dismissButton)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(296)
            $0.height.equalTo(184)
        }
        
        alertTitleLabel.snp.makeConstraints {
            $0.top.equalTo(alertView).offset(24)
            $0.left.right.equalTo(alertView).inset(20)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(alertTitleLabel.snp.bottom).offset(16)
            $0.height.equalTo(48)
            $0.left.right.equalTo(alertView).inset(20)
        }
        
        dismissButton.snp.makeConstraints {
            $0.bottom.equalTo(alertView).offset(-20)
            $0.left.equalTo(alertView).offset(20)
            $0.height.equalTo(40)
            $0.width.equalTo(124)
        }
        
        okButton.snp.makeConstraints {
            $0.bottom.equalTo(alertView).offset(-20)
            $0.right.equalTo(alertView).offset(-20)
            $0.height.equalTo(40)
            $0.width.equalTo(124)
        }
        
        backgroundView.alpha = 0
    }
    
    private func setupTextFieldBinding() {
        Observable.combineLatest(textField.rx.text.orEmpty, isCodeInvalid)
            .subscribe(onNext: { [weak self] (text, isInvalid) in
                let borderColor = (isInvalid && !text.isEmpty) ? UIColor.red.cgColor : UIColor.black.cgColor
                self?.textField.layer.borderColor = borderColor
            })
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        let input = GroupViewModel.Input(
            fetchGroupList: fetchGroupList,
            okButtonTap: okButton.rx.tap.asSignal(),
            invitationCode: textField.rx.text.orEmpty.asSignal(onErrorJustReturn: "")
        )
        let output = viewModel.transform(input: input)
        
        output.groupList
            .drive(onNext: { [weak self] groupResults in
                self?.groupResults = groupResults
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)
        
        output.didOkButtonTapped
            .emit(onNext: { [weak self] isValid in
                if isValid {
                    self?.redirectToNextPage()
                } else {
                    self?.showInvalidCodeAlert()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func redirectToNextPage() {
        guard let invitationCode = textField.text else { return }
        let inviteVC = InviteScreenViewController(invitationCode : invitationCode)
        let navigationController = UINavigationController(rootViewController: inviteVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        present(navigationController, animated: true, completion: nil)
        dismissAlert()
    }
    
    private func showInvalidCodeAlert() {
        textField.layer.borderColor = UIColor.red.cgColor
    }
    
    private func setupButtonActions() {
        createButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showCreateViewController()
            })
            .disposed(by: disposeBag)
        
        inviteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert()
            })
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismissAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func showCreateViewController() {
        let createVC = CreateGroupViewController()
        let navigationController = UINavigationController(rootViewController: createVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        present(navigationController, animated: true, completion: nil)
    }
    
    private func showAlert() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
        }
    }
    
    private func dismissAlert() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
        }, completion: { _ in
            self.textField.text = ""
            self.textField.layer.borderColor = UIColor.black.cgColor
            self.textField.resignFirstResponder()
        })
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Extension
extension GroupListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupListCollectionViewCell.identifier, for: indexPath) as? GroupListCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let groupResult = groupResults[indexPath.item]
        cell.configure(with: groupResult)
        return cell
    }
}

extension GroupListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 40
        let height: CGFloat = 68
        return CGSize(width: width, height: height)
    }
}

extension GroupListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRoomCode = groupResults[indexPath.item].roomId
        let roomDetailVC = GroupCalendarViewController(roomId: selectedRoomCode)
        navigationController?.pushViewController(roomDetailVC, animated: true)
    }
}
