//
//  InviteScreenViewController.swift
//  TogetUp
//
//  Created by nayeon  on 4/12/24.
//

import RxCocoa
import RxSwift
import UIKit
import SnapKit
import Then

class InviteScreenViewController: UIViewController {
    
    private let viewModel: InviteViewModel
    private let disposeBag = DisposeBag()
    var latestGroupInfo: GroupInfo?
    
    init(invitationCode: String) {
        self.viewModel = InviteViewModel(invitationCode: invitationCode)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backGround = UIImageView().then {
        $0.image = UIImage(named: "bg_inviteScreen")
    }
    
    private let cancleButton = UIButton().then {
        $0.setImage(UIImage(named: "x"), for: .normal)
    }
    
    private let circleView = UIView().then {
        $0.backgroundColor = UIColor(named: "secondary050")
        $0.layer.cornerRadius = 43
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.black.cgColor
    }
    
    private var missionImageLabel = UILabel().then {
        $0.text = "⏰"
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 48)
    }
    
    private var groupNameLabel = UILabel().then {
        $0.text = "그룹명"
        $0.textAlignment = .center
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
    }
    
    private var introLabel = UILabel().then {
        $0.text = "그룹설명레이블인데 이걸 몇글자까지 허용해야하는지 고민임둥"
        $0.textAlignment = .center
        $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        $0.textColor = UIColor(red: 0.192, green: 0.188, blue: 0.2, alpha: 1)

    }
    
    private var openingDateLabel = UILabel().then {
        $0.text = "개설일"
        $0.textAlignment = .center
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
        $0.textColor = UIColor(red: 0.376, green: 0.365, blue: 0.384, alpha: 1)
    }
    
    private var memberCountLabel = UILabel().then {
        $0.text = "명"
        $0.textAlignment = .center
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        $0.textColor = UIColor(red: 0.376, green: 0.365, blue: 0.384, alpha: 1)
    }
    
    private let missionTitleLabel = UILabel().then {
        $0.text = "MISSION"
        $0.textAlignment = .center
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        $0.layer.borderColor = UIColor.black.cgColor
        $0.backgroundColor = UIColor(named: "secondary100")
        $0.layer.borderWidth = 2
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.lineBreakMode = .byWordWrapping
    }
    
    private var missionContentLabel = UILabel().then {
        $0.text = "미션 내용"
        $0.textAlignment = .center
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        $0.layer.borderColor = UIColor.black.cgColor
        $0.backgroundColor = .white
        $0.layer.borderWidth = 2
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let actionButton = UIButton().then {
        $0.setTitle("그룹 참여하기", for: .normal)
        $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        $0.titleLabel?.textColor = .white
        $0.backgroundColor = UIColor(named:"primary400")
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    private func setupUI() {
        view.addSubview(backGround)
        view.addSubview(cancleButton)
        view.addSubview(circleView)
        circleView.addSubview(missionImageLabel)
        view.addSubview(groupNameLabel)
        view.addSubview(introLabel)
        view.addSubview(openingDateLabel)
        view.addSubview(memberCountLabel)
        view.addSubview(missionTitleLabel)
        view.addSubview(missionContentLabel)
        view.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        
        backGround.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        cancleButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(64)
            $0.width.height.equalTo(24)
        }
        
        circleView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(cancleButton.snp.bottom).offset(32)
            $0.width.height.equalTo(86)
        }
        
        missionImageLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        groupNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(circleView.snp.bottom).offset(24)
        }
        
        introLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(groupNameLabel.snp.bottom).offset(10)
        }
        
        openingDateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(introLabel.snp.bottom).offset(16)
        }
        
        memberCountLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(missionTitleLabel.snp.top).offset(-8)
        }
        
        missionTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(missionContentLabel.snp.top).offset(2)
            $0.height.equalTo(48)
        }
        
        missionContentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(actionButton.snp.top).offset(-24)
            $0.height.equalTo(106)
        }
        
        actionButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-58)
            $0.height.equalTo(56)
        }
    }
    
    private func setupBindings() {
        let input = InviteViewModel.Input(viewWillAppear: rx.viewWillAppear,
                                          tapBackButton: cancleButton.rx.tap.asSignal(),
                                          tapAcceptButton: actionButton.rx.tap.asSignal()
        )
        
        let output = viewModel.transform(input: input)
        
        output.groupInfo.drive(onNext: { [weak self] info in
            self?.groupNameLabel.text = info.name
            self?.introLabel.text = info.intro
            self?.openingDateLabel.text = info.createdAt
            self?.memberCountLabel.text = "\(info.headCount)/10명"
            self?.missionContentLabel.text = info.missionKr
            self?.missionImageLabel.text = info.icon
            self?.latestGroupInfo = info
        }).disposed(by: disposeBag)
        
        output.didBackButtonTapped
            .emit(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.didAcceptButtonTapped
            .emit(onNext: { [weak self] in
                guard let self = self, let info = self.latestGroupInfo else { return }
                
                let joinAlarmVC = GroupJoinAlarmViewController()
                joinAlarmVC.roomId = info.id
                joinAlarmVC.icon = info.icon
                joinAlarmVC.missionId = info.missionObjectId < 64 ? 2 : 3
                joinAlarmVC.missionKr = info.missionKr
                joinAlarmVC.missionObjectId = info.missionObjectId
                joinAlarmVC.missionEndpoint = info.missionName
                self.navigationController?.pushViewController(joinAlarmVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
