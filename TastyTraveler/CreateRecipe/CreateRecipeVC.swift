//
//  CreateRecipeVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import MobileCoreServices
import Firebase
import RSKImageCropper
import AVKit
import AVFoundation
import CoreLocation

class CreateRecipeVC: UIViewController {
    
    var recipe: Recipe?
    var isEditingRecipe = false
    
    let ingredientsDataSource = IngredientsDataSource()
    let stepsDataSource = StepsDataSource()
    let tagsDataSource = TagsDataSource()
    
    let photoImagePicker = UIImagePickerController()
    var localVideoURL: URL?
    var servings: String?
    var timeInMinutes: String?
    var difficulty: String?
    var states: [State]?
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        return lm
    }()
    
    lazy var formView: CreateRecipeForm = {
        let form = CreateRecipeForm()
        form.createRecipeVC = self
        return form
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        return tap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        states = loadJson(filename: "states")
        
        if isEditingRecipe {
            guard let recipe = recipe else { return }
            ingredientsDataSource.ingredients = recipe.ingredients
            stepsDataSource.steps = recipe.steps
            if let tags = recipe.tags {
                var indexes = [Int]()
                for tag in tags {
                    if let index = Tag.allValues.index(where: { $0 == tag.rawValue }) {
                        indexes.append(index)
                    }
                }
                formView.tagsToSelect = indexes
            }
            formView.photoImageView.loadImage(urlString: recipe.photoURL, placeholder: nil)
            formView.photoImageView.isHidden = false
            formView.containerView.removeConstraint(formView.recipeNameConstraintNoImage)
            formView.containerView.addConstraint(formView.recipeNameConstraint)
            formView.recipeNameTextInputView.textView.text = recipe.name
            formView.recipeNameTextInputView.textView.textColor = Color.darkText
            if let desc = recipe.description {
                formView.descriptionTextInputView.textView.text = desc
                formView.descriptionTextInputView.textView.textColor = Color.darkGrayText
            }
            
            let title = NSAttributedString(string: recipe.meal!, attributes: [
                NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                NSAttributedStringKey.foregroundColor: Color.primaryOrange])
            formView.mealTypeButton.setAttributedTitle(title, for: .normal)
            
            if let videoURL = recipe.videoURL {
                self.localVideoURL = URL(string: videoURL)
                self.formView.tutorialVideoImageView.image = self.getThumbnail(forURL: self.localVideoURL!)
                self.formView.tutorialVideoImageView.isHidden = false
                self.formView.containerView.removeConstraint(self.formView.servingsConstraintNoVideo)
                self.formView.containerView.addConstraint(self.formView.servingsConstraint)
            }
            
            formView.servingsTextField.text = String(recipe.servings)
            formView.textFieldDidEndEditing(formView.servingsTextField)
            formView.timeTextField.text = String(recipe.timeInMinutes)
            formView.textFieldDidEndEditing(formView.timeTextField)
            
            switch recipe.difficulty {
            case "Easy":
                formView.difficultyControl.selectedSegmentIndex = 0
            case "Medium":
                formView.difficultyControl.selectedSegmentIndex = 1
            default:
                formView.difficultyControl.selectedSegmentIndex = 2
            }
            
            
        }
        
        formView.ingredientsTableView.dataSource = ingredientsDataSource
        formView.ingredientsTableView.delegate = ingredientsDataSource
        formView.stepsTableView.dataSource = stepsDataSource
        formView.stepsTableView.delegate = stepsDataSource
        formView.tagsCollectionView.dataSource = tagsDataSource
        formView.tagsCollectionView.delegate = tagsDataSource
        
        ingredientsDataSource.ingredientsTableView = formView.ingredientsTableView
        stepsDataSource.stepsTableView = formView.stepsTableView
        
        photoImagePicker.delegate = self
        
        self.view = formView
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestAuthorization()
    }
    
    var viewIsDark = Bool()
    
    func makeViewDark() {
        viewIsDark = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func makeViewLight() {
        viewIsDark = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if viewIsDark {
            return .lightContent
        } else {
            return .default
        }
    }
    
    func pointAdder(numberOfPoints: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
            guard let user = user else { return }
            
            var points = user.points
            let newPoints = user.points != nil ? points! + numberOfPoints : numberOfPoints
            FirebaseController.shared.ref.child("users").child((user.uid)).child("points").setValue(newPoints)
            
        }
    }
    
    
    func submitRecipe() {
        pointAdder(numberOfPoints: 10)

        guard let photo = formView.photoImageView.image else { return }
        guard let name = formView.recipeNameTextInputView.textView.text else { return }
        guard let servings = servings else { return }
        guard let timeInMinutes = timeInMinutes else { return }
        guard let difficulty = formView.difficultyControl.titleForSegment(at: formView.difficultyControl.selectedSegmentIndex) else { return }
        guard let mealType = formView.mealTypeButton.titleLabel?.text else { return }
        
        var steps = stepsDataSource.steps
        
        // if the last element in the tableview has an empty textfield continue, if not append that textfield text to the steps array
        let stepsIndexPath = IndexPath(row: stepsDataSource.steps.count, section: 0)
        
        if let stepCell = formView.stepsTableView.cellForRow(at: stepsIndexPath) as? TextInputTableViewCell {
            if let text = stepCell.textField.text {
                if !steps.contains(text) && text != "" {
                    steps.append(text)
                }
            } else {
                print("Last step field is empty")
            }
        } else {
            return
        }
        
        var ingredients = ingredientsDataSource.ingredients
        
        let ingredientsIndexPath = IndexPath(row: ingredientsDataSource.ingredients.count, section: 0)
        if let ingredientCell = formView.ingredientsTableView.cellForRow(at: ingredientsIndexPath) as? TextInputTableViewCell {
            if let text = ingredientCell.textField.text {
                if !ingredients.contains(text) && text != "" {
                    ingredients.append(text)
                }
            } else {
                print("Last ingredient field is empty")
            }
        } else {
            return
        }
        
        let servingsInt = Int(servings)
        let timeInMinutesInt = Int(timeInMinutes)
        
        var recipeDictionary: [String:Any] = [Recipe.photoKey: resize(photo),
                                              Recipe.nameKey: name,
                                              Recipe.creatorIDKey: Auth.auth().currentUser!.uid,
                                              Recipe.servingsKey: servingsInt!,
                                              Recipe.timeInMinutesKey: timeInMinutesInt!,
                                              Recipe.difficultyKey: difficulty,
                                              Recipe.ingredientsKey: ingredients,
                                              Recipe.stepsKey: steps,
                                              Recipe.mealKey: mealType]
        
        if let descriptionText = formView.descriptionTextInputView.textView.text {
            if descriptionText != "" && descriptionText != "Give your recipe a description..." {
                recipeDictionary[Recipe.descriptionKey] = descriptionText
            }
        }
        
        if let videoURL = localVideoURL {
            recipeDictionary[Recipe.videoURLKey] = videoURL
            recipeDictionary[Recipe.thumbnailURLKey] = UIImageJPEGRepresentation(formView.tutorialVideoImageView.image!, 0.8)!
        }
        
        if let selectedTags = formView.tagsCollectionView.indexPathsForSelectedItems {
            let tagIndexes = selectedTags.map { $0.item }
            var tags = [String]()
            tagIndexes.forEach { tags.append(Tag.allValues[$0]) }
            recipeDictionary[Recipe.tagsKey] = tags
        }
        
        getUserLocation()
        if let location = locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error == nil {
                    guard let placemark = placemarks?[0] else { print("placemark not found"); return }
                    let countryCode = placemark.isoCountryCode
                    recipeDictionary[Recipe.countryCodeKey] = countryCode
                    recipeDictionary[Recipe.countryKey] = placemark.country
                    
                    let range = -2...2
                    let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
                    let adjustedLatitude = location.coordinate.latitude + (Double(randomDistance) * 0.01)
                    let adjustedLongitude = location.coordinate.longitude + (Double(randomDistance) * 0.01)
                    
                    recipeDictionary["longitude"] = adjustedLongitude
                    recipeDictionary["latitude"] = adjustedLatitude
                    
                    // Found state or province; display that instead of city
                    if let administrativeArea = placemark.administrativeArea, let states = self.states, placemark.country == "United States" {
                        if let matchingState = states.first(where: { $0.country == countryCode && $0.short == administrativeArea}) {
                            recipeDictionary[Recipe.localityKey] = matchingState.name
                            
                            // Upload with location
                            if self.isEditingRecipe {
                                FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: self.recipe?.uid, timestamp: self.recipe?.creationDate.timeIntervalSince1970)
                            } else {
                                FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: nil, timestamp: nil)
                            }
                        }
//                        } else {
//                            recipeDictionary[Recipe.localityKey] = administrativeArea
//
//                            // Upload with location
//                            FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary)
//                        }
                    } else {
                        recipeDictionary[Recipe.localityKey] = placemark.locality
                        
                        if self.isEditingRecipe {
                            FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: self.recipe?.uid, timestamp: self.recipe?.creationDate.timeIntervalSince1970)
                        } else {
                            FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: nil, timestamp: nil)
                        }
                    }
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            // Upload without location
            if self.isEditingRecipe {
                FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: self.recipe?.uid, timestamp: self.recipe?.creationDate.timeIntervalSince1970)
            } else {
                FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: nil, timestamp: nil)
            }
            print("No location available.")
        }
        
        self.dismiss(animated: true, completion: {
//            if let firstRecipeUploaded = UserDefaults.standard.object(forKey: "firstRecipeUploaded") as? Bool, firstRecipeUploaded {
//                print("First recipe has already been uploaded: \(firstRecipeUploaded)")
//            } else {
//                UserDefaults.standard.set(true, forKey: "firstRecipeUploaded")
//
                NotificationCenter.default.post(Notification(name: Notification.Name("FirstRecipe")))
//            }
        })
    }
    
    func resize(_ image: UIImage) -> Data? {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 933.0
        let maxWidth: Float = 1242.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.4

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return imageData
    }
    
    func submitTestRecipe() {
        let ac = UIAlertController(title: "Submit with custom location", message: "Use the current recipe with a custom location.", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter latitude"
        }
        ac.addTextField { (textField) in
            textField.placeholder = "Enter longitude"
        }
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (_) in
            guard let latitude = ac.textFields![0].text else { return }
            guard let longitude = ac.textFields![1].text else { return }
            
            guard let photo = self.formView.photoImageView.image else { return }
            guard let name = self.formView.recipeNameTextInputView.textView.text else { return }
            guard let servings = self.servings else { return }
            guard let timeInMinutes = self.timeInMinutes else { return }
            guard let difficulty = self.formView.difficultyControl.titleForSegment(at: self.formView.difficultyControl.selectedSegmentIndex) else { return }
            guard let mealType = self.formView.mealTypeButton.titleLabel?.text else { return }
            
            var steps = self.stepsDataSource.steps
            
            // if the last element in the tableview has an empty textfield continue, if not append that textfield text to the steps array
            let stepsIndexPath = IndexPath(row: self.stepsDataSource.steps.count, section: 0)
            
            if let stepCell = self.formView.stepsTableView.cellForRow(at: stepsIndexPath) as? TextInputTableViewCell {
                if let text = stepCell.textField.text {
                    if !steps.contains(text) && text != "" {
                        steps.append(text)
                    }
                } else {
                    print("Last step field is empty")
                }
            } else {
                return
            }
            
            var ingredients = self.ingredientsDataSource.ingredients
            
            let ingredientsIndexPath = IndexPath(row: self.ingredientsDataSource.ingredients.count, section: 0)
            if let ingredientCell = self.formView.ingredientsTableView.cellForRow(at: ingredientsIndexPath) as? TextInputTableViewCell {
                if let text = ingredientCell.textField.text {
                    if !ingredients.contains(text) && text != "" {
                        ingredients.append(text)
                    }
                } else {
                    print("Last ingredient field is empty")
                }
            } else {
                return
            }
            
            let servingsInt = Int(servings)
            let timeInMinutesInt = Int(timeInMinutes)
            
            var recipeDictionary: [String:Any] = [Recipe.photoKey: self.resize(photo),
                                                  Recipe.nameKey: name,
                                                  Recipe.creatorIDKey: Auth.auth().currentUser!.uid,
                                                  Recipe.servingsKey: servingsInt!,
                                                  Recipe.timeInMinutesKey: timeInMinutesInt!,
                                                  Recipe.difficultyKey: difficulty,
                                                  Recipe.ingredientsKey: ingredients,
                                                  Recipe.stepsKey: steps,
                                                  Recipe.mealKey: mealType]
            
            if let descriptionText = self.formView.descriptionTextInputView.textView.text {
                if descriptionText != "" && descriptionText != "Give your recipe a description..." {
                    recipeDictionary[Recipe.descriptionKey] = descriptionText
                }
            }
            
            if let videoURL = self.localVideoURL {
                recipeDictionary[Recipe.videoURLKey] = videoURL
                recipeDictionary[Recipe.thumbnailURLKey] = UIImageJPEGRepresentation(self.formView.tutorialVideoImageView.image!, 0.8)!
            }
            
            if let selectedTags = self.formView.tagsCollectionView.indexPathsForSelectedItems {
                let tagIndexes = selectedTags.map { $0.item }
                var tags = [String]()
                tagIndexes.forEach { tags.append(Tag.allValues[$0]) }
                recipeDictionary[Recipe.tagsKey] = tags
            }
            
            let location = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
            
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error == nil {
                    guard let placemark = placemarks?[0] else { print("placemark not found"); return }
                    let countryCode = placemark.isoCountryCode
                    recipeDictionary[Recipe.countryCodeKey] = countryCode
                    recipeDictionary[Recipe.countryKey] = placemark.country
                    
                    let range = -2...2
                    let randomDistance = Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound))) + range.lowerBound
                    let adjustedLatitude = location.coordinate.latitude + (Double(randomDistance) * 0.01)
                    let adjustedLongitude = location.coordinate.longitude + (Double(randomDistance) * 0.01)
                    
                    recipeDictionary["longitude"] = adjustedLongitude
                    recipeDictionary["latitude"] = adjustedLatitude
                    
                    // Found state or province; display that instead of city
                    if let administrativeArea = placemark.administrativeArea, let states = self.states, placemark.country == "United States" {
                        if let matchingState = states.first(where: { $0.country == countryCode && $0.short == administrativeArea}) {
                            recipeDictionary[Recipe.localityKey] = matchingState.name
                            
                            // Upload with location
                            if self.isEditingRecipe {
                                FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: self.recipe?.uid, timestamp: self.recipe?.creationDate.timeIntervalSince1970)
                            } else {
                                FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: nil, timestamp: nil)
                            }
                        }
                        //                        } else {
                        //                            recipeDictionary[Recipe.localityKey] = administrativeArea
                        //
                        //                            // Upload with location
                        //                            FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary)
                        //                        }
                    } else {
                        recipeDictionary[Recipe.localityKey] = placemark.locality
                        
                        if self.isEditingRecipe {
                            FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: self.recipe?.uid, timestamp: self.recipe?.creationDate.timeIntervalSince1970)
                        } else {
                            FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary, uid: nil, timestamp: nil)
                        }
                    }
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            self.dismiss(animated: true, completion: {
//                if let firstRecipeUploaded = UserDefaults.standard.object(forKey: "firstRecipeUploaded") as? Bool, firstRecipeUploaded {
//                    print("First recipe has already been uploaded: \(firstRecipeUploaded)")
//                } else {
//                    UserDefaults.standard.set(true, forKey: "firstRecipeUploaded")
                    NotificationCenter.default.post(Notification(name: Notification.Name("FirstRecipe")))
//                }
            })
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    @objc func handleTap() {
        self.view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.view.removeGestureRecognizer(tapGesture)
            formView.scrollView.contentInset = UIEdgeInsets.zero
        } else {
            self.view.addGestureRecognizer(tapGesture)
            formView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - formView.bottomView.frame.height, right: 0)
        }
        
        formView.scrollView.scrollIndicatorInsets = formView.scrollView.contentInset
    }
}

