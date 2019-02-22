//
//  ViewController.swift
//  duplicity
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = .white
        label.text = "duplicity"
        return label
    }()

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            titleLabel .centerXAnchor.constraint(equalTo: view.centerXAnchor)
            //titleField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
            ])
    }
    
}

