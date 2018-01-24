//
//  ClubsViewController.swift
//  coredatasample
//
//  Created by ITI on 2017/05/26.
//  Copyright © 2017年 Masami Suzuki. All rights reserved.
//

import UIKit
import CoreData

class ClubsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var frcClub: NSFetchedResultsController = { () -> NSFetchedResultsController<Clubs> in
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest<Clubs> = Clubs.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "name",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getClubsData()
    }
    
    func getClubsData() {
        do {
            try frcClub.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return frcClub.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return frcClub.sections![section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frcClub.fetchedObjects![section].student?.count ?? 0
        //return frcClub.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClubCell", for:indexPath) as UITableViewCell
        
        let students = frcClub.fetchedObjects![indexPath.section].student!.allObjects
        let student = students[indexPath.row] as! Students
        cell.textLabel?.text = student.name
        
        return cell
    }
    
    /// MARK: - Fetched Results Controller Delegate Methods
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
}
