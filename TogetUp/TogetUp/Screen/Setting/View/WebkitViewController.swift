//
//  WebkitViewController.swift
//  TogetUp
//
//  Created by 이예원 on 5/10/24.
//

import UIKit
import WebKit
import SnapKit

class WebkitViewController: UIViewController {
    private let webView = WKWebView()
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
        loadWebPage()
    }
    
    private func setConstraints() {
        self.view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func loadWebPage() {
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
