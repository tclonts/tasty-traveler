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

class CreateRecipeVC: UIViewController {
    
    var recipe: Recipe?
    
    let ingredientsDataSource = IngredientsDataSource()
    let stepsDataSource = StepsDataSource()
    let tagsDataSource = TagsDataSource()
    
    let photoImagePicker = UIImagePickerController()
    var localVideoURL: URL?
    var servings: String?
    var timeInMinutes: String?
    var difficulty: String?
    
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
    
    func submitRecipe() {
        guard let photo = formView.photoImageView.image else { return }
        guard let name = formView.recipeNameTextInputView.textView.text else { return }
        guard let servings = servings else { return }
        guard let timeInMinutes = timeInMinutes else { return }
        guard let difficulty = formView.difficultyControl.titleForSegment(at: formView.difficultyControl.selectedSegmentIndex) else { return }
        
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
        
        var recipeDictionary: [String:Any] = [Recipe.photoKey: UIImageJPEGRepresentation(photo, 0.8)!,
                                              Recipe.nameKey: name,
                                              Recipe.creatorIDKey: Auth.auth().currentUser!.uid,
                                              Recipe.servingsKey: servingsInt!,
                                              Recipe.timeInMinutesKey: timeInMinutesInt!,
                                              Recipe.difficultyKey: difficulty,
                                              Recipe.ingredientsKey: ingredients,
                                              Recipe.stepsKey: steps]
        
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
            tagIndexes.forEach { tags.append(tagsDataSource.tags[$0]) }
            recipeDictionary[Recipe.tagsKey] = tags
        }
        
        FirebaseController.shared.uploadRecipe(dictionary: recipeDictionary)
        self.dismiss(animated: true, completion: nil)
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
        self.makeViewDark()
        
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
        return textField
    }()
    
    let stepLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    weak var delegate: TextInputCellDelegate?
    
    func configure(text: String?, placeholder: String?, step: Int?) {
        textField.text = text
        textField.placeholder = placeholder
        
        if let step = step { stepLabel.isHidden = false; stepLabel.text = "\(step)."}
        
        if stepLabel.isHidden {
            textField.fillContainer()
        } else {
            stepLabel.left(0).centerVertically()
            textField.left(adaptConstant(20))
            textField.top(0).bottom(0).right(0)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
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
    var tags = ["Vegan",
                "Gluten-free",
                "Vegetarian",
                "Whole 30",
                "Paleo",
                "Organic"]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCell
        
        let tag = tags[indexPath.item]
        
        cell.tagString = tag
        cell.setUpViews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCell
        
        cell.tagLabel.textColor = .white
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, adaptConstant(18), 0, 0 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return adaptConstant(8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCell
        
        cell.tagLabel.textColor = Color.lightGray
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: adaptConstant(115), height: collectionView.frame.height)
    }
}
