//
//  GroupSettingViewController.swift
//  TogetUp
//
//  Created by nayeon  on 8/6/24.
//

import RxSwift
import SnapKit
import Then
import UIKit

final class GroupSettingsViewController: UIViewController {
    private let viewModel: GroupSettingsViewModel
    private let disposeBag = DisposeBag()
    private var userProfileData: [UserProfileData] = []
    
    init(roomId: Int) {
        self.viewModel = GroupSettingsViewModel(roomId: roomId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .white
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(named: "neutra000")
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.layer.masksToBounds = true
    }
    
    private let iconImageView = UILabel().then {
        $0.text = "⏰"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 32)
    }

    private let titleLabel = UILabel().then {
        $0.text = "그룹 타이틀"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        $0.textColor = .black
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "그룹 설명"
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        $0.textColor = UIColor(named: "neutral600")
        $0.numberOfLines = 2
    }
    
    private let createdDateLabel = UILabel().then {
        $0.text = "생성일: 2024-08-06"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        $0.textColor = UIColor(named: "neutral400")
    }
    
    private let inviteCodeButton = UIButton(type: .system).then {
        $0.setTitle("초대코드 보내기", for: .normal)
        $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(named: "primary400")
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 2
        $0.layer.masksToBounds = true
    }
    
    private let missionButton = UIButton().then {
        $0.backgroundColor = UIColor(named: "secondary050")
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    private let circleView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 30
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1).cgColor
    }
    
    private var missionImageLabel = UILabel().then {
        $0.text = "⏰"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 36)
    }
    
    private var missionTextLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        $0.text = "미션 내용"
    }

    private var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let topSeparatorLine = UIView().then {
        $0.backgroundColor = .black
    }

    private let exitButton = UIButton(type: .system).then {
        let boldConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        let boldImage = UIImage(systemName: "rectangle.portrait.and.arrow.forward", withConfiguration: boldConfiguration)
        $0.setImage(boldImage, for: .normal)
        $0.tintColor = .black
    }
    
    private let alertView = UIView().then {
        $0.backgroundColor = UIColor(named: "secondary025")
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 2
        $0.layer.masksToBounds = true
    }

    private let alertTitleLabel = UILabel().then {
        $0.text = "초대코드"
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        $0.textAlignment = .center
        $0.textColor = .black
    }

    private let inviteCodeLabel = UILabel().then {
        $0.text = "" 
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        $0.textAlignment = .center
        $0.textColor = UIColor(named: "neutral800")
    }

    private let dismissButton = UIButton(type: .system).then {
        $0.setTitle("닫기", for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
        $0.tintColor = .black
        $0.backgroundColor = UIColor(named: "secondary025")
        $0.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
    }

    private let copyButton = UIButton(type: .system).then {
        $0.setTitle("코드 복사하기", for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
        $0.tintColor = .white
        $0.backgroundColor = UIColor(named: "primary400")
        $0.addTarget(self, action: #selector(copyInviteCode), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupTableView()
        setupBindings()
    }

    private func setupNavigationBar() {
        DispatchQueue.main.async {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            
            appearance.titleTextAttributes = [
                .font: UIFont(name: "AppleSDGothicNeo-Bold", size: 18),
                .foregroundColor: UIColor.black
            ]
            
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.compactAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationItem.title = "그룹 설정"
            self.navigationController?.navigationBar.topItem?.title = ""
            self.navigationController?.navigationBar.tintColor = .black
        }
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(bottomView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(containerView)
        contentView.addSubview(missionButton)
        missionButton.addSubview(circleView)
        missionButton.addSubview(missionTextLabel)
        circleView.addSubview(missionImageLabel)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(createdDateLabel)
        containerView.addSubview(inviteCodeButton)
        
        contentView.addSubview(tableView)
        
        bottomView.addSubview(topSeparatorLine)
        bottomView.addSubview(exitButton)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
            $0.bottom.equalTo(tableView.snp.bottom).offset(20)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(75)
            $0.bottom.equalToSuperview()
        }
        
        topSeparatorLine.snp.makeConstraints {
            $0.height.equalTo(2)
            $0.leading.trailing.top.equalToSuperview()
        }
        
        exitButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(contentView).inset(20)
            $0.height.equalTo(178)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(14)
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.top)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalTo(titleLabel.snp.trailing)
        }
        
        createdDateLabel.snp.makeConstraints {
            $0.bottom.equalTo(inviteCodeButton.snp.top).offset(-16)
            $0.leading.equalTo(descriptionLabel.snp.leading)
            $0.trailing.equalTo(descriptionLabel.snp.trailing)
        }
        
        inviteCodeButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        missionButton.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(82)
        }
        
        circleView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(14)
            $0.width.height.equalTo(60)
        }

        missionImageLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        missionTextLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(circleView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(missionButton.snp.bottom).offset(24)
            $0.leading.trailing.equalTo(contentView).inset(20)
            $0.height.equalTo(tableView.contentSize.height + 45)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GroupMemberListCell.self, forCellReuseIdentifier: GroupMemberListCell.identifier)
        
        tableView.layer.cornerRadius = 12
        tableView.layer.borderWidth = 2
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.masksToBounds = true
    }
    
    private func setupBindings() {
        let exitButtonTappedWithAlert = exitButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                return Observable<Void>.create { observer in
                    let alert = UIAlertController(title: "방을 나가시겠습니까?", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                        observer.onCompleted()
                    }
                    let confirmAction = UIAlertAction(title: "확인", style: .destructive) { _ in
                        observer.onNext(())
                        observer.onCompleted()
                    }
                    alert.addAction(cancelAction)
                    alert.addAction(confirmAction)
                    self?.present(alert, animated: true, completion: nil)
                    return Disposables.create {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }

        let input = GroupSettingsViewModel.Input(viewDidLoad: Observable.just(()),
                                                 inviteCodeButtonTapped: inviteCodeButton.rx.tap.asObservable(),
                                                 exitButtonTapped: exitButtonTappedWithAlert)

        let output = viewModel.transform(input: input)
        
        output.groupInfo
            .drive(onNext: { [weak self] groupInfo in
                guard let self = self else { return }
                
                self.userProfileData = groupInfo.userProfileData
                self.tableView.reloadData()
                let tableViewHeight = CGFloat(self.userProfileData.count * 58 + 50)
                self.tableView.snp.updateConstraints {
                    $0.height.equalTo(tableViewHeight)
                }
                self.iconImageView.text = groupInfo.missionData.icon
                self.titleLabel.text = groupInfo.roomData.name
                self.descriptionLabel.text = groupInfo.roomData.intro
                self.createdDateLabel.text = groupInfo.roomData.createdAt
                self.missionImageLabel.text = groupInfo.missionData.icon
                self.missionTextLabel.text = groupInfo.missionData.name

            })
            .disposed(by: disposeBag)

        output.didInviteCodeButtonTapped
            .drive(onNext: { [weak self] inviteCode in
                self?.showCustomInviteCodeAlert(inviteCode: inviteCode)
            })
            .disposed(by: disposeBag)
        
        output.didExitButtonTapped
            .emit(onNext: { [weak self] isSuccess in
                guard isSuccess else {
                    print("방 나가기 실패")
                    return
                }
                self?.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func showCustomInviteCodeAlert(inviteCode: String) {
        inviteCodeLabel.text = inviteCode

        view.addSubview(alertView)
        alertView.addSubview(alertTitleLabel)
        alertView.addSubview(inviteCodeLabel)
        alertView.addSubview(dismissButton)
        alertView.addSubview(copyButton)

        alertView.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide.snp.center)
            $0.width.equalTo(270)
            $0.height.equalTo(155)
        }

        alertTitleLabel.snp.makeConstraints {
            $0.top.equalTo(alertView.snp.top).offset(24)
            $0.centerX.equalToSuperview()
        }

        inviteCodeLabel.snp.makeConstraints {
            $0.top.equalTo(alertTitleLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }

        dismissButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(24)
            $0.width.equalTo(115)
            $0.height.equalTo(40)
        }

        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(24)
            $0.width.equalTo(115)
            $0.height.equalTo(40)
        }
    }
    
    @objc private func dismissAlert() {
        alertView.removeFromSuperview()
    }

    @objc private func copyInviteCode() {
        UIPasteboard.general.string = inviteCodeLabel.text
        let alert = UIAlertController(title: nil, message: "초대코드가 복사되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Extension
extension GroupSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfileData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberListCell.identifier, for: indexPath) as? GroupMemberListCell
        else {
            return UITableViewCell()
        }
        let userProfile = userProfileData[indexPath.row]
        let isCurrentUser = indexPath.row == 0
        cell.configure(with: userProfile, isCurrentUser: isCurrentUser)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "secondary100")
        
        let headerLabel = UILabel()
        headerLabel.text = "참여중인 멤버"
        headerLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
        headerLabel.textColor = .black
        
        let countLabel = UILabel()
        countLabel.text = String(userProfileData.count)
        countLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        countLabel.textColor = UIColor(named: "primary500")
        
        headerView.addSubview(headerLabel)
        headerView.addSubview(countLabel)
        
        headerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.centerY.equalTo(headerLabel.snp.centerY)
            $0.leading.equalTo(headerLabel.snp.trailing).offset(8)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .black
        
        headerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints {
            $0.height.equalTo(2)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}
