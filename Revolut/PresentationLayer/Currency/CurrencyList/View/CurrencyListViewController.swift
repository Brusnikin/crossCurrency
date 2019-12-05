//
//  CurrencyListViewController.swift
//  Revolut
//
//  Created by Blashkin Georgiy on 12.11.2019.
//  Copyright © 2019 Blashkin Georgiy. All rights reserved.
//

import UIKit

protocol CurrencyListViewControllerProtocol {
	func configure(currency list: [PlainCurrency])
	func select(currency: PlainCurrency)
}

protocol CurrencyListViewControllerDelegate: class {
	func show(selected currency: PlainCurrency)
	func showCrossCurrencyList()
	func finishFlow()
}

typealias CurrencyListViewType = CurrencyListViewControllerProtocol & CurrencyListViewController

class CurrencyListViewController: UIViewController {

	// MARK: - Properties

	weak var delegate: CurrencyListViewControllerDelegate?
	let presenter: CurrencyListPresenterProtocol

	private let tableView = UITableView()
	private lazy var tableAdapter = CurrencyListTableAdapter(tableView: tableView)
	private var selectedCurrencyList = [PlainCurrency]()

	// MARK: - Construction

	init(presenter: CurrencyListPresenterProtocol) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("CurrencyListViewController")
	}

	// MARK: - Lifecycle

	override func loadView() {
		view = tableView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		tableAdapter.delegate = self

		tableView.separatorColor = .clear
		tableView.delegate = tableAdapter
		tableView.dataSource = tableAdapter
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.presentationController?.delegate = self
		navigationItem.hidesBackButton = true
	}
}

extension CurrencyListViewController: CurrencyListViewControllerProtocol {
	func configure(currency list: [PlainCurrency]) {
		tableAdapter.update(currency: list)
	}

	func select(currency: PlainCurrency) {
		selectedCurrencyList.append(currency)
		presenter.prepare(selected: currency)
	}
}

extension CurrencyListViewController: CurrencyListTableAdapterDelegate {
	func selected(currency: PlainCurrency) {
		selectedCurrencyList.append(currency)

		if selectedCurrencyList.count > 1 {
			presenter.cache(selected: selectedCurrencyList)
			delegate?.showCrossCurrencyList()
		} else {
			delegate?.show(selected: currency)
		}
	}
}

extension CurrencyListViewController: CurrencyListPresenterDelegate {
	func update(currencyList selected: [PlainCurrency]) {
		tableAdapter.select(currencyList: selected)
	}
}

extension CurrencyListViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		delegate?.finishFlow()
	}
}
