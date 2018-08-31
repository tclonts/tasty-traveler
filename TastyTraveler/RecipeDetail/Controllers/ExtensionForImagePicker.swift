//
//  ExtensionForImagePicker.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 8/25/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase
import GSKStretchyHeaderView
import Stevia
import RSKImageCropper
import SVProgressHUD

extension RecipeDetailVC: RSKImageCropViewControllerDelegate  {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var avatarImage: UIImage

        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            avatarImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            avatarImage = possibleImage

        } else {
            return
        }

        picker.dismiss(animated: true) {
            var imageCropVC: RSKImageCropViewController!
            imageCropVC = RSKImageCropViewController(image: avatarImage, cropMode: .circle)
            imageCropVC.delegate = self
            self.present(imageCropVC, animated: true, completion: nil)
        }
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        CookedImageCell.shared.cookedImageView.image = croppedImage
        
        dismiss(animated: true, completion: {(() -> Void).self
            
            self.cookedItReviewPopup()
        })

        guard let imageData = resize(croppedImage) else { return }
//        pointAdder(numberOfPoints: 10)
        guard let recipe = recipe else { return }

        FirebaseController.shared.uploadCookedRecipeImage(recipe: recipe, data: imageData)
    }

    func resize(_ image: UIImage) -> Data? {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 255.0//933.0
        let maxWidth: Float = 255.0//1242.0
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

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cookedItReviewPopup() {
            guard let userID = Auth.auth().currentUser?.uid else { return }
        
            if !self.recipe!.hasCooked {
            self.recipe?.cookedDate = Date()
            self.recipe?.hasCooked = true
            let popup = CookedItAlertView()
            popup.modalPresentationStyle = .overCurrentContext
            popup.recipeID = self.recipe!.uid
            self.pointAdder(numberOfPoints: 5)
            self.present(popup, animated: false) {
            popup.showAlertView()
                
            }
    
            }
    }
    
    func uncookRecipe() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        self.pointAdder(numberOfPoints: -5)
        
        let ac = UIAlertController(title: "Mark this recipe as not cooked?", message: "This will permanently delete your rating/review for this recipe as well.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in

        
        FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").child(self.recipe!.uid).removeValue()
        FirebaseController.shared.ref.child("recipes").child(self.recipe!.uid).child("cookedImages").child(userID).removeValue()
        FirebaseController.shared.ref.child("users").child(userID).child("reviewedRecipes").child(self.recipe!.uid).removeValue()
        FirebaseController.shared.ref.child("recipes").child(self.recipe!.uid).child("reviews").child(userID).removeValue()
            
            NotificationCenter.default.post(name: Notification.Name("submittedReview"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
            
            
            self.recipe?.cookedDate = nil
            self.recipe?.hasCooked = false
            
            if !self.isFromFavorites {
                self.homeVC!.searchResultRecipes[self.homeVC!.previousIndexPath!.item] = self.recipe!
                self.homeVC?.recipeDataHasChanged = true
            }
            
            ac.dismiss(animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
}
