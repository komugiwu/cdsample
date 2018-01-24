//
//  StudentViewController.swift
//  coredatasample
//
//  Created by ITI on 2017/05/26.
//  Copyright © 2017年 Masami Suzuki. All rights reserved.
//

import UIKit
import CoreData

class StudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var frcStudent: NSFetchedResultsController = { () -> NSFetchedResultsController<Students> in
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest<Students> = Students.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    lazy var frcClub: NSFetchedResultsController = { () -> NSFetchedResultsController<Clubs> in
        let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest<Clubs> = Clubs.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getClubsData()
        getStudentsData()
    }

    func getClubsData() {
        do {
            try frcClub.performFetch()
            if frcClub.fetchedObjects?.count == 0 {
                createClubsDemoData()
            }
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func getStudentsData() {
        do {
            try frcStudent.performFetch()
            if frcStudent.fetchedObjects?.count == 0 {
                createStudentsDemoData()
            }
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func createClubsDemoData() {
        let clubList = [["野球部", 32000, "花田球場", "火水"],
                        ["サッカー部", 25000, "日野グラウンド", "月木金"],
                        ["テニス部", 18000, "千代田コート", "水"]]
        
        for clubData in clubList {
            let club = NSEntityDescription.insertNewObject(forEntityName: "Clubs", into: frcStudent.managedObjectContext) as! Clubs
            club.name = clubData[0] as? String
            club.money = Int32(clubData[1] as! Int)
            club.place = clubData[2] as? String
            club.schedule = clubData[3] as? String
        }
        
        do {
            try frcClub.managedObjectContext.save()
        } catch {
            fatalError(error as! String)
        }
    }
    
    func createStudentsDemoData() {
        let studentList = [[1, "佐藤", 29, "野球部"],
                           [2, "田中", 20, "サッカー部"],
                           [3, "中西", 37, "野球部"],
                           [4, "鈴木", 24, "野球部"],
                           [5, "高橋", 21, "サッカー部"],
                           [6, "伊藤", 30, "テニス部"]]
        
        for studentData in studentList {
            let student = NSEntityDescription.insertNewObject(forEntityName: "Students", into: frcStudent.managedObjectContext) as! Students
            student.id = Int32(studentData[0] as! Int)
            student.name = studentData[1] as? String
            student.age = Int16(studentData[2] as! Int)
            
            //所属部のオブジェクトを検索し、clubプロパティに設定する。
            frcClub.fetchRequest.predicate = NSPredicate(format:"name = %@", studentData[3] as! String)
            do {
                try frcClub.performFetch()
                student.club = frcClub.fetchedObjects?[0]
            } catch {
                fatalError(error as! String)
            }
        }
        
        do {
            try frcStudent.managedObjectContext.save()
        } catch {
            fatalError(error as! String)
        }
    }
    
    // MARK: - UITableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frcStudent.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for:indexPath) as UITableViewCell
        
        let student = frcStudent.object(at: indexPath)
        
        cell.textLabel?.text = "id.\(student.id)　\(student.name!)　\(student.age) \(student.club!.name!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            do {
                let cellData = frcStudent.object(at: indexPath)
                frcStudent.managedObjectContext.delete(cellData)
                try frcStudent.managedObjectContext.save()
            } catch {
                print("Fetching Failed.")
            }
        }
    }
    
    // MARK: - Fetched Results Controller Delegate Methods
    
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
