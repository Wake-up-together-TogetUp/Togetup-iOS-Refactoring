//
//  MissionPerformViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/24.
//

import UIKit
import RxSwift
import RxCocoa
import AudioToolbox
import AVFoundation
import RealmSwift

class MissionPerformViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var missionPerformButton: UIButton!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var missionBackgroundView: UIView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var alarmIconLabel: UILabel!
    @IBOutlet weak var alarmNameLabel: UILabel!
    @IBOutlet weak var missionObjectLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    // MARK: - Properties
    private let viewModel = MissionPerformViewModel()
    private let alarmListViewModel = AlarmListViewModel()

    private let disposeBag = DisposeBag()
    var objectEndpoint = ""
    var alarmIcon = ""
    var alarmName = ""
    var missionObject = ""
    var missionId = 0
    var alarmId = 0
    var isSnoozeActivated = false
    var isVibrate: Bool = true
    private var audioPlayer: AVAudioPlayer?
    private var vibrationTimer: Timer?
    private var countdownTimer: Timer?
    private var remainingTimeInSeconds: Int = 60
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        bindLabels()
        disableButtonIfNeeded()
        updateAlarmCompletedTime(alarmId: self.alarmId)
        completeMission()
    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        startCountdown()
//    }
    
    // MARK: - Custom Method
    private func updateAlarmCompletedTime(alarmId: Int) {
        let realm = try! Realm()
        
        guard let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) else {
            print("Alarm not found")
            return
        }
        
        try! realm.write {
            alarm.completedTime = Date()
        }
    }
    
    func completeMission() {
        let realm = try! Realm()
        guard let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) else { return }
        
        if !alarm.isRepeatAlarm() {
            deactivateAlarm(alarm)
        }
    }

    private func deactivateAlarm(_ alarm: Alarm) {
        alarmListViewModel.toggleAlarm(alarmId: alarm.id)
    }
    
    private func customUI() {
        self.missionPerformButton.layer.cornerRadius = 12
        self.missionPerformButton.layer.borderWidth = 2
        
        self.iconBackgroundView.layer.cornerRadius = 170
        self.iconBackgroundView.layer.borderWidth = 2
        
        self.missionBackgroundView.layer.cornerRadius = 12
        self.missionBackgroundView.layer.borderWidth = 2
        
        self.alarmIconLabel.text = alarmIcon
        self.alarmNameLabel.text = alarmName
        self.missionObjectLabel.text = missionObject
    }
    
    private func bindLabels() {
        viewModel.currentDate
            .bind(to: currentDateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentTime
            .bind(to: currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func loadSound() {
        guard let soundURL = Bundle.main.url(forResource: "alarmSound", withExtension: "mp3") else {
            print("File not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            
            if isVibrate {
                vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                })
            }
        } catch {
            print("Error loading audio file")
        }
    }
    
    private func stopSoundAndVibrate() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    private func startCountdown() {
        timerLabel.text = "1:00"
        timerLabel.textColor = UIColor(named: "primary500")
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.remainingTimeInSeconds -= 1
            
            if self.remainingTimeInSeconds == 0 {
                self.timerLabel.textColor = UIColor(named: "error500")
                timer.invalidate()
                disableMissionPerformButton()
                stopSoundAndVibrate()
            }
            
            let minutes = self.remainingTimeInSeconds / 60
            let seconds = self.remainingTimeInSeconds % 60
            let formattedTime = String(format: "%02d:%02d", minutes, seconds)
            self.timerLabel.text = formattedTime
        }
    }
    
    private func disableButtonIfNeeded() {
        let realm = try! Realm()
        
        guard let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) else { return }
        
        if let alarmTime = alarm.getAlarmTime() {
            let timeDifference = -alarmTime.timeIntervalSinceNow
            if timeDifference <= 60 {
                missionPerformButton.isEnabled = true
                loadSound()
                startCountdown()
            } else {
                disableMissionPerformButton()
            }
        }
    }
    
    private func disableMissionPerformButton() {
        missionPerformButton.isEnabled = false
        missionPerformButton.backgroundColor = UIColor(named: "primary100")
    }
    
    // MARK: - @
    @IBAction func performButtonTapped(_ sender: UIButton) {
        stopSoundAndVibrate()
        checkCameraAuthorizationStatus()
    }
    
    @IBAction func dismissMissionPage(_ sender: UIButton) {
        stopSoundAndVibrate()
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension MissionPerformViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func checkCameraAuthorizationStatus() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.presentImagePickerController()
                }
            }
        case .authorized:
            presentImagePickerController()
        case .restricted, .denied:
            showCameraAccessDeniedAlert()
        @unknown default:
            fatalError("Unknown camera authorization status")
        }
    }
    
    private func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(title: "카메라 권한이 거부되었습니다",
                                      message: "설정으로 이동해 카메라 권한을 허용해 주세요",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func presentImagePickerController() {
        DispatchQueue.main.async {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let capturedImage = info[.editedImage] as? UIImage {
                if let nextVC = self.storyboard?.instantiateViewController(identifier: "CapturedImageViewController") as? CapturedImageViewController {
                    nextVC.image = capturedImage
                    nextVC.missionEndpoint = self.objectEndpoint
                    nextVC.missionId = self.missionId
                    nextVC.alarmId = self.alarmId
                    self.present(nextVC, animated: true, completion: nil)
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.dismiss(animated: true)
        }
    }
}
