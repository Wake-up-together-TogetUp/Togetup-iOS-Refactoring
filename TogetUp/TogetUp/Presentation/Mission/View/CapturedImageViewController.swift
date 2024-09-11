//
//  CapturedImageViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/25.
//

import UIKit
import RxSwift
import Lottie
import SnapKit

class CapturedImageViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressBar: LottieAnimationView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var filmAgainButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var statusLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var successLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var levelUpLabel: UILabel!
    @IBOutlet weak var congratLabel: UILabel!
    @IBOutlet weak var levelUpView: UIView!
    @IBOutlet weak var newAvatarAvailabelLabel: UILabel!
    
    // MARK: - Properties
    var image = UIImage()
    var missionId = 0
    var missionEndpoint: String?
    private let viewModel = MissionProcessViewModel()
    private let realmManager = RealmAlarmDataManager()
    private let disposeBag = DisposeBag()
    private var countdownTimer: Timer?
    private var countdownValue = 5
    private var filePath = ""
    var alarmId = 0
    lazy var isPersonlAlarm = realmManager.checkIfAlarmIsPersonal(withId: alarmId)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        capturedImageView.image = image
        customUI()
        postMissionImage()
        setLottieAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pointLabel.layer.cornerRadius = 12
        pointLabel.layer.masksToBounds = true
        levelUpView.layer.cornerRadius = 12
        levelUpView.layer.masksToBounds = true
    }
    
    // MARK: - Custom Method
    private func customUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.progressView.isHidden = false
        }
        progressView.layer.cornerRadius = 12
        progressView.layer.borderWidth = 2
        
        filmAgainButton.layer.cornerRadius = 18.5
        filmAgainButton.layer.borderWidth = 2
    }
    
    private func postMissionImage() {
        var missionName: String = ""
        
        switch missionId {
        case 1:
            missionName = "direct-registration"
        case 2:
            missionName = "object-detection"
        case 3:
            missionName = "expression-recognition"
        default:
            print("알 수 없는 미션 ID")
            return
        }
        
        viewModel.sendMissionImage(missionName: missionName, object: self.missionEndpoint, missionImage: image)
            .subscribe(onNext: { response in
                self.handleMissionDetectResponse(response)
                let param = MissionCompleteRequest(alarmId: self.alarmId, missionPicLink: response.result?.filePath ?? "")
                self.completeMission(with: param)
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleMissionDetectResponse(_ response: MissionDetectResponse) {
        progressView.backgroundColor = UIColor(named: "secondary050")
        progressBar.isHidden = true
        if response.message == "미션을 성공하지 못했습니다." || response.message == "탐지된 객체가 없습니다." {
            updateUIForFailure()
        } else {
            statusLabel.text = "미션 성공🎉"
            successLabel.isHidden = false
            progressView.isHidden = false
            pointLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                self.progressView.isHidden = true
                let url = URL(string: response.result!.filePath)!
                self.capturedImageView.load(url: url)
            }
        }
    }
    
    private func completeMission(with param: MissionCompleteRequest) {
        viewModel.completeMission(param: param) { result in
            switch result {
            case .success(let response):
                if let userLevelUp = response.result?.userLevelUp, userLevelUp {
                    self.handleCompleteResponseUI(response)
                }
                if self.isPersonlAlarm {
                    self.startCountdown()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.progressView.isHidden = true
                        self.showMoveToGroupPopUpView()
                    }
                }
                
            case .failure(let error):
                if case NetWorkingError.tooManyRequests = error {
                    self.updateUIForFailure(message: "최대 요청 횟수를 초과했습니다.", buttonTitle: "홈으로 이동", action: #selector(self.navigateToHomeAction))
                } else {
                    self.updateUIForFailure(message: "인식에 실패했어요😢", buttonTitle: "다시 촬영하기", action: #selector(self.filmAgainButtonTapped(_:)))
                }
            }
        }
    }
    
    private func handleCompleteResponseUI(_ response: MissionCompleteResponse) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if response.result?.userLevelUp ?? false {
                self.statusLabel.text = "LEVEL UP"
                self.successLabel.isHidden = true
                self.pointLabel.isHidden = true
                self.levelUpView.isHidden = false
                self.levelUpLabel.isHidden = false
                self.congratLabel.isHidden = false
                self.configureLevelUpLabel(userLevel: response.result?.userStat.level ?? 0)
                if response.result?.avatarUnlockAvailable ?? false {
                    self.newAvatarAvailabelLabel.isHidden = false
                    self.congratLabel.isHidden = true
                }
            }
        }
    }
    
    private func configureLevelUpLabel(userLevel: Int) {
        let text = "\(userLevel - 1) ⭢ \(userLevel)"
        let attributedString = NSMutableAttributedString(string: text)
        let textLength = text.count
        let startLocation = 4
        
        let range = NSRange(location: startLocation, length: textLength - startLocation)
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "secondary500")!, range: range)
        
        levelUpLabel.attributedText = attributedString
    }
    
    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countdownValue > 0 {
                self.countdownValue -= 1
            } else {
                timer.invalidate()
                self.navigateToHome()
            }
        }
    }
    
    private func showMoveToGroupPopUpView() {
        let dialog = DialogTypeChoice(
            title: "그룹 게시판 업로드 완료",
            subtitle: "5초 후 자동으로 홈 이동",
            leftButtonTitle: "홈으로 이동",
            rightButtonTitle: "보러가기",
            leftAction: {
                self.navigateToHome()
            },
            rightAction: {
                self.navigateToGroup()
            }
        )
        
        view.addSubview(dialog)
        
        dialog.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(270)
            make.height.equalTo(157)
        }
        
        dialog.startCounting()
    }
    
    private func navigateToHome() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        
        guard let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else { return }
        
        let navController = UINavigationController(rootViewController: tabBarVC)
        navController.modalPresentationStyle = .fullScreen
        
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
    
    private func navigateToGroup() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else { return }

        tabBarVC.selectedIndex = 2

        let groupStoryboard = UIStoryboard(name: "Group", bundle: nil)
        guard let groupListVC = groupStoryboard.instantiateViewController(withIdentifier: "GroupListViewController") as? GroupListViewController else { return }

        if let roomId = realmManager.getRoomId(for: alarmId) {
            groupListVC.roomIdToNavigate = roomId
            groupListVC.shouldNavigateToGroupCalendar = true
        }

        if let groupListNavController = tabBarVC.viewControllers?[2] as? UINavigationController {
            groupListNavController.setViewControllers([groupListVC], animated: true)
        }

        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()

        self.dismiss(animated: true, completion: nil)
    }


    
    
    private func setLottieAnimation() {
        let animation = LottieAnimation.named("progress")
        progressBar.animation = animation
        progressBar.loopMode = .loop
        progressBar.animationSpeed = 1
        progressBar.play()
    }
    
    private func updateUIForFailure(message: String = "인식에 실패했어요😢", buttonTitle: String = "다시 촬영하기", action: Selector = #selector(filmAgainButtonTapped(_:))) {
        statusLabel.text = message
        filmAgainButton.isHidden = false
        filmAgainButton.setTitle(buttonTitle, for: .normal)
        filmAgainButton.removeTarget(nil, action: nil, for: .allEvents)
        filmAgainButton.addTarget(self, action: action, for: .touchUpInside)
    }
    
    // MARK: - @
    @IBAction func filmAgainButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc private func navigateToHomeAction() {
        navigateToHome()
    }
}
