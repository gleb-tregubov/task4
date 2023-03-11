//
//  ViewController.swift
//  task4
//
//  Created by Gleb Tregubov on 11.03.2023.
//

import UIKit

class ViewController: UIViewController {
    
    private struct CheckItem: Hashable {
        let number: Int
        var check: Bool
    }

    private enum TableSection: Hashable {
        case main
    }
    
    private lazy var tableView = UITableView(frame: view.bounds, style: .insetGrouped)
    
    private lazy var tableViewDataSource: UITableViewDiffableDataSource<TableSection, CheckItem> = {
        let dataSource = UITableViewDiffableDataSource<TableSection, CheckItem>(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
                return UITableViewCell(style: .value1, reuseIdentifier: String(describing: UITableViewCell.self))
            }
            cell.textLabel?.text = "\(item.number)"
            cell.accessoryView = item.check ? UIImageView(image: UIImage.checkmark) : nil
            return cell
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.delegate = self
        view.addSubview(tableView)
        configureInitialDiffableSnapshot()
        
        title = "Task 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffle))
    }
    
    func configureInitialDiffableSnapshot() {
        let items = (0...30).map { CheckItem(number: $0, check: false) }
        var snapshot = NSDiffableDataSourceSnapshot<TableSection, CheckItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        
        tableViewDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc
    func shuffle() {
        var snp = tableViewDataSource.snapshot()
        var items = snp.itemIdentifiers(inSection: .main)
        
        items.shuffle()
        
        snp.deleteAllItems()
        snp.appendSections([.main])
        snp.appendItems(items, toSection: .main)
        tableViewDataSource.apply(snp, animatingDifferences: true)
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var snp = tableViewDataSource.snapshot()
        var items = snp.itemIdentifiers(inSection: .main)
        
        if !(items[indexPath.row].check) {
            items[indexPath.row].check.toggle()
            
            snp.deleteAllItems()
            snp.appendSections([.main])
            snp.appendItems(items, toSection: .main)
            
            guard indexPath.row > 0 else {
                tableViewDataSource.apply(snp, animatingDifferences: false)
                return
            }
            snp.moveItem(items[indexPath.row], beforeItem: items[0])
            tableViewDataSource.apply(snp, animatingDifferences: true)
        } else {
            items[indexPath.row].check.toggle()
            
            snp.deleteAllItems()
            snp.appendSections([.main])
            snp.appendItems(items, toSection: .main)
            tableViewDataSource.apply(snp, animatingDifferences: false)
        }
    }
}
