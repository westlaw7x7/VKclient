//
//  CommunitiesTableViewController.swift
//  ProjectTestLocalUI
//
//  Created by Alexander Grigoryev on 25.08.2021.
//

import UIKit
import SDWebImage
import RealmSwift

class CommunitiesTableViewController: UITableViewController {
   
    @IBOutlet var addGroup: UIBarButtonItem!
//    MARK: Property for OPERATION
//    let myQueue: OperationQueue = {
//        let q = OperationQueue()
//        q.maxConcurrentOperationCount = 4
//        q.name = "asych.groups.load.parsing.savingToRealm.operation"
//        q.qualityOfService = .userInitiated
//        return q
//    }()
    
    var groupsfromRealm: Results<GroupsRealm>? {
        didSet {
            self.tableView.reloadData()
        }
    }
    var groupsNotification: NotificationToken?
    private let token = Session.instance.token
    private let groupsService = NetworkGroupsAdapter()
    private let viewModelFactory = GroupsViewModelFactory()
    private var groupsHolder = [GroupsObjects]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var viewModels: [GroupsViewModel] = []
    private var groupsAll: [GroupsObjects] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "GroupsTableViewCell", bundle: nil), forCellReuseIdentifier: "myGroupsCells")
        groupsService.getFriendsData(token: token) { [weak self] groups in
            guard let self = self else { return }
            self.groupsAll = groups
            self.viewModels = self.viewModelFactory.constructViewModels(from: groups)
            self.tableView.reloadData()
        }
        
        
        self.tableView.reloadData()
//        asyncOperationGroups()
//        loadFromDB()
    }
    
//    MARK: Function for OPERATION
//    private func asyncOperationGroups() {
//        let networkOperation = NetworkGroupsAsyncOperation(url: URL(string: "https://api.vk.com/method/groups.get")!,
//                                                           method: .get,
//                                                           parameters: [
//                                                            "access_token": token,
//                                                            "extended": "1",
//                                                            "fields": "photo_100",
//                                                            "v": "5.92"
//                                                        ])
//        myQueue.addOperation(networkOperation)
//
//        let parsingOperation = ParsingData()
//        parsingOperation.addDependency(networkOperation)
//        myQueue.addOperation(parsingOperation)
//
//        let saveToRealm = SavingGroupsToRealmAsyncOperation()
//        saveToRealm.addDependency(parsingOperation)
//        myQueue.addOperation(saveToRealm)
//    }
    
    private func loadFromDB() {
        
        groupsfromRealm = try? RealmService.load(typeOf: GroupsRealm.self)
        
        groupsNotification = groupsfromRealm?.observe(on: .main, { realmChange in
            switch realmChange {
            case .initial(let objects):
                if objects.count > 0 {
                    self.tableView.reloadData()
                }
                print(objects)
                
            case let .update(_, deletions, insertions, modifications ):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}),
                                          with: .none)
                self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}),
                                          with: .none)
                self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                          with: .none)
                self.tableView.endUpdates()
                self.tableView.reloadData()
            case .error(let error):
                print(error)
                
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        groupsNotification?.invalidate()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupsfromRealm?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myGroupsCells", for: indexPath)
        cell.textLabel?.text = groupsfromRealm?[indexPath.row].name
        cell.imageView?.sd_setImage(with: URL(string: (groupsfromRealm?[indexPath.row].photo)!))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100.0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do { tableView.deselectRow(at: indexPath, animated: true)}
        
    }
}


