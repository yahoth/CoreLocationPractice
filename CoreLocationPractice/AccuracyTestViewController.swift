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
    var hStackView: UIStackView!
    var collectionView: UICollectionView!

    var labelsStackView: UIStackView!
    var totalMeasurement: UILabel!
    var invalidSpeed: UILabel!
    var invalidSpeedAccuracy: UILabel!
    var invalidCoordinateAccuracy: UILabel!
    var invalidAltitudeAccuracy: UILabel!

    var labels: [UILabel] {
        [totalMeasurement, invalidSpeed, invalidSpeedAccuracy, invalidCoordinateAccuracy, invalidAltitudeAccuracy]
    }

    // CollectionView Datasource
    var datasource: UICollectionViewDiffableDataSource<Section, Log>!
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setLabels()
        setLabelsStackView()
        setCollectionView()
        configureDatasource()
        setHStackView()
        setButton()
        setChangeModeButton()
        setConstraints()
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
    func setLabels() {
        totalMeasurement = UILabel()
        invalidSpeed = UILabel()
        invalidSpeedAccuracy = UILabel()
        invalidCoordinateAccuracy = UILabel()
        invalidAltitudeAccuracy = UILabel()

        labels.forEach {
            $0.font = .systemFont(ofSize: 15, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .left
            $0.numberOfLines = 1
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    func setLabelsStackView() {
        labelsStackView = UIStackView()
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 12
        labelsStackView.distribution = .fillEqually
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
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

    func setHStackView() {
        hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.spacing = 20
        hStackView.distribution = .fillEqually
        hStackView.translatesAutoresizingMaskIntoConstraints = false
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
        view.addSubview(labelsStackView)
        labels.forEach(labelsStackView.addArrangedSubview(_:))
        view.addSubview(collectionView)
        view.addSubview(hStackView)
        [startButton, stopButton, resetButton, changeModeButton].forEach(hStackView.addArrangedSubview(_:))

        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: labelsStackView.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: hStackView.topAnchor),

            hStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            hStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func startButtonTapped() {
        testManager.start()
    }
    @objc func stopButtonTapped() {
        testManager.stop()
    }
    @objc func resetButtonTapped() {
        testManager.logs = []
        testManager.invalidSpeed = 0
        testManager.invalidAltitude = 0
        testManager.invalidCoordinate = 0
        testManager.invalidSpeedAccuracy = 0
        testManager.totalMeasurement = 0
    }
}
