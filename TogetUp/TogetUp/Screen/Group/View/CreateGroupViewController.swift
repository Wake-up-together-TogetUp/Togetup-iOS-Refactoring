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
    var viewModel = CreateGroupViewModel(groupService: GroupService())
    var customView = CreateGroupView()
    private var disposeBag = DisposeBag()
    
    private var missionKoreanName = "사람"
    private var missionIcon = "👤"
    private var missionId = 2
    private var missionObjectId: Int? = 1
    var missionEndpoint = "person"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
        addMissionNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .white
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        
        customView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        customView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        customView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        customView.addMissionButton.addTarget(self, action: #selector(addMissionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
           let input = CreateGroupViewModel.Input(
               didGroupNameTextFieldChange: customView.groupNameTextField.rx.text.orEmpty.asObservable(),
               didExplanationTextViewChange: customView.groupIntroTextView.rx.text.orEmpty.asObservable(),
               tapMissionButton: customView.addMissionButton.rx.tap.asSignal(),
               tapCompleteButton: customView.nextButton.rx.tap.asSignal(),
               tapCancleButton: customView.cancelButton.rx.tap.asSignal(),
               icon: Observable.just(missionIcon),
               missionId: Observable.just(missionId),
               missionObjectId: Observable.just(missionObjectId)
           )
           
           let output = viewModel.transform(input: input)
           
           output.groupName
               .bind(to: customView.groupNameTextField.rx.text)
               .disposed(by: disposeBag)
           
           output.groupIntro
               .bind(to: customView.groupIntroTextView.rx.text)
               .disposed(by: disposeBag)
           
           output.error
               .drive(onNext: { errorMessage in
                   print("Error: \(errorMessage)")
               })
               .disposed(by: disposeBag)
           
           output.didCompleteButtonTapped
               .emit(onNext: { [weak self] in
                   self?.navigationController?.popViewController(animated: true)
               })
               .disposed(by: disposeBag)
           
           output.didCancleButtonTapped
               .emit(onNext: { [weak self] in
                   self?.dismiss(animated: true, completion: nil)
               })
               .disposed(by: disposeBag)
       }
    
    // MARK: - Button Actions
    private func addMissionNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(missionSelected(_:)), name: .init("MissionSelected"), object: nil)
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
        
        self.customView.missionSettingLabel.text = kr
        self.customView.missionImageLabel.text = icon
        self.missionObjectId = missionObjectId
        self.missionId = missionId
        self.missionEndpoint = missionName
        self.customView.missionTextLabel.text = kr
        
        viewModel.transform(input: CreateGroupViewModel.Input(
             didGroupNameTextFieldChange: customView.groupNameTextField.rx.text.orEmpty.asObservable(),
             didExplanationTextViewChange: customView.groupIntroTextView.rx.text.orEmpty.asObservable(),
             tapMissionButton: customView.addMissionButton.rx.tap.asSignal(),
             tapCompleteButton: customView.nextButton.rx.tap.asSignal(),
             tapCancleButton: customView.cancelButton.rx.tap.asSignal(),
             icon: Observable.just(icon),
             missionId: Observable.just(missionId),
             missionObjectId: Observable.just(missionObjectId)
         ))
    }

    
    @objc private func addMissionButtonTapped() {
        let storyboard = UIStoryboard(name: "Alarm", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController else { return }
        
        vc.customMissionDataHandler = {[weak self] missionKoreanName, missionIcon, missionId, missionObjectId in
            self?.customView.missionSettingLabel.text = missionKoreanName
            self?.customView.missionTextLabel.text = missionKoreanName
            self?.customView.missionImageLabel.text = missionIcon
            self?.missionId = missionId
            self?.missionObjectId = missionObjectId
            self?.missionEndpoint = ""
        }
        
        self.viewModel.transform(input: CreateGroupViewModel.Input(
            didGroupNameTextFieldChange: self.customView.groupNameTextField.rx.text.orEmpty.asObservable() ?? Observable.just(""),
            didExplanationTextViewChange: self.customView.groupIntroTextView.rx.text.orEmpty.asObservable() ?? Observable.just(""),
            tapMissionButton: self.customView.addMissionButton.rx.tap.asSignal() ?? Signal.empty(),
            tapCompleteButton: self.customView.nextButton.rx.tap.asSignal() ?? Signal.empty(),
            tapCancleButton: self.customView.cancelButton.rx.tap.asSignal() ?? Signal.empty(),
               icon: Observable.just(missionIcon),
               missionId: Observable.just(missionId),
               missionObjectId: Observable.just(missionObjectId)
           ))
        
        vc.modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func nextButtonTapped() {
        
    }
}
