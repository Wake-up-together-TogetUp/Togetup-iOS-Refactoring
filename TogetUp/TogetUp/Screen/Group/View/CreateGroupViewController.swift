//
//  CreateGroupViewController.swift
//  TogetUp
//
//  Created by nayeon  on 2/12/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CreateGroupViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private let viewModel = CreateGroupViewModel()
    var createGroupView = CreateGroupView()
    private var disposeBag = DisposeBag()
    
    private var missionKoreanName = "사람"
    private var missionIcon = "👤"
    private var missionId = 2
    private var missionObjectId: Int? = 1
    var missionEndpoint = "person"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupUI()
        addMissionNotificationCenter()
        configureAlarmNameTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .white
        createGroupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createGroupView)
        
        createGroupView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        createGroupView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createGroupView.addMissionButton.addTarget(self, action: #selector(addMissionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - ViewModel Binding
    private func setupBindings() {
        let input = CreateGroupViewModel.Input(
            groupName: createGroupView.groupNameTextField.rx.text.orEmpty.asObservable(),
            groupIntro: createGroupView.groupIntroTextView.rx.text.orEmpty.asObservable(),
            nextButtonTapped: createGroupView.nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isNextButtonEnabled
            .bind(to: createGroupView.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        createGroupView.nextButton.rx.tap
            .withLatestFrom(Observable.combineLatest(output.groupName, output.groupIntro))
            .subscribe(onNext: { [weak self] groupName, groupIntro in
                let createAlarmVC = CreateAlarmViewController()
                createAlarmVC.groupName = groupName
                createAlarmVC.groupIntro = groupIntro
                createAlarmVC.missionId = self?.missionId ?? 2
                createAlarmVC.missionObjectId = self?.missionObjectId
                createAlarmVC.missionKoreanName = self?.createGroupView.missionTextLabel.text ?? ""
                createAlarmVC.missionEndpoint = self?.missionEndpoint ?? ""
                createAlarmVC.icon = self?.createGroupView.missionImageLabel.text ?? ""
                self?.navigationController?.pushViewController(createAlarmVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func addMissionNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(missionSelected(_:)), name: .init("MissionSelected"), object: nil)
    }
    
    private func truncateMaxLength(text: String) -> String {
        return String(text.prefix(10))
    }
    
    private func limitTextLength(text: String) -> String {
        return String(text.prefix(30))
    }
    
    private func updateGroupNameLabelColorAndText(truncatedText: String, originalText: String) {
        createGroupView.groupNameCountLabel.text = "\(truncatedText.count)/10"
        createGroupView.groupNameCountLabel.textColor = originalText.count > 10 ? UIColor(named: "error500") : UIColor(named: "neutral500")
    }
    
    private func updateGroupIntroLabelColorAndText(limitTextLength: String, originalText: String) {
        createGroupView.groupIntroCountLabel.text = "\(limitTextLength.count)/30"
        createGroupView.groupIntroCountLabel.textColor = originalText.count > 30 ? UIColor(named: "error500") : UIColor(named: "neutral500")
    }
    
    private func configureAlarmNameTextField() {
        createGroupView.groupNameTextField.rx.text.orEmpty
            .map { [weak self] text -> String in
                let truncatedText = self?.truncateMaxLength(text: text) ?? ""
                DispatchQueue.main.async {
                    self?.updateGroupNameLabelColorAndText(truncatedText: truncatedText, originalText: text)
                }
                return truncatedText
            }
            .bind(to: createGroupView.groupNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        createGroupView.groupIntroTextView.rx.text.orEmpty
            .map { [weak self] text -> String in
                let limitText = self?.limitTextLength(text: text) ?? ""
                DispatchQueue.main.async {
                    self?.updateGroupIntroLabelColorAndText(limitTextLength: limitText, originalText: text)
                }
                return limitText
            }
            .bind(to: createGroupView.groupIntroTextView.rx.text)
            .disposed(by: disposeBag)
    }
    
    @objc func missionSelected(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let icon = userInfo["icon"] as? String,
              let kr = userInfo["kr"] as? String,
              let missionObjectId = userInfo["missionObjectId"] as? Int,
              let missionId = userInfo["missionId"] as? Int,
              let missionName = userInfo["name"] as? String else {
            return
        }
        
        self.createGroupView.missionImageLabel.text = icon
        self.missionObjectId = missionObjectId
        self.missionId = missionId
        self.missionEndpoint = missionName
        self.createGroupView.missionTextLabel.text = kr
    }
    
    @objc private func addMissionButtonTapped() {
        let storyboard = UIStoryboard(name: "Alarm", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController else { return }
        
        vc.customMissionDataHandler = {[weak self] missionKoreanName, missionIcon, missionId, missionObjectId in
            self?.createGroupView.missionTextLabel.text = missionKoreanName
            self?.createGroupView.missionImageLabel.text = missionIcon
            self?.missionId = missionId
            self?.missionObjectId = missionObjectId
            self?.missionEndpoint = ""
        }
        
        vc.modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        showCancelGroupPopUpView()
    }
    
    private func showCancelGroupPopUpView() {
        var dialog: DialogTypeChoice?
        
        dialog = DialogTypeChoice(
            title: "그룹 개설 취소",
            subtitle: "알람 설정을 그만두면\n그룹도 함께 삭제됩니다",
            leftButtonTitle: "가입 취소하기",
            rightButtonTitle: "계속 진행하기",
            leftAction: {
                self.dismiss(animated: true, completion: nil)
            },
            rightAction: {
                dialog?.removeFromSuperview()
            }
        )
        
        if let dialog = dialog {
            view.addSubview(dialog)
            
            dialog.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(270)
                make.height.equalTo(177)
            }
        }
    }
}
