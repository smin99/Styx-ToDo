//
//  MainViewController.swift
//  Styx
//
//  Created by HwangSeungmin on 12/12/18.
//  Copyright © 2018 Min. All rights reserved.
//

import UIKit
import EZLoadingActivity
import SwiftMessages
import SideMenu

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
//    // Test case
//    let label1 = Label(ID: 1, Title: "", ColorID: 1)//  (ID: 1, Title: "homework", ColorID: 1)
//    let label2 = Label(ID: 2, Title: "project", ColorID: 4)
//    let task1 = Task(Title: "Review hw3", Due: Date(timeIntervalSinceNow: 30000000), Notif: 1, LabelID: 1)  // case 1: task not due
//    let task2 = Task(Title: "Work on project", Due: Date(timeIntervalSinceNow: 2000000), LabelID: 2)    // case 2: task not due
//    let task3 = Task(Title: "Read chapter 3", Due: Date(timeIntervalSinceNow: -3000), LabelID: 1)   // case 3: task due
//    let task4 = Task(Title: "Write journal", Due: Date(timeIntervalSinceNow: -1000), LabelID: 1)    // case 4: task due
//    lazy var tasks: [Task] = [task1, task2, task3, task4]
    
    var names = [ "AAA", "BBB", "CC" ]
    
    static var Database: TaskDBProtocol!
    static var mainView: MainViewController!
    
    var labelList: Array<Label>!
    var taskList: Array<Task>!
    var listList: Array<List>!
    var imageList: Array<Image>!
        
    var isInitData: Bool = false
    
    // passed from side menu: if not given, set it to 0
    var labelIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.mainView = self
        
        // Initialize DB Object
        if(MainViewController.Database == nil) {
            if let dataUrl = FileUtil.getDataFolder() {
                let dbUrl = dataUrl.appendingPathComponent("todo.sqlite3")
                MainViewController.Database = TaskDB(dbPath: dbUrl.absoluteString)
            }
        }
        
        // Initialize if the DB is not opened
        if MainViewController.Database != nil && !MainViewController.Database.IsDBOpened {
            let bOpen = MainViewController.Database.OpenDB()
            print("DBOpen Return: \(bOpen), isOpen: \(MainViewController.Database.IsDBOpened), Error Message: \(MainViewController.Database.LastErrorMessage)")
        }
        
        // SideMenu Initialization
        SideMenuManager.default.menuPushStyle = .defaultBehavior
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = view.frame.width * 0.8
        if let sideMenu = storyboard?.instantiateViewController(withIdentifier: "leftSideMenu") {
            SideMenuManager.default.menuLeftNavigationController = sideMenu as? UISideMenuNavigationController
            
            SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
//        let rightButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: showEditing(sender: editBarButton))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("View will appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("View will disappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        DispatchQueue.global().async {
            
            self.labelList = MainViewController.Database.GetLabelList()
            self.taskList = MainViewController.Database.GetTaskList()
            self.listList = MainViewController.Database.GetListList()
            self.imageList = MainViewController.Database.GetImageList()
            
            // when labelList is empty, make a test case
            if self.labelList.count == 0 {
                
                /* first time to use the app: initialize empty label
                 _ = MainViewController.Database.UpsertLabel(label: Label(ID: 0, Title: "New Label", ColorID: 0))
                 
                */
                
                _ = MainViewController.Database.UpsertLabel(label: Label(ID: 0, Title: "Homework", ColorID: 0))
                let id1 = MainViewController.Database.UpsertLabel(label: Label(ID: 0, Title: "Project", ColorID: 0))
                let id2 = MainViewController.Database.UpsertTask(task: Task(ID: 0, Title: "Chapter 3", Due: Date(), Detail: "", Notif: 0, isNotif: false, LabelID: id1, isDone: false, isDeleted: false))
                _ = MainViewController.Database.UpsertList(list: List(ID: 0, TaskID: id2, Title: "34", isDone: false))
                _ = MainViewController.Database.UpsertList(list: List(ID: 0, TaskID: id2, Title: "35", isDone: true))
                _ = MainViewController.Database.UpsertList(list: List(ID: 0, TaskID: id2, Title: "36", isDone: false))
                _ = MainViewController.Database.UpsertList(list: List(ID: 0, TaskID: id2, Title: "37", isDone: false))
                _ = MainViewController.Database.UpsertTask(task: Task(ID: 0, Title: "Chapter 5", Due: Date(), Detail: "", Notif: 0, isNotif: false, LabelID: id1))
                _ = MainViewController.Database.UpsertTask(task: Task(ID: 0, Title: "Chapter 6", Due: Date(), Detail: "", Notif: 0, isNotif: false, LabelID: id1))
                _ = MainViewController.Database.UpsertLabel(label: Label(ID: 0, Title: "Shopping List", ColorID: 0))
                self.tableView.reloadData()
            }
            
            // Map Task Object to the Label Object
            for task in self.taskList {
                if let index = self.labelList.index(where: { $0.ID == task.LabelID}){
                    self.labelList[index].taskList.append(task)
                }
            }
            
            // Map List Object to the corresponding Task Obejct
            for list in self.listList {
                if let index = self.taskList.index(where: {$0.ID == list.TaskID}) {
                    self.taskList[index].listList.append(list)
                }
            }
            
            // Map Image Object to the corresponding Task Object
            for image in self.imageList {
                if let index = self.taskList.index(where: {$0.ID == image.TaskID}) {
                    self.taskList[index].imageList.append(image)
                }
            }
            
            DispatchQueue.main.sync {
                EZLoadingActivity.hide()
                
                self.isInitData = true
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View did disappear")
        
        stopAvoidingKeyboard()  // Stop changing the view size when keyboard disappear/appear
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if labelList == nil { return 0 }
        
        return labelList[labelIndex].taskList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // count the list completed and save it
        var numListCompleted = 0
        for list in labelList[labelIndex].taskList[indexPath.row].listList {
            if list.isDone { numListCompleted = numListCompleted + 1 }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell") as! TaskTableViewCell
        cell.titleLabel.text = labelList[labelIndex].taskList[indexPath.row].Title
        cell.dueLabel.text = labelList[0].taskList[indexPath.row].Due.toString(dateformat: "MM-DD-YY")
        
        let progressFloat: Float = numListCompleted == 0 ? 0.0 : Float(numListCompleted / labelList[labelIndex].taskList[indexPath.row].listList.count)
        cell.taskProgressBar.progress = progressFloat
        cell.taskProgressPercentageLabel.text = String(format: "%.2f", progressFloat * 100) + " %"
        
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let _ = tableView.cellForRow(at: indexPath) as? LabelTableViewCell {
//            if let openedIndexPath = openedLabelIndex {
//                labelList[openedIndexPath.row].isOpened = false
//                openedLabelIndex = nil
//                if openedIndexPath == indexPath {
//                    tableView.reloadData()
//                    return
//                }
//            }
//
//            if labelList[indexPath.row].taskList.count > 0 {
//                labelList[indexPath.row].isOpened = true
//                openedLabelIndex = indexPath
//            }
//            tableView.reloadData()
//        }
        let viewController = TaskTableViewController()
        viewController.taskTitle = taskList[indexPath.row].Title
        viewController.taskIndex = indexPath.row
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Edit Bar Button: Change into Editing mode
    @IBAction func tableEditing(_ sender: Any) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        } else {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }
    
    // Label Bar Button: Modally present side menu for labels
    @IBAction func labelSideMenu(_ sender: Any) {
        if let left = SideMenuManager.default.menuLeftNavigationController {
            present(left, animated: true, completion: nil)
        }
    }
    
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let view: ConfirmDialogView = try! SwiftMessages.viewFromNib()
            view.configureDropShadow()
            
            view.yesAction = {
                let id: Int64 = self.taskList[indexPath.row].ID
                self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                _ = MainViewController.Database.DeleteTask(id: id)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                SwiftMessages.hide()
                tableView.reloadData()
            }
            
            view.cancelAction = {
                SwiftMessages.hide()
            }
            
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
            config.duration = .forever
            config.presentationStyle = .center
            config.dimMode = .gray(interactive: true)
            view.initControl()
            SwiftMessages.show(config: config, view: view)
        }
    }
}