//
//  MapViewController.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/11/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
   
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { notification in
                
                if self.isViewLoaded{
                    self.updateLocations()
                }
            }
        }
    }
    
    var locations = [Location]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        updateLocations()
        
        if !locations.isEmpty{
            locationsButtonPressed()
        }
        
    }
    
    private func updateLocations() {
        
        mapView.removeAnnotations(locations)
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
        
        mapView.addAnnotations(locations)
    }
    
    @IBAction func locationsButtonPressed() {
        
        let region = self.region(for: locations)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func userButtonPressed() {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    private func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        
        let region: MKCoordinateRegion
        
        switch annotations.count {
            
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            
        default:
            
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2, longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace, longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) ->
        MKAnnotationView? {
            
            guard annotation is Location else {
                return nil
            }
            
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
            if annotationView == nil {
                let pinView = MKPinAnnotationView(annotation: annotation,
                                                  reuseIdentifier: identifier)
                
                pinView.tintColor = UIColor(white: 0.0, alpha: 0.5)
                pinView.isEnabled = true
                pinView.canShowCallout = true
                pinView.animatesDrop = false
                pinView.pinTintColor = UIColor(red: 0.32, green: 0.82,
                                               blue: 0.4, alpha: 1)
                
                
                let rightButton = UIButton(type: .detailDisclosure)
                rightButton.addTarget(self,
                                      action: #selector(showLocationDetails(_:)),
                                      for: .touchUpInside)
                pinView.rightCalloutAccessoryView = rightButton
                
                annotationView = pinView
            }
            
            if let annotationView = annotationView {
                annotationView.annotation = annotation
                
                let button = annotationView.rightCalloutAccessoryView
                    as! UIButton
                if let index = locations.firstIndex(of: annotation
                    as! Location) {
                    button.tag = index
                }
            }
            return annotationView
    }
    
    @objc func showLocationDetails(_ sender: Any) {
        
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditLocation" {
            
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let locationToEdit = locations[button.tag]
            controller.locationToEdit = locationToEdit
        }
    }
}
