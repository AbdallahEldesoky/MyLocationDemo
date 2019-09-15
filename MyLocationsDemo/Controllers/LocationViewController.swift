//
//  LocationViewController.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/10/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationViewController: UITableViewController {
    
    let cellIdenifier = "LocationCell"
    
    var managedObjectContex: NSManagedObjectContext!
    
    lazy var fetchedRequestController: NSFetchedResultsController<Location> = {
        
        let fetchRequest = NSFetchRequest<Location>()
        
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let categoryDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [dateSortDescriptor, categoryDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContex, sectionNameKeyPath: "category", cacheName: "locations")
        fetchedController.delegate = self
        
        return fetchedController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        fetchLocations()
    }
    
    deinit {
        fetchedRequestController.delegate = nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionInfo = fetchedRequestController.sections![section]
        return sectionInfo.name.uppercased()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedRequestController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedRequestController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdenifier, for: indexPath) as! LocationCell
        
        let location = fetchedRequestController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let location = fetchedRequestController.object(at: indexPath)
            
            location.deletePhotoFile()
            managedObjectContex.delete(location)
            
            do {
                try managedObjectContex.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //configure sectionLabel
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
        let sectionLabel = UILabel(frame: labelRect)
        sectionLabel.font = UIFont.boldSystemFont(ofSize: 11)
        sectionLabel.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        sectionLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        sectionLabel.backgroundColor = .clear
        
        //configure section separator
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        // add sectionLabel and separator to header view
        let headerViewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        let headerView = UIView(frame: headerViewRect)
        headerView.backgroundColor = UIColor(white: 0, alpha: 0.85)
       
        headerView.addSubview(sectionLabel)
        headerView.addSubview(separator)
        
        return headerView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditLocation" {
            
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContex
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                
                let location = fetchedRequestController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    private func fetchLocations() {
        
        do {
            try fetchedRequestController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }

    }
    
    
}


extension LocationViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("ControllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            print("NSFetchedResultsChangeInsert object")
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            print("NSFetchedResultsChangeDelete object")
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("NSFetchedResultsChangeUpdate object")
            
            let cell = tableView.cellForRow(at: indexPath!) as! LocationCell
            let location = controller.object(at: indexPath!) as! Location
            cell.configure(for: location)
            
        case .move:
            print("NSFetchedResultsChangeMove object")
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        
        case .insert:
            print("*** NSFetchedResultsChangeInsert section")
            
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        
        case .delete:
            print("*** NSFetchedResultsChangeDelete section")
            
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        
        case .update:
            print("*** NSFetchedResultsChangeUpdate section")
            
        case .move:
            print("*** NSFetchedResultsChangeMove section")
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("ControllerDidChangeContent")
        tableView.endUpdates()
    }
    
}
