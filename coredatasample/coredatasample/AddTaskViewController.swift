//
//  AddTaskViewController.swift
//  coredatasample
//
//  Created by ITI on 2017/05/24.
//  Copyright © 2017年 Masami Suzuki. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController {

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    var taskCategory = "ToDo"
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // taskに値が代入されていたら、textFieldとsegmentedControlにそれを表示
        if let task = task {
            taskTextField.text = task.name
            taskCategory = task.category!
            switch task.category! {
            case "ToDo":
                categorySegmentedControl.selectedSegmentIndex = 0
            case "Shopping":
                categorySegmentedControl.selectedSegmentIndex = 1
            case "Assignment":
                categorySegmentedControl.selectedSegmentIndex = 2
            default:
                categorySegmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    
    @IBAction func categoryChosen(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            taskCategory = "ToDo"
        case 1:
            taskCategory = "Shopping"
        case 2:
            taskCategory = "Assignment"
        default:
            taskCategory = "ToDo"
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func plusButtonTapped(_ sender: Any) {
        
        let taskName = taskTextField.text
        if taskName == "" {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        // 受け取った値が空であれば、新しいTask型オブジェクトを作成する
        if task == nil {
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
            task = NSManagedObject(entity:entity!,insertInto:context) as? Task
        }
        
        // 受け取ったオブジェクト、または、先ほど新しく作成したオブジェクトそのタスクのnameとcategoryに入力データを代入する
        if let task = task {
            task.name = taskName
            task.category = taskCategory
            task.date = NSDate()
        }
        
        // 変更内容を保存する
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
}
