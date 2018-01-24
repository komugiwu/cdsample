//
//  ViewController.swift
//  coredatasample
//
//  Created by ITI on 2017/05/24.
//  Copyright © 2017年 Masami Suzuki. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var taskTableView: UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<Task> in 
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true),
                                        NSSortDescriptor(key: "date", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: "category",
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
    }
    
    func getData() {
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    // MARK: - prepare Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let destinationViewController = segue.destination as? AddTaskViewController else {
            return
        }
        
        if let indexPath = taskTableView.indexPathForSelectedRow, segue.identifier == "SegueEditTaskViewController" {
            // 編集したいデータを取得
            let cellData = fetchedResultsController.object(at: indexPath)
            destinationViewController.task = cellData
        }
    }
    
    // MARK: - UITableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = taskTableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        let cellData = fetchedResultsController.object(at: indexPath)
        cell.taskLabel.text = "\(cellData.name!)"
        cell.timeLabel.text = convertStringFromDate(date: cellData.date!)
        
        return cell
    }
    
    func convertStringFromDate(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date as Date)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            do {
                let cellData = fetchedResultsController.object(at: indexPath)
                fetchedResultsController.managedObjectContext.delete(cellData)
                try fetchedResultsController.managedObjectContext.save()
            } catch {
                print("Fetching Failed.")
            }
        }
    }
    
    // MARK: - Fetched Results Controller Delegate Methods
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            taskTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            taskTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        taskTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        taskTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                taskTableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                taskTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                let cell = taskTableView.cellForRow(at: indexPath) as! TaskTableViewCell
                configureCell(cell: cell, atIndexPath: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                taskTableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                taskTableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func configureCell(cell: TaskTableViewCell, atIndexPath indexPath: IndexPath) {
        // Fetch Record
        let record = fetchedResultsController.object(at: indexPath)
        
        // Update Cell
        if let name = record.value(forKey: "name") as? String {
            cell.taskLabel.text = name
        }
        if let date = record.value(forKey: "date") as? String {
            cell.timeLabel.text = date
        }
    }
}

