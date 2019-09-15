//
//  FirstViewController.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/6/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class CurrentLocationViewController: UIViewController {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var latitudeText: UILabel!
    @IBOutlet weak var longitudeText: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    
    
    var managedObjectContext: NSManagedObjectContext!
    
    let locationManager = CLLocationManager()
    var updatingLocation = false
    var fetchedLocation: CLLocation?
    var lastErrorLocation: Error?
   
    let geocoeder = CLGeocoder()
    var performReverseGeocoding = false
    var placemark: CLPlacemark?
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    var logoVisable = false
    var soundID: SystemSoundID = 0
    
    
    lazy var logoButton: UIButton = {
       
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "logo"), for: .normal)
            button.sizeToFit()
        button.addTarget(self, action: #selector(getLocationPressed(_:)), for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        loadSoundEffect(name: "Sound.caf")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = fetchedLocation!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    @IBAction func getLocationPressed(_ sender: Any) {
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if logoVisable {
            hideLogoView()
        }
        
        if updatingLocation {
            stopUpdaingLocation()
        } else {
            fetchedLocation = nil
            lastErrorLocation = nil
            startUpdatingLocation()
        }
    }
    
    private func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in setting", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateUI() {
        
        if let fetchedLocation = fetchedLocation {
        
            messageLabel.isHidden = true
            latitudeLabel.text = String(format: "%.8f", fetchedLocation.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", fetchedLocation.coordinate.longitude)
            tagButton.isHidden = false
            
            if let placemark = placemark {
                addressLabel.text = placemark.decode()
            } else if performReverseGeocoding {
                addressLabel.text = "Searching For Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
            addressLabel.isHidden = false
            latitudeText.isHidden = false
            longitudeText.isHidden = false
            
        } else {
            
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.isHidden = true
            tagButton.isHidden = true
            
            let statusMessage: String
            
            if let error = lastErrorLocation as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching ..."
            } else {
                statusMessage = ""
                showLogoView()
            }
            
            messageLabel.text = statusMessage
            messageLabel.isHidden = false
            latitudeText.isHidden = true
            longitudeText.isHidden = true
        }
        
        configureGetButton()
    }
    
    private func configureGetButton() {
        
        let spinnerTag = 2000
        
        if updatingLocation {
            getLocationButton.setTitle("Stop", for: .normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                
                let spinner = UIActivityIndicatorView(style: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height + 25
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
            
        } else {
            
            getLocationButton.setTitle("Get My Location", for: .normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    private func loadSoundEffect(name: String) {
        
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            
            if error != kAudioServicesNoError {
                print("error: \(error)\n loading sound: \(path)")
            }
        }
    }
    
    private func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    private func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }

    @objc func didTimeOut() {
        
        if fetchedLocation == nil {
           
            stopUpdaingLocation()
            lastErrorLocation = NSError(domain: "MyLocationsErrorDomin", code: 1, userInfo: nil)
            updateUI()
        }
    }
    

}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("did fail with errror: \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastErrorLocation = error
        stopUpdaingLocation()
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print("did update location: \(newLocation)")
        
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 || newLocation.horizontalAccuracy < 0 {
            return
        }
        
        let distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        
        if fetchedLocation == nil || fetchedLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastErrorLocation = nil
            fetchedLocation = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                
                print("done!")
                stopUpdaingLocation()
                
                if distance > 0 {
                    performReverseGeocoding = false
                }
            }
            updateUI()
            
            if !performReverseGeocoding {
                
                performReverseGeocoding = true
                
                geocoeder.reverseGeocodeLocation(newLocation) { ( placemarks, error) in
                    
                    self.lastGeocodingError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                        if self.placemark == nil {
                            self.playSoundEffect()
                        }
                        self.placemark = places.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performReverseGeocoding = false
                    self.updateUI()
                }
            } else if distance > 1 {
                
                let timeInterval = newLocation.timestamp.timeIntervalSince(fetchedLocation!.timestamp)
                
                if timeInterval > 10 {
                    stopUpdaingLocation()
                    unloadSoundEffect()
                    updateUI()
                }
            }
        }
    }
    
    
    private func startUpdatingLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
            
        }
    }
    
    
    private func stopUpdaingLocation() {
        
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
}


extension CurrentLocationViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    private func showLogoView() {
        if !logoVisable {
            
            logoVisable = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    private func hideLogoView() {
        
        guard logoVisable else { return }
        
        logoVisable = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        let centerX = view.bounds.midX
        
        //perform animation for containerView and logoButton
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover,forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoRotator,forKey: "logoRotator")
    }
    

}
