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
    @IBOutlet weak var noExistingAlarmLabel: UILabel!
    @IBOutlet weak var setAlarmLabel: UILabel!
    
    private lazy var groupCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.frame.width - 40, height: 124)
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GroupAlarmCollectionViewCell.self, forCellWithReuseIdentifier: GroupAlarmCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private var bottomLineView = UIView().then {
        $0.backgroundColor = UIColor(named: "primary300")
    }
    
    // MARK: - Properties
    private let viewModel = AlarmListViewModel()
    private let disposeBag = DisposeBag()
    private let realmManger = RealmAlarmDataManager()
    var selectedAlarmId = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGroupCollectionView()
        bindLabels()
        fetchAndSaveAlarmsIfFirstLogin()
        fetchAndSaveGroupAlarmsIfFirstLogin()
        setUpNavigationBar()
        setCollectionViewFlowLayout()
        setGroupCollectionViewFlowLayout()
        personalCollectionViewItemSelected()
        groupCollectionViewItemSelected()
        setupSegmentedControl()
        setupBottomLineView()
        updateViewForSelectedSegment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchAlarmsFromRealm()
        setCollectionView()
        setGroupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBottomLinePosition(animated: false)
    }
    
    // MARK: - Custom Method
    private func bindLabels() {
        viewModel.isAlarmEmpty
            .map { !$0 }
            .bind(to: noExistingAlarmLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isAlarmEmpty
            .map { !$0 }
            .bind(to: setAlarmLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setupGroupCollectionView() {
        view.addSubview(groupCollectionView)
        
        NSLayoutConstraint.activate([
            groupCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            groupCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            groupCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            groupCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
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
    
    private func setGroupCollectionView() {
        self.groupCollectionView.delegate = nil
        self.groupCollectionView.dataSource = nil
        viewModel.getGroupAlarmList()
            .bind(to: groupCollectionView.rx.items(cellIdentifier: GroupAlarmCollectionViewCell.identifier, cellType: GroupAlarmCollectionViewCell.self)) { index, alarm, cell in
                cell.configure(with: alarm)
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchAndSaveGroupAlarmsIfFirstLogin() {
        if AppStatusManager.shared.isFirstLogin {
            viewModel.getAndSaveAlarmList(type: "group")
            AppStatusManager.shared.markAsLogined()
        }
    }
    
    private func personalCollectionViewItemSelected() {
        personalCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                let alarms = try? self.viewModel.alarms.value()
                guard let selectedAlarm = alarms?[indexPath.row] else { return }
                
                self.selectedAlarmId = selectedAlarm.id
                
                guard let vc = self.storyboard?.instantiateViewController(identifier: "EditAlarmViewController") as? EditAlarmViewController else { return }
                
                vc.alarmId = self.selectedAlarmId
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
    
    private func groupCollectionViewItemSelected() {
        groupCollectionView.rx.itemSelected
            .withLatestFrom(viewModel.getGroupAlarmList()) { (indexPath, groupAlarms) in
                (indexPath, groupAlarms)
            }
            .subscribe(onNext: { [weak self] indexPath, groupAlarms in
                guard let self = self else { return }
                
                guard indexPath.row < groupAlarms.count else { return }
                
                let selectedAlarm = groupAlarms[indexPath.row]
                self.selectedAlarmId = selectedAlarm.id
                
                guard let vc = self.storyboard?.instantiateViewController(identifier: "EditAlarmViewController") as? EditAlarmViewController else { return }
                
                vc.alarmId = self.selectedAlarmId
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
        viewModel.toggleAlarm(alarmId: alarm.id)
    }
    
    private func showDeleteAlert(for alarm: Alarm) {
        let alertController = UIAlertController(title: nil, message: "삭제하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAlarm(alarmId: alarm.id)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }
    
    private func showAlertForExcessiveAlarms() {
        let alertController = UIAlertController(title: "생성된 알람의 개수가 너무 많습니다!", message: "사용하지 않는 알람을 삭제해주세요", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func fetchAndSaveAlarmsIfFirstLogin() {
        if AppStatusManager.shared.isFirstLogin {
            viewModel.getAndSaveAlarmList(type: "personal")
            AppStatusManager.shared.markAsLogined()
        }
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width - 40, height: 124)
        layout.minimumLineSpacing = 16
        personalCollectionView.collectionViewLayout = layout
    }
    
    private func setGroupCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width - 40, height: 124)
        layout.minimumLineSpacing = 16
        groupCollectionView.collectionViewLayout = layout
    }
    
    private func setUpNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.text = "알람"
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
    private func setupSegmentedControl() {
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
    }
    
    private func setupBottomLineView() {
        view.addSubview(bottomLineView)
        updateBottomLinePosition(animated: false)
    }
    
    private func updateBottomLinePosition(animated: Bool) {
        let selectedIndex = CGFloat(segmentedControl.selectedSegmentIndex)
        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingDistance = segmentWidth * selectedIndex
        
        let updatePosition = {
            self.bottomLineView.frame = CGRect(
                x: leadingDistance,
                y: self.segmentedControl.frame.maxY + 8,
                width: segmentWidth,
                height: 2
            )
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: updatePosition)
        } else {
            updatePosition()
        }
    }
    
    private func updateViewForSelectedSegment() {
        if segmentedControl.selectedSegmentIndex == 0 {
            personalCollectionView.isHidden = false
            groupCollectionView.isHidden = true
        } else {
            personalCollectionView.isHidden = true
            groupCollectionView.isHidden = false
        }
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        let segmentIndex = CGFloat(sender.selectedSegmentIndex)
        let segmentWidth = sender.frame.width / CGFloat(sender.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        updateViewForSelectedSegment()
        updateBottomLinePosition(animated: true)
    }
    
    @IBAction func createAlarmBtnTapped(_ sender: Any) {
        if realmManger.countActivatedAlarms() > 64 {
            showAlertForExcessiveAlarms()
        } else {
            guard let vc = storyboard?.instantiateViewController(identifier: "EditAlarmViewController") as? EditAlarmViewController else { return }
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.isNavigationBarHidden = true
            navigationController.navigationBar.backgroundColor = .clear
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            
            present(navigationController, animated: true)
        }
    }
}
