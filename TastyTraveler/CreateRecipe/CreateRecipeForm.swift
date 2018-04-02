//
//  CreateRecipeForm.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class CreateRecipeForm: UIView {

    var createRecipeVC: CreateRecipeVC?
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var recipeNameTextInputView: TextInputView = {
        let textView = TextInputView()
        textView.textView.text = "Name this recipe"
        textView.textView.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(22))
        textView.textView.textColor = Color.lightGray
        textView.textView.isScrollEnabled = false
        textView.textView.textContainerInset = UIEdgeInsets.zero
        textView.textView.textContainer.lineFragmentPadding = 0
        textView.textView.delegate = self
        return textView
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cameraButton"), for: .normal)
        button.width(adaptConstant(25)).height(adaptConstant(22))
        button.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
        return button
    }()
    
    lazy var nameAndCameraView: UIView = {
        let view = UIView()
        view.sv(recipeNameTextInputView, cameraButton)
        return view
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))
        textView.textColor = Color.darkText
        textView.text = "This is an example description. You can write anything about the recipe here. Share the recipe's origin, overview, inspiration, etc."
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    lazy var descriptionTextInputView: TextInputView = {
        let textView = TextInputView()
        textView.textView.text = "Give your recipe a description..."
        textView.textView.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(18))
        textView.textView.textColor = Color.lightGray
        textView.textView.isScrollEnabled = false
        textView.textView.textContainerInset = UIEdgeInsets.zero
        textView.textView.textContainer.lineFragmentPadding = 0
        textView.textView.delegate = self
        return textView
    }()
    
    let tutorialVideoLabel: UILabel = {
        let label = UILabel()
        label.text = "Tutorial Video"
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        return label
    }()
    
    lazy var tutorialVideoButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Upload a video", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(chooseVideo), for: .touchUpInside)
        return button
    }()
    
    let tutorialVideoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    let servingsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Servings"
        return label
    }()
    
    lazy var servingsButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Enter number of servings", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(servingsButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Time"
        return label
    }()
    
    let timeButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Enter total time", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Difficulty"
        return label
    }()
    
    let difficultyControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Easy", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Medium", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Hard", at: 2, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.lightGray], for: .normal)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.darkText], for: .selected)
        return segmentedControl
    }()
    
    let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Ingredients"
        return label
    }()
    
    lazy var ingredientsTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.register(TextInputTableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        return tableView
    }()
    
    lazy var addIngredientButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Add ingredient", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))!,
            NSAttributedStringKey.foregroundColor: Color.darkGrayText])
        button.setImage(#imageLiteral(resourceName: "addCircleButton"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(addIngredientTapped), for: .touchUpInside)
        return button
    }()
    
    let stepsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Steps"
        return label
    }()
    
    lazy var stepsTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.register(TextInputTableViewCell.self, forCellReuseIdentifier: "stepCell")
        return tableView
    }()
    
    lazy var addStepButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Add step", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))!,
            NSAttributedStringKey.foregroundColor: Color.darkGrayText])
        button.setImage(#imageLiteral(resourceName: "addCircleButton"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(addStepButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let tagsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Tags"
        return label
    }()
    
    lazy var tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "tagCell")
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: "CANCEL", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.gray])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "doneButton"), for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let containerView = UIView()
    let scrollViewContainer = UIView()
    
    // Constraints
    lazy var recipeNameConstraintNoImage = constraint(item: nameAndCameraView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: adaptConstant(35))
    lazy var recipeNameConstraint = constraint(item: nameAndCameraView, attribute: .top, relatedBy: .equal, toItem: photoImageView, attribute: .bottom, multiplier: 1, constant: adaptConstant(27))
    lazy var servingsConstraintNoVideo = constraint(item: servingsLabel, attribute: .top, relatedBy: .equal, toItem: tutorialVideoLabel, attribute: .bottom, multiplier: 1, constant: adaptConstant(27))
    lazy var servingsConstraint = constraint(item: servingsLabel, attribute: .top, relatedBy: .equal, toItem: tutorialVideoImageView, attribute: .bottom, multiplier: 1, constant: adaptConstant(27))
    lazy var scrollViewContainerBottomConstraint = constraint(item: scrollViewContainer, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0)
    
    let margin: CGFloat = adaptConstant(18)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setUpViews()
    }
    
    fileprivate func setUpViews() {
        
        containerView.sv(
            photoImageView,
            nameAndCameraView,
            descriptionTextInputView,
            tutorialVideoLabel,
            tutorialVideoButton,
            tutorialVideoImageView,
            servingsLabel,
            servingsButton,
            timeLabel,
            timeButton,
            difficultyLabel,
            difficultyControl,
            ingredientsLabel,
            ingredientsTableView,
            addIngredientButton,
            stepsLabel,
            stepsTableView,
            addStepButton,
            tagsLabel,
            tagsCollectionView
        )
        
        // Photo
        photoImageView.top(0).left(0).right(0)
        photoImageView.Height == photoImageView.Width * 0.75
        
        // Recipe name and camera button
        containerView.addConstraint(recipeNameConstraintNoImage)
        nameAndCameraView.left(margin).right(margin)
        recipeNameTextInputView.height(40)
        nameAndCameraView.Height == recipeNameTextInputView.Height
        recipeNameTextInputView.Right == cameraButton.Left - adaptConstant(20)
        recipeNameTextInputView.left(0).top(0)
        cameraButton.right(0).top(0)
        
        // Description
        descriptionTextInputView.Top == nameAndCameraView.Bottom + adaptConstant(27)
        descriptionTextInputView.left(adaptConstant(18)).right(margin)
        descriptionTextInputView.height(60)
        
        // Tutorial Video
        tutorialVideoLabel.Top == descriptionTextInputView.Bottom + adaptConstant(27)
        tutorialVideoLabel.left(margin)
        tutorialVideoButton.CenterY == tutorialVideoLabel.CenterY
        tutorialVideoButton.right(margin)
        tutorialVideoImageView.right(margin)
        tutorialVideoImageView.Top == tutorialVideoButton.Bottom + adaptConstant(10)
        tutorialVideoImageView.width(adaptConstant(118))
        tutorialVideoImageView.heightEqualsWidth()
        
        // Servings
        containerView.addConstraint(servingsConstraintNoVideo)
        servingsLabel.left(margin)
        servingsButton.right(margin)
        servingsButton.CenterY == servingsLabel.CenterY
        servingsButton.Left == servingsLabel.Right
        
        // Time
        timeLabel.Top == servingsLabel.Bottom + adaptConstant(27)
        timeLabel.left(margin)
        timeButton.right(margin)
        timeButton.CenterY == timeLabel.CenterY
        timeButton.Left == timeLabel.Right
        
        // Difficulty
        difficultyLabel.Top == timeLabel.Bottom + adaptConstant(27)
        difficultyLabel.left(margin)
        difficultyControl.right(0)
        difficultyControl.CenterY == difficultyLabel.CenterY
        
        // Ingredients
        ingredientsLabel.Top == difficultyLabel.Bottom + adaptConstant(27)
        ingredientsLabel.left(margin)
        ingredientsTableView.Top == ingredientsLabel.Bottom + adaptConstant(10)
        ingredientsTableView.left(margin).right(margin)
        ingredientsTableView.height(adaptConstant(39))
        addIngredientButton.Top == ingredientsTableView.Bottom + adaptConstant(20)
        addIngredientButton.left(margin)
        
        // Steps
        stepsLabel.Top == addIngredientButton.Bottom + adaptConstant(27)
        stepsLabel.left(margin)
        stepsTableView.Top == stepsLabel.Bottom + adaptConstant(10)
        stepsTableView.left(margin).right(margin)
        stepsTableView.height(adaptConstant(39))
        addStepButton.Top == stepsTableView.Bottom + adaptConstant(10)
        addStepButton.left(margin)
        
        // Tags
        tagsLabel.Top == addStepButton.Bottom + adaptConstant(27)
        tagsLabel.left(margin)
        tagsCollectionView.Top == tagsLabel.Bottom
        tagsCollectionView.left(0).right(0)
        tagsCollectionView.bottom(0).height(adaptConstant(81))
        
        sv(
            scrollViewContainer.sv(scrollView.sv(containerView)),
            bottomView.sv(cancelButton, doneButton)
        )
        
        scrollViewContainer.top(0).left(0).right(0)
        scrollViewContainer.Bottom == bottomView.Top
        
        scrollView.top(0).left(0).right(0).bottom(0)
        
        containerView.fillContainer()
        containerView.Width == scrollView.Width
        
        scrollView.top(0).left(0).right(0)
        scrollView.Bottom == bottomView.Top
        
        bottomView.bottom(0).left(0).right(0).height(adaptConstant(76))
        cancelButton.left(adaptConstant(27)).centerVertically()
        doneButton.right(adaptConstant(27)).centerVertically()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func cancelButtonTapped() {
        self.createRecipeVC?.dismiss(animated: true, completion: nil)
//        print(ingredientsTableView.numberOfRows(inSection: 0))
//        print(createRecipeVC?.ingredientsDataSource.ingredients.count)
    }
    
    @objc fileprivate func doneButtonTapped() {
        self.createRecipeVC?.submitRecipe()
    }
    
    @objc fileprivate func addIngredientTapped() {
        var previousIngredient: String?
        
        if ingredientsTableView.numberOfRows(inSection: 0) == 1 {
            let cell = ingredientsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextInputTableViewCell
            if cell.textField.text != "" { previousIngredient = cell.textField.text }
        } else {
            let cell = ingredientsTableView.cellForRow(at: IndexPath(row: (createRecipeVC?.ingredientsDataSource.ingredients.count)!, section: 0)) as! TextInputTableViewCell
            if cell.textField.text != "" { previousIngredient = cell.textField.text }
        }
        
        if previousIngredient != nil {
            createRecipeVC?.ingredientsDataSource.ingredients.append(previousIngredient!)
            
            guard let ingredients = createRecipeVC?.ingredientsDataSource.ingredients else { return }
            ingredientsTableView.beginUpdates()
            ingredientsTableView.insertRows(at: [IndexPath(row: ingredients.count, section: 0)], with: .none)
            ingredientsTableView.endUpdates()
            ingredientsTableView.heightConstraint?.constant = ingredientsTableView.contentSize.height
        }
    }
    
    @objc fileprivate func addStepButtonTapped() {
        var previousStep: String?
        
        if stepsTableView.numberOfRows(inSection: 0) == 1 {
            let cell = stepsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextInputTableViewCell
            if cell.textField.text != "" { previousStep = cell.textField.text }
        } else {
            let cell = stepsTableView.cellForRow(at: IndexPath(row: (createRecipeVC?.stepsDataSource.steps.count)!, section: 0)) as! TextInputTableViewCell
            if cell.textField.text != "" { previousStep = cell.textField.text }
        }
        
        if previousStep != nil {
            createRecipeVC?.stepsDataSource.steps.append(previousStep!)
            
            guard let steps = createRecipeVC?.stepsDataSource.steps else { return }
            stepsTableView.beginUpdates()
            stepsTableView.insertRows(at: [IndexPath(row: steps.count, section: 0)], with: .none)
            stepsTableView.endUpdates()
            stepsTableView.heightConstraint?.constant = stepsTableView.contentSize.height
        }
    }
    
    @objc fileprivate func servingsButtonTapped() {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.tag = 0
        textField.width(0).height(0)
        textField.delegate = self
        self.sv(textField)
        textField.becomeFirstResponder()
    }
    
    @objc fileprivate func timeButtonTapped() {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.tag = 1
        textField.width(0).height(0)
        textField.delegate = self
        self.sv(textField)
        textField.becomeFirstResponder()
    }
    
    func showTextField() {
        
    }
    
    @objc fileprivate func choosePhoto() {
        createRecipeVC?.choosePhoto()
    }
    
    @objc fileprivate func chooseVideo() {
        //createRecipeVC?.chooseVideo()
    }
}

