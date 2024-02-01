//
//  ViewController.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 1/31/24.
//

import UIKit
import CoreLocation
import SnapKit

class ViewController: UIViewController {

    let locationManager = LocationManager()
    var startButton: UIButton!
    var stopButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setButton()
        setConstraints()
    }
}

//UI관련 코드
extension ViewController {
    func setButton() {
        startButton = UIButton()
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .blue
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)

        stopButton = UIButton()
        stopButton.setTitle("Stop", for: .normal)
        stopButton.backgroundColor = .red
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
    }

    func setConstraints() {
        view.addSubview(startButton)
        view.addSubview(stopButton)
        startButton.snp.makeConstraints { make in
            make.centerY.equalTo(view).offset(-30)
            make.horizontalEdges.equalTo(view).inset(50)
            make.height.equalTo(50)
        }

        stopButton.snp.makeConstraints { make in
            make.centerY.equalTo(view).offset(30)
            make.horizontalEdges.equalTo(view).inset(50)
            make.height.equalTo(50)
        }
    }
    @objc func startButtonTapped() {
        locationManager.start()
    }
    @objc func stopButtonTapped() {
        locationManager.stop()
    }

}

