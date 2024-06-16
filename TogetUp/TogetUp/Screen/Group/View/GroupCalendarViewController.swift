//
//  GroupCalendarViewController.swift
//  TogetUp
//
//  Created by nayeon  on 6/14/24.
//

import UIKit
import SnapKit
import FSCalendar

class GroupCalendarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
    }
    
    // MARK: - Properties
    private let previousMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendarLeft"), for: .normal)
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendarRight"), for: .normal)
        return button
    }()
    
    private let headerSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private var rightCharacter: UIImageView = {
        let img = UIImageView(image: UIImage(named: "itemR_chick"))
        return img
    }()
    
    private let leftCharacter: UIImageView = {
        let img = UIImageView(image: UIImage(named: "itemL_chick"))
        return img
    }()
    
    private let centerCharacter: UIImageView = {
        let img = UIImageView(image: UIImage(named: "C_chick"))
        return img
    }()
    
    private let calendarView: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scope = .week
        calendar.headerHeight = 52
        calendar.appearance.headerDateFormat = "YYYY년 MM월 W주차"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleAlignment = .left
        calendar.appearance.headerTitleOffset = CGPoint(x: -UIScreen.main.bounds.width / 5, y: 0)
        calendar.backgroundColor = .white
        return calendar
    }()
    
    private let toggleCalendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setImage(UIImage(named: "chevron-down"), for: .normal)
        button.tintColor = UIColor(named: "neutral400")
        button.layer.cornerRadius = 20
        return button
    }()
    
    private var backGroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "bg_chick")
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let numberOfColumns: CGFloat = 2
        let itemWidth = (UIScreen.main.bounds.width - 20 * 2 - (numberOfColumns - 1) * layout.minimumInteritemSpacing) / numberOfColumns
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(backGroundImage)
        view.addSubview(calendarView)
        view.addSubview(headerSeparatorView)
        view.addSubview(toggleCalendarButton)
        view.addSubview(collectionView)
        view.addSubview(rightCharacter)
        view.addSubview(leftCharacter)
        view.addSubview(centerCharacter)
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        setupCustomHeader()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "secondary050")

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "그룹 캘린더"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingButtonTapped))
    }
    
    private func setupCustomHeader() {
        let headerView = calendarView.calendarHeaderView
        headerView.backgroundColor = UIColor(named: "secondary050")
        headerView.addSubview(previousMonthButton)
        headerView.addSubview(nextMonthButton)
        
        previousMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(headerView)
            $0.trailing.equalTo(nextMonthButton).offset(-40)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(headerView)
            $0.trailing.equalTo(headerView).offset(-8)
        }
        
        headerSeparatorView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
    
    private func setupConstraints() {
        setupCustomHeader()
        calendarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.leading.trailing.equalToSuperview().inset(0)
            $0.height.equalTo(300)
        }
        
        toggleCalendarButton.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(-10)
            $0.leading.trailing.equalToSuperview().offset(0)
            $0.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(toggleCalendarButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(0)
        }
        
        backGroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        leftCharacter.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.equalTo(104)
            $0.left.equalTo(view.snp.left)
            $0.centerY.equalTo(view.snp.centerY).offset(104)
        }
        
        rightCharacter.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.equalTo(104)
            $0.right.equalTo(view.snp.right)
            $0.centerY.equalTo(view.snp.centerY).offset(-104)
        }
        
        centerCharacter.snp.makeConstraints {
            $0.width.equalTo(153)
            $0.height.equalTo(160)
            $0.centerX.equalTo(view.snp.centerX)
            $0.bottom.equalTo(view.snp.bottom).inset(0)
        }
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        toggleCalendarButton.addTarget(self, action: #selector(toggleCalendarScope), for: .touchUpInside)
        previousMonthButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
    }
    
    @objc private func toggleCalendarScope() {
      if self.calendarView.scope == .month {
        self.calendarView.setScope(.week, animated: true)
          self.calendarView.appearance.headerDateFormat = "YYYY년 MM월 W주차"
            toggleCalendarButton.setImage(UIImage(named: "chevron-down"), for: .normal)
        
      } else {
        self.calendarView.setScope(.month, animated: true)
        self.calendarView.appearance.headerDateFormat = "YYYY년 MM월"
          toggleCalendarButton.setImage(UIImage(named: "chevron-down"), for: .normal)
      }
    }
    
    @objc private func previousMonthTapped() {
        calendarView.setCurrentPage(calendarView.currentPage.previousMonth, animated: true)
    }
    
    @objc private func nextMonthTapped() {
        calendarView.setCurrentPage(calendarView.currentPage.nextMonth, animated: true)
    }
    
    @objc private func settingButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension GroupCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // MARK: - FSCalendarDelegate & DataSource
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
}

// MARK: - UICollectionViewDataSource
extension GroupCalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        cell.configure(with: UIImage(named: "missionDefault")!, text: "닉네임")
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GroupCalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
      calendarView.snp.updateConstraints {
        $0.height.equalTo(bounds.height)
      }
      self.view.layoutIfNeeded()
     }
}

// MARK: - Date Extension
extension Date {
    var previousMonth: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
    
    var nextMonth: Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
}


#Preview {
    let navigationController = UINavigationController(rootViewController: GroupCalendarViewController())
    return navigationController
}