extension CreateRecipeForm: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Servings textfield
        if textField.tag == 0 {
            if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
                if updatedString == "" {
                    let title = NSAttributedString(string: "Enter number of servings", attributes: [
                        NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                        NSAttributedStringKey.foregroundColor: Color.primaryOrange])
                    self.servingsButton.setAttributedTitle(title, for: .normal)
                } else {
                    
                    let title = NSAttributedString(string: updatedString + " servings", attributes: [
                        NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                        NSAttributedStringKey.foregroundColor: Color.primaryOrange])
                    self.servingsButton.setAttributedTitle(title, for: .normal)
                }
            }
        }
        
        // Time textfield
        if textField.tag == 1 {
            if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
                if updatedString == "" {
                    let title = NSAttributedString(string: "Enter total time", attributes: [
                        NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                        NSAttributedStringKey.foregroundColor: Color.primaryOrange])
                    self.timeButton.setAttributedTitle(title, for: .normal)
                } else {
                    
                    let title = NSAttributedString(string: updatedString + " minutes", attributes: [
                        NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                        NSAttributedStringKey.foregroundColor: Color.primaryOrange])
                    self.timeButton.setAttributedTitle(title, for: .normal)
                }
            }
        }
        
        return true
    }
}

extension CreateRecipeForm: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var size: CGSize
        if textView == recipeNameTextInputView.textView {
            size = CGSize(width: self.frame.width - cameraButton.frame.width - 12, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            recipeNameTextInputView.heightConstraint?.constant = estimatedSize.height
        } else {
            size = CGSize(width: self.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            descriptionTextInputView.heightConstraint?.constant = estimatedSize.height
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == recipeNameTextInputView.textView {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars < 70
        } else {
            return true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == recipeNameTextInputView.textView && recipeNameTextInputView.textView.text == "Name this recipe" {
            textView.textColor = Color.blackText
            textView.text = ""
        }
        
        if textView == descriptionTextInputView.textView && descriptionTextInputView.textView.text == "Give your recipe a description..." {
            textView.textColor = Color.blackText
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == recipeNameTextInputView.textView && recipeNameTextInputView.textView.text == "" {
            textView.textColor = Color.lightGray
            textView.text = "Name this recipe"
        }
        
        if textView == descriptionTextInputView.textView && descriptionTextInputView.textView.text == "" {
            textView.textColor = Color.lightGray
            textView.text = "Give your recipe a description..."
        }
    }
}