extension CreateRecipeVC: CLLocationManagerDelegate {
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            
            // One-time delivery of the user's location
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            Analytics.logEvent("location_denied", parameters: ["username": Auth.auth().currentUser!.displayName!, "userID": Auth.auth().currentUser!.uid])
            showLocationDisabledPopUp()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled", message: "We need your location to display the origin of your recipe.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CreateRecipeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource  {
    
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let path = UIBezierPath(rect: controller.maskRect)
        return path
    }
    
    func choosePhoto() {
        present(photoImagePicker, animated: true)
    }
    
    func chooseVideo() {
        let picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageCropViewController = RSKImageCropViewController(image: image)
            imageCropViewController.delegate = self
            imageCropViewController.dataSource = self
            imageCropViewController.cropMode = .custom
            print("ORIGINAL IMAGE SIZE: \(image.size)")
            photoImagePicker.pushViewController(imageCropViewController, animated: true)
        }
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mov")
            compressVideo(inputURL: videoURL, outputURL: compressedURL, handler: { (exportSession) in
                guard let session = exportSession else { return }
                
                switch session.status {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    guard let compressedData = NSData(contentsOf: compressedURL) else { return }
                    self.localVideoURL = exportSession?.outputURL
                    DispatchQueue.main.async {
                        self.formView.tutorialVideoImageView.image = self.getThumbnail(forURL: self.localVideoURL!)
                        self.formView.tutorialVideoImageView.isHidden = false
                        self.formView.containerView.removeConstraint(self.formView.servingsConstraintNoVideo)
                        self.formView.containerView.addConstraint(self.formView.servingsConstraint)
                    }
                    self.dismiss(animated: true, completion: nil)
                case .failed:
                    break
                case .cancelled:
                    break
                }
            })
        }
    }
    
    func playVideo() {
        if let videoURL = localVideoURL {
            let player = AVPlayer(url: videoURL)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            present(playerViewController, animated: true, completion: {
                playerViewController.player!.play()
            })
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetHighestQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func getThumbnail(forURL videoURL: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: videoURL)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.photoImagePicker.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        formView.photoImageView.image = croppedImage
        formView.photoImageView.isHidden = false
        formView.containerView.removeConstraint(formView.recipeNameConstraintNoImage)
        formView.containerView.addConstraint(formView.recipeNameConstraint)
        //self.makeViewDark()
        print(croppedImage.size)
        print(cropRect.size)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let maskSize = CGSize(width: self.view.frame.width, height: self.view.frame.width * 0.75)
        let maskRect = CGRect(x: 0, y: (self.view.frame.height * 0.5) - maskSize.height * 0.5, width: maskSize.width, height: maskSize.height)
        return maskRect
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
}

protocol TextInputCellDelegate: class {
    func handleEndEditing(text: String, cell: TextInputTableViewCell)
}

class TextInputTableViewCell: UITableViewCell, UITextFieldDelegate {
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = ProximaNova.regular.of(size: 16)
        textField.textColor = Color.darkText
        textField.contentHorizontalAlignment = .left
        return textField
    }()
    
    let stepLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = ProximaNova.regular.of(size: 16)
        label.textColor = Color.darkText
        return label
    }()
    
    weak var delegate: TextInputCellDelegate?
    
    func configure(text: String?, placeholder: String?, step: Int?) {
        textField.text = text
        textField.placeholder = placeholder
        
        if let step = step { stepLabel.isHidden = false; stepLabel.text = "\(step)."}
        
        if stepLabel.isHidden {
            textField.top(adaptConstant(8)).bottom(adaptConstant(8)).right(0).left(0)
        } else {
            stepLabel.left(0).centerVertically()
            textField.left(adaptConstant(20))
            textField.top(adaptConstant(8)).bottom(adaptConstant(8)).right(0)
        }
    }
    
    override func prepareForReuse() {
        textField.text = ""
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sv(stepLabel, textField)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if text != "" {
                delegate?.handleEndEditing(text: text, cell: self)
            }
        }
    }
}

class IngredientsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, TextInputCellDelegate {
    var ingredients = [String]()
    var ingredientsTableView: UITableView?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as? TextInputTableViewCell else { return UITableViewCell() }
        
        if indexPath.row == ingredients.count {
            cell.configure(text: nil, placeholder: "Enter ingredient", step: nil)
        } else {
            cell.configure(text: ingredients[indexPath.row], placeholder: nil, step: nil)
        }

        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !ingredients.isEmpty {
            
            if cell.isKind(of: TextInputTableViewCell.self) {
                (cell as! TextInputTableViewCell).textField.becomeFirstResponder()
            }
        }
    }
    
    func handleEndEditing(text: String, cell: TextInputTableViewCell) {
//        guard let indexPath = ingredientsTableView?.indexPath(for: cell) else { return }
//        guard !ingredients.contains(text) else { return }
//
//        // last row of the steps tableview
//        if indexPath.row == ingredients.count {
//            ingredients.append(text)
//        } else {
//            // replace existing step
//            ingredients[indexPath.row] = text
//        }
    }
}

class StepsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, TextInputCellDelegate {
    var steps = [String]()
    var stepsTableView: UITableView?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell") as? TextInputTableViewCell else { return UITableViewCell() }
        
        if indexPath.row == steps.count {
            cell.configure(text: nil, placeholder: "Enter step", step: indexPath.row + 1)
        } else {
            cell.configure(text: steps[indexPath.row], placeholder: nil, step: indexPath.row + 1)
        }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !steps.isEmpty {
            
            if cell.isKind(of: TextInputTableViewCell.self) {
                (cell as! TextInputTableViewCell).textField.becomeFirstResponder()
            }
        }
    }
    
    func handleEndEditing(text: String, cell: TextInputTableViewCell) {
//        guard let indexPath = stepsTableView?.indexPath(for: cell) else { return }
//        guard !steps.contains(text) else { return }
//
//        // last row of the steps tableview
//        if indexPath.row == steps.count {
//            steps.append(text)
//        } else {
//            // replace existing step
//            steps[indexPath.row] = text
//        }
    }
}

class TagsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Tag.allValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCell
        
        let tag = Tag.allValues[indexPath.item]
        
        let attributedString = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!, NSAttributedStringKey.foregroundColor: Color.lightGray])
//        cell.tagString = tag
        cell.tagLabel.attributedText = attributedString
        cell.setUpViews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, adaptConstant(18), 0, 0 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return adaptConstant(8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let attributedString = NSAttributedString(string: Tag.allValues[indexPath.row], attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!, NSAttributedStringKey.foregroundColor: Color.lightGray])
        return CGSize(width: attributedString.size().width + adaptConstant(24), height: collectionView.frame.height)
    }
}
