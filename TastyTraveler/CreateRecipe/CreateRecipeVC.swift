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

class CreateRecipeVC: UIViewController {
    
    var recipe: Recipe?
    
    let ingredientsDataSource = IngredientsDataSource()
    let stepsDataSource = StepsDataSource()
    let tagsDataSource = TagsDataSource()
    
    let photoImagePicker = UIImagePickerController()
    
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
        let recipeDictionary: [String:Any] = ["photo": UIImageJPEGRepresentation(photo, 0.8)!,
                                              "recipeName": formView.recipeNameTextInputView.textView.text,
                                              "creatorID": Auth.auth().currentUser!.uid]
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
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
//        let videoUrl = info[UIImagePickerControllerMediaURL] as! NSURL?
//        let pathString = videoUrl?.relativePath
        
//        let imageUID = UUID().uuidString
        
//        formView.photoImageView.image = image
//        formView.photoImageView.isHidden = false
//        formView.containerView.removeConstraint(formView.recipeNameConstraintNoImage)
//        formView.containerView.addConstraint(formView.recipeNameConstraint)
        
        let imageCropViewController = RSKImageCropViewController(image: image)
        imageCropViewController.delegate = self
        imageCropViewController.dataSource = self
        imageCropViewController.cropMode = .custom
        
        photoImagePicker.pushViewController(imageCropViewController, animated: true)
        
//        if let jpegData = UIImageJPEGRepresentation(image, 80) {
//        }
        
//        dismiss(animated: true)
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

class TextInputTableViewCell: UITableViewCell {
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        
        return textField
    }()
    
    let stepLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
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
}

class IngredientsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var ingredients = [String]()
    
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

        cell.textField.delegate = self
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
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField.text != ingredients.last && textField.text != "" {
//            ingredients.append(textField.text!)
//            print(ingredients)
//        }
//    }
}

class StepsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var steps = [String]()
    
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
        
        cell.textField.delegate = self
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
        
        let tag = tags[indexPath.row]
        
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
