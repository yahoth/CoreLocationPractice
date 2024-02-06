//
//  AccuracyTestViewController.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 2/7/24.
//

import UIKit
import CoreLocation
import Combine

class AccuracyTestViewController: UIViewController {
    // Model
    let testManager = AccuracyTestManager()
    var subscriptions = Set<AnyCancellable>()

    // UI Component
    var startButton: UIButton!
    var stopButton: UIButton!
    var resetButton: UIButton!
    var changeModeButton: UIButton!
    let buttonHStackView = UIStackView()
    var collectionView: UICollectionView!
    var buttons: [UIButton] {
        [startButton, stopButton, resetButton, changeModeButton]
    }

    let invalidCountLabelsVStackView = UIStackView()
    var totalMeasurement = UILabel()
    var invalidSpeed = UILabel()
    var invalidSpeedAccuracy = UILabel()
    var invalidCoordinateAccuracy = UILabel()
    var invalidAltitudeAccuracy = UILabel()
    var invalidCountLabels: [UILabel] {
        [totalMeasurement, invalidSpeed, invalidSpeedAccuracy, invalidCoordinateAccuracy, invalidAltitudeAccuracy]
    }


    let speedInfoVStackView = UIStackView()
    var speed = UILabel()
    var topSpeed = UILabel()
    var averageSpeed = UILabel()
    var speedInfoLabels: [UILabel] {
        [speed, topSpeed, averageSpeed]
    }

    // CollectionView Datasource
    var datasource: UICollectionViewDiffableDataSource<Section, Log>!
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // CollectionView Configuring
        setCollectionView()
        configureDatasource()

        // UI Setup
        invalidCountLabels.forEach{ set($0, textAlignment: .left) }
        set(invalidCountLabelsVStackView, axis: .vertical, spacing: 12)

        speedInfoLabels.forEach {set($0, textAlignment: .right) }
        set(speedInfoVStackView, axis: .vertical, spacing: 12)

        set(buttonHStackView, axis: .horizontal, spacing: 20)
        setButton()
        setChangeModeButton()

        // Auto-Layout
        setConstraints()

        // Data bind
        bind()
    }

    func applySnapshot(logs: [Log]) {
        var snapshot = datasource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(logs)
        datasource.apply(snapshot)
    }

    func bind() {
        testManager.$logs
            .receive(on: DispatchQueue.main)
            .sink { logs in
                self.applySnapshot(logs: logs.reversed())
            }.store(in: &subscriptions)

        testManager.$totalMeasurement
            .receive(on: DispatchQueue.main)
            .sink { totalCount in
                self.totalMeasurement.text = "total count: \(totalCount)"
            }.store(in: &subscriptions)

        testManager.$invalidSpeed
            .receive(on: DispatchQueue.main)
            .combineLatest(testManager.$invalidSpeedAccuracy, testManager.$invalidCoordinate, testManager.$invalidAltitude)
            .sink { speed, speedAccuracy, coordinate, altitude in
                self.invalidSpeed.text = "speed: \(speed)"
                self.invalidSpeedAccuracy.text = "speedAccuracy: \(speedAccuracy)"
                self.invalidCoordinateAccuracy.text = "coordinate: \(coordinate)"
                self.invalidAltitudeAccuracy.text = "altitude: \(altitude)"
            }.store(in: &subscriptions)

        testManager.$speedKMS
            .receive(on: DispatchQueue.main)
            .combineLatest(testManager.$speeds)
            .sink { speed, speeds in
                let topSpeed = speeds.max() ?? 0
                let averageSpeed = speeds.reduce(0, +) / Double(speeds.count)
                self.speed.text = "speed: \(String(format: "%.0f", speed))km/h"
                self.averageSpeed.text = "average: \(String(format: "%.0f", averageSpeed))km/h"
                self.topSpeed.text = "top: \(String(format: "%.0f", topSpeed))km/h"
            }.store(in: &subscriptions)
    }
}


// CollectionView 관련 코드
extension AccuracyTestViewController {

    func setCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configureDatasource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Log> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.text
            cell.contentConfiguration = content
        }

        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Log>()
        snapshot.appendSections([.main])
        snapshot.appendItems([])
        datasource.apply(snapshot)
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = true
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
}

//Test 통계 Components 관련 (Labels)
extension AccuracyTestViewController {
    func set(_ label: UILabel, textAlignment: NSTextAlignment) {
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.textAlignment = textAlignment
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension CLActivityType: CaseIterable {
    public static var allCases: [CLActivityType] {
        [.airborne, .automotiveNavigation, .fitness, .other, .otherNavigation]
    }

    var title: String {
        switch self {
        case .other:
            return "other"
        case .automotiveNavigation:
            return "automotiveNavigation"
        case .fitness:
            return "fitness"
        case .otherNavigation:
            return "otherNavigation"
        case .airborne:
            return "airborne"
        @unknown default:
            fatalError()
        }
    }
}

//UI Components 관련 코드
extension AccuracyTestViewController {

    func set(_ stackView: UIStackView, axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setChangeModeButton() {
        changeModeButton = UIButton()
        changeModeButton.setTitle("Change", for: .normal)
        changeModeButton.backgroundColor = .darkGray
        changeModeButton.translatesAutoresizingMaskIntoConstraints = false
        changeModeButton.layer.cornerRadius = 16

        let menu = CLActivityType.allCases.map { type in
            return UIAction(title: type.title) { _ in
                self.testManager.locationManager.activityType = type
                self.changeModeButton.setTitle(type.title, for: .normal)
            }
        }
        changeModeButton.menu = UIMenu(title: "Select Activity Type", options: .singleSelection, children: menu)
        changeModeButton.showsMenuAsPrimaryAction = true
    }

    func setButton() {
        startButton = UIButton()
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .blue
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        stopButton = UIButton()
        stopButton.setTitle("Stop", for: .normal)
        stopButton.backgroundColor = .red
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        resetButton = UIButton()
        resetButton.setImage(UIImage(systemName: "trash"), for: .normal)
        resetButton.backgroundColor = .red
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)

        [startButton, stopButton, resetButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 16
        }
    }

    func setConstraints() {
        [collectionView, invalidCountLabelsVStackView, buttonHStackView, speedInfoVStackView].forEach(view.addSubview(_:))

        invalidCountLabels.forEach(invalidCountLabelsVStackView.addArrangedSubview(_:))

        speedInfoLabels.forEach(speedInfoVStackView.addArrangedSubview(_:))

        buttons.forEach(buttonHStackView.addArrangedSubview(_:))


        NSLayoutConstraint.activate([
            invalidCountLabelsVStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            invalidCountLabelsVStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            invalidCountLabelsVStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            speedInfoVStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            speedInfoVStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            speedInfoVStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: invalidCountLabelsVStackView.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonHStackView.topAnchor),

            buttonHStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonHStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonHStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            buttonHStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func startButtonTapped() {
        testManager.start()
    }
    @objc func stopButtonTapped() {
        testManager.stop()
    }
    @objc func resetButtonTapped() {
        testManager.reset()
    }
}
