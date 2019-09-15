//
//  TagLocationViewController.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/8/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.isHidden = false
            addPhotoLabel.text = ""
            addPhotoLabel.isHidden = true
            tableView.reloadData()
        }
    }
    
    var managedObjectContext: NSManagedObjectContext!
    
    // variabels will be hocked in edit situation
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                placemark = location.placemark
            }
        }
    }
    
    var observer: Any!
    
    var descriptionText = ""
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForBackgroundNotification()
        
        descriptionTextView.delegate = self
        if let loaction = locationToEdit {
            title = "Edit Location"
            descriptionTextView.text = descriptionText
            
            if loaction.hasPhoto {
                if let theImage = loaction.photoImage {
                    image = theImage
                }
            }
        }
        
        
        configueGesture()
        
        setupUI()
    }
    //tap gesture to hide keyboard when user clicked another row
    private func configueGesture() {
        
        let gestureRecogonizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        gestureRecogonizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecogonizer)
    }
    
    deinit {
        print("deinit!")
        NotificationCenter.default.removeObserver(observer)
    }
    
    private func listenForBackgroundNotification() {
        
        observer =  NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            if let weakSelf = self {
                
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                
                weakSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    private func setupUI() {
        
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        dateLabel.text = format(date: date)
        
        if let placemark = placemark {
            addressLabel.text = placemark.decode()
        } else {
            addressLabel.text = "No Address Found"
        }
    }
    
    private func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @IBAction func CategotyPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if image != nil && indexPath.section == 1 && indexPath.row == 0 {
            
            let aspectRatio = Float(image!.size.width / image!.size.height)
            let cellHeight = CGFloat(aspectRatio * 260)
            
            print(cellHeight)
            
            return cellHeight
            
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        cell.selectedBackgroundView = selectionView
        
    }
    
    @IBAction func donePressed(_ sender: Any) {
        
        let hudView = HudView.hud(inView: tableView, animated: true)
        
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "\t✓\nUpdated"
            location = temp
        } else {
            hudView.text = "\t✓\nTagged"
            location = Location(context: managedObjectContext)
            //make photoID equal nil cause core data make it 0 for newer object
            location.photoID = nil
        }
        
        //configure loaction properties
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.category = categoryName
        location.locationDescription = descriptionTextView.text
        location.date = date
        location.placemark = placemark
        
        //save photo in document directory
        if let image = image {
            
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing File\(error)")
                }
            }
        }
        
        //save location in core data
        do {
            try managedObjectContext.save()
            after(delay: 1.2) {
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
       navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard(_ gestureRecogonizer: UIGestureRecognizer) {
        
        let tappedPoint = gestureRecogonizer.location(in: tableView)
        
        if let indexPath = tableView.indexPathForRow(at: tappedPoint) {
            if indexPath.section != 0 && indexPath.row != 0 {
                descriptionTextView.resignFirstResponder()
            }
        } else {
            descriptionTextView.resignFirstResponder()
        }
    }
    
}


extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    private func pickPhoto() {
        
        if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPicker()
        } else {
            picker(for: .photoLibrary)
        }
        
    }
    
    private func showPicker() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.picker(for: .camera)
        }
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) { _ in
            self.picker(for: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromLibraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func picker(for mode: UIImagePickerController.SourceType) {
        
        let imagePicker = CustomeImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.delegate = self
        imagePicker.sourceType = mode
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if editedImage != nil {
            image = editedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension LocationDetailsViewController: UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if descriptionTextView.textColor == UIColor.lightGray && locationToEdit == nil {
            descriptionTextView.text = nil
        }
        descriptionTextView.textColor = .black
    }
    
}
