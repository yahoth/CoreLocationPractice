//
//  ViewController.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 1/31/24.
//

import UIKit
import CoreLocation
import Combine

class ViewController: UIViewController {

    let locationManager = LocationManager()
    var startButton: UIButton!
    var stopButton: UIButton!
    var hStackView: UIStackView!
    var collectionView: UICollectionView!
//    var log: [String] = []
    var datasource: UICollectionViewDiffableDataSource<Section, Log>!
    var subscriptions = Set<AnyCancellable>()
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setCollectionView()
        configureDatasource()
        setHStackView()
        setButton()
        setConstraints()
        bind()
        setNavigationItem()
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
extension ViewController {

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
extension ViewController {


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

        [startButton, stopButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 30
        }
    }

    func setConstraints() {
        view.addSubview(collectionView)
        view.addSubview(hStackView)
        [startButton, stopButton].forEach(hStackView.addArrangedSubview(_:))

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: hStackView.topAnchor),

            hStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            hStackView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    @objc func startButtonTapped() {
        locationManager.start()
    }
    @objc func stopButtonTapped() {
        locationManager.stop()
    }
}

extension ViewController {
    func setNavigationItem() {
        let resetItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(resetLog))
        self.navigationItem.rightBarButtonItem = resetItem
    }

    @objc func resetLog() {
        locationManager.logs = []
    }
}
