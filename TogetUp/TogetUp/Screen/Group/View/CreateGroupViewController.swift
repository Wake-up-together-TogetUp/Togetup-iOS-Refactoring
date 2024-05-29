//
//  CreateGroupViewController.swift
//  TogetUp
//
//  Created by nayeon  on 2/12/24.
//

import UIKit
import SnapKit

class CreateGroupViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    var viewModel = CreateGroupViewModel(groupService: GroupService())
    var customView = CreateGroupView()
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
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        customView.addMissionButton.addTarget(self, action: #selector(addMissionButtonTapped), for: .touchUpInside)
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
        self.missionKoreanName = kr
    }

    
    @objc private func addMissionButtonTapped() {
        let storyboard = UIStoryboard(name: "Alarm", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "MissionListViewController") as? MissionListViewController else { return }
        
        vc.customMissionDataHandler = {[weak self] missionKoreanName, missionIcon, missionId, missionObjectId in
            self?.customView.missionSettingLabel.text = missionKoreanName
            self?.missionKoreanName = missionKoreanName
            self?.customView.missionImageLabel.text = missionIcon
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
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func nextButtonTapped() {
        
    }
}
