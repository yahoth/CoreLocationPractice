//
//  MainViewController.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 1/31/24.
//

import UIKit
import CoreLocation
import Combine
import MapKit

class MainViewController: UIViewController {
    // Model
    let locationManager = LocationManager()
    var subscriptions = Set<AnyCancellable>()

    // UI Component
    var startButton: UIButton!
    var stopButton: UIButton!
    var resetButton: UIButton!
    var hStackView: UIStackView!
    var collectionView: UICollectionView!
    var mapView: MKMapView!

    // CollectionView Datasource
    var datasource: UICollectionViewDiffableDataSource<Section, Log>!
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setCollectionView()
        configureDatasource()
        setMapView()
        setHStackView()
        setButton()
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
        locationManager.$logs
            .receive(on: DispatchQueue.main)
            .sink { logs in
                self.applySnapshot(logs: logs)
            }.store(in: &subscriptions)
    }
}


// CollectionView 관련 코드
extension MainViewController {

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
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear

        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
}

//UI Components 관련 코드
extension MainViewController {

    func setMapView() {
        mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserTrackingButton = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setHStackView() {
        hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.spacing = 20
        hStackView.distribution = .fillEqually
        hStackView.translatesAutoresizingMaskIntoConstraints = false
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
        view.addSubview(mapView)
        view.addSubview(collectionView)
        view.addSubview(hStackView)
        [startButton, stopButton, resetButton].forEach(hStackView.addArrangedSubview(_:))

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.widthAnchor),

            collectionView.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor),
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
        locationManager.start()
    }
    @objc func stopButtonTapped() {
        locationManager.stop()
    }
    @objc func resetButtonTapped() {
        locationManager.logs = []
    }

}
