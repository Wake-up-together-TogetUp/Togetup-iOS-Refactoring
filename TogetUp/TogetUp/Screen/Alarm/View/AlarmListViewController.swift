//
//  ViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit

class AlarmListViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private lazy var leadingDistance: NSLayoutConstraint = {
        return underLineView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor)
    }()
    
    private lazy var underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "primary300")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
        customSegmentedControl()
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
        
        // 오토레이아웃
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
    
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        let segmentIndex = CGFloat(sender.selectedSegmentIndex)
                let segmentWidth = sender.frame.width / CGFloat(sender.numberOfSegments)
                let leadingDistance = segmentWidth * segmentIndex
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.leadingDistance.constant = leadingDistance
                    self?.view.layoutIfNeeded()
                })
    }
    
    
    @IBAction func createAlarmBtnTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "CreateAlarmViewController") as? CreateAlarmViewController else { return }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        
        present(navigationController, animated: true)
    }
    
}

