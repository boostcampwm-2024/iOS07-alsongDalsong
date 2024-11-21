//
//  SelectMusicViewController.swift
//  alsongDalsong
//
//  Created by Minha Lee on 11/21/24.
//

import UIKit
import SwiftUI

class SelectMusicViewController: UIViewController {
    
    let selectMusicViewModel = SelectMusicViewModel()
    let selectCompleteButton = ASButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .asLightGray
        let selectMusicView = SelectMusicView(viewModel: selectMusicViewModel)
        let hostingController = UIHostingController(rootView: selectMusicView)
        addChild(hostingController)
        
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(selectCompleteButton)
        selectCompleteButton.translatesAutoresizingMaskIntoConstraints = false
        selectCompleteButton.setConfiguration(title: "선택 완료", backgroundColor: .asGreen)
        let safeArea = view.safeAreaLayoutGuide
    
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: selectCompleteButton.topAnchor, constant: -20),
            
            selectCompleteButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            selectCompleteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            selectCompleteButton.heightAnchor.constraint(equalToConstant: 45),
            selectCompleteButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30)
        ])
    }

}
