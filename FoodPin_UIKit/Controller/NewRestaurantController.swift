//
//  NewRestaurantController.swift
//  FoodPin_UIKit
//
//  Created by Андрей Бородкин on 23.03.2022.
//

import UIKit
import CoreData

class NewRestaurantController: UITableViewController {

    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    
    @IBOutlet var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 10.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    // try to make a generic to incorporate text view and field
    
    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }
    
    var restaurant: Restaurant!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the superview's layout
        let margins = photoImageView.superview!.layoutMarginsGuide
        
        // Disable auto resizing mask to use auto layout programmatically
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Pin the leading edge of the image view to the margin's leading edge and others
        photoImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        photoImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        photoImageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Customise the navigation bar appearance
        if let appearance = navigationController?.navigationBar.standardAppearance {
            if let customFont = UIFont(name: "Nunito-Bold", size: 40.0) {
                
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
        }
    }
    
    //MARK: - Methods
    
    @IBAction func saveButtonTapped() {
        if let name = nameTextField.text, name.count > 1,
           let type = typeTextField.text, type.count > 1,
           let location = addressTextField.text, location.count > 1,
           let phone = phoneTextField.text, phone.count > 1,
           let description = descriptionTextView.text
        {
            print("""
                Name: \(name)
                Type: \(type)
                Location: \(location)
                Phone: \(phone)
                Description: \(description)
                """)
            
            if name == "Sample" {
                let sampleRestaurants = Restaurant.RestaurantStruct.sampleData
                
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    for sample in sampleRestaurants {
                        restaurant = Restaurant(context: appDelegate.persistentContainer.viewContext)
                        restaurant.name = sample.name
                        restaurant.type = sample.type
                        restaurant.location = sample.location
                        restaurant.phone = sample.phone
                        restaurant.summary = sample.description
                        restaurant.isFavourite = false
                        restaurant.image = (UIImage(named: sample.image)?.pngData())!
                        
                        print("Saving data to context")
                        appDelegate.saveContext()
                    }
                }
            } else {
                
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    restaurant = Restaurant(context: appDelegate.persistentContainer.viewContext)
                    restaurant.name = name
                    restaurant.type = type
                    restaurant.location = location
                    restaurant.phone = phone
                    restaurant.summary = description
                    restaurant.isFavourite = false
                    
                    if let imageData = photoImageView.image?.pngData() {
                        restaurant.image = imageData
                    }
                    
                    print("Saving data to context")
                    appDelegate.saveContext()
                }
            }
            
            
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Opps", message: "We can't proceed because one of the text field is blank. Please nota that all field are required ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    // MARK: - DataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "", message: "Chose your photo source", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {action in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    
                    self.present(imagePicker, animated: true, completion:  nil)
                }
            })
            
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            
            // For iPad
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }

}

// MARK: - Extensions

extension NewRestaurantController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
}

extension NewRestaurantController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
}
