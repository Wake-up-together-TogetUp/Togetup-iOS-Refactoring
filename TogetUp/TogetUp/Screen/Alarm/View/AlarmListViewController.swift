//
//  ViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class AlarmListViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var personalCollectionView: UICollectionView!
    @IBOutlet weak var addAlarmButton: UIButton!
    @IBOutlet weak var groupLockerView: UIView!
    
    // MARK: - Properties
    private let viewModel = AlarmListViewModel()
    private let disposeBag = DisposeBag()
    let realm = try! Realm()
    private lazy var leadingDistance: NSLayoutConstraint = {
        return underLineView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor)
    }()
    private lazy var underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "primary300")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var selectedAlarmId = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
        fetchAndSaveAlarmsIfFirstLaunch()
        setUpNavigationBar()
        customSegmentedControl()
        setCollectionViewFlowLayout()
        personalCollectionViewItemSelected()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchAlarmsFromRealm()
        setCollectionView()
        printScheduledLocalNotifications()
        printAllAlarms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Custom Method
    
    func printScheduledLocalNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                print("=================================")
                print("Identifier: \(request.identifier)")

                if let trigger = request.trigger as? UNCalendarNotificationTrigger, let nextTriggerDate = trigger.nextTriggerDate() {
                    print("Next trigger date: \(nextTriggerDate)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("Time interval trigger: \(trigger.timeInterval)")
                }

                print("Content: \(request.content.body)")
            }
        }
    }
    
    func printAllAlarms() {
        let realm = try! Realm() // Realm 인스턴스 생성 시 발생할 수 있는 예외를 무시
        let alarms = realm.objects(Alarm.self) // 모든 Alarm 객체를 조회

        // 조회된 Alarm 객체들을 순회하며 출력
        alarms.forEach { alarm in
            print("Alarm ID: \(alarm.id), Name: \(alarm.name), Is Activated: \(alarm.isActivated), Is Alarmed: \(alarm.isAlarmed)")
            // 필요에 따라 더 많은 필드를 출력할 수 있습니다.
        }
    }

    private func customUI () {
        groupLockerView.layer.cornerRadius = 12
    }
    
    private func setCollectionView() {
        self.personalCollectionView.delegate = nil
        self.personalCollectionView.dataSource = nil
        viewModel.alarms.bind(to: personalCollectionView.rx.items(cellIdentifier: AlarmListCollectionViewCell.identifier, cellType: AlarmListCollectionViewCell.self)) { index, alarm, cell in
            cell.setAttributes(with: alarm)
            cell.onDeleteTapped = { [weak self] in
                self?.showDeleteAlert(for: alarm)
            }
            cell.onToggleSwitch = { [weak self] in
                self?.editIsActivatedToggle(for: alarm)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func personalCollectionViewItemSelected() {
        personalCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                let alarms = try? self.viewModel.alarms.value()
                guard let selectedAlarm = alarms?[indexPath.row] else { return }
                
                self.selectedAlarmId = selectedAlarm.id
                
                guard let vc = self.storyboard?.instantiateViewController(identifier: "EditAlarmViewController") as? EditAlarmViewController else { return }
                
                vc.alarmId = selectedAlarmId
                vc.navigatedFromScreen = "AlarmList"
                
                let navi = UINavigationController(rootViewController: vc)
                navi.modalPresentationStyle = .fullScreen
                navi.isNavigationBarHidden = true
                navi.navigationBar.backgroundColor = .clear
                navi.interactivePopGestureRecognizer?.isEnabled = true
                
                self.present(navi, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func editIsActivatedToggle(for alarm: Alarm) {
        viewModel.editAlarmToggle(alarmId: alarm.id)
    }
    
    private func showDeleteAlert(for alarm: Alarm) {
        let alertController = UIAlertController(title: nil, message: "삭제하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAlarm(alarmId: alarm.id)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func fetchAndSaveAlarmsIfFirstLaunch() {
        if AppStatusManager.shared.isFirstLaunch {
            viewModel.getAndSaveAlarmList(type: "personal")
            AppStatusManager.shared.markAsLaunched()
        }
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: personalCollectionView.bounds.width, height: 124)
        layout.minimumLineSpacing = 16
        personalCollectionView.collectionViewLayout = layout
    }
    
    private func setUpNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.text = "알람"
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
    private func customSegmentedControl() {
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "neutral400")!,
            NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)!
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)!
        ], for: .selected)
        
        self.view.addSubview(underLineView)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        underLineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            underLineView.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            underLineView.heightAnchor.constraint(equalToConstant: 2),
            leadingDistance,
            underLineView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments))
        ])
    }
    
    // MARK: - @
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        let segmentIndex = CGFloat(sender.selectedSegmentIndex)
        let segmentWidth = sender.frame.width / CGFloat(sender.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.leadingDistance.constant = leadingDistance
            self?.view.layoutIfNeeded()
        })
        
        if sender.selectedSegmentIndex == 0 {
            self.personalCollectionView.isHidden = false
            self.addAlarmButton.isHidden = false
            self.groupLockerView.isHidden = true
        } else {
            self.personalCollectionView.isHidden = true
            self.addAlarmButton.isHidden = true
            self.groupLockerView.isHidden = false
        }
    }
    
    @IBAction func createAlarmBtnTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "EditAlarmViewController") as? EditAlarmViewController else { return }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        present(navigationController, animated: true)
    }
}
