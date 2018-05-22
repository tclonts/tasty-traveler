//
//  StaticMapView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class StaticMapView: UIViewController {
    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        view.alpha = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneButtonTapped)))
        return view
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "closeButtonRound"), for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let backgroundView = UIView()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = adaptConstant(10)
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var coordinate: CLLocationCoordinate2D? {
        didSet {
            setUpMapImage(coordinate: coordinate!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = .clear
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = adaptConstant(12)
        backgroundView.clipsToBounds = true
        
        setUpViews()
        
        activityIndicator.startAnimating()
        
        self.backgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showMapView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.overlayView.alpha = 1
            self.backgroundView.transform = .identity
        }, completion: nil)
    }
    
    func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.overlayView.alpha = 0
            self.backgroundView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height - self.backgroundView.frame.height / 2)
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func doneButtonTapped() {
        handleDismiss()
    }
    
    func setUpViews() {
        self.view.sv(overlayView, backgroundView.sv(activityIndicator, mapImageView, dismissButton))
        
        overlayView.fillContainer()
        backgroundView.left(adaptConstant(12)).right(adaptConstant(12)).centerVertically()
        
        activityIndicator.centerInContainer()
        
        dismissButton.top(adaptConstant(12)).left(adaptConstant(12))
        
        mapImageView.left(0).right(0).top(0).bottom(0)
        mapImageView.height(UIScreen.main.bounds.height / 2)
    }
    
    func setUpMapImage(coordinate: CLLocationCoordinate2D) {

        let distanceInMeters: Double = 600000//500000

        let options = MKMapSnapshotOptions()
        options.showsBuildings = false
        options.showsPointsOfInterest = false
        let height = UIScreen.main.bounds.height / 2
        let width = UIScreen.main.bounds.width - adaptConstant(25) - adaptConstant(25)
        options.size = CGSize(width: width, height: height)
        options.region = MKCoordinateRegionMakeWithDistance(coordinate, distanceInMeters, distanceInMeters)


        let pin = MKMarkerAnnotationView()
        pin.animatesWhenAdded = false
        pin.contentMode = .scaleAspectFit
        pin.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        pin.titleVisibility = .hidden
        pin.subtitleVisibility = .hidden

        //let backgroundQueue = DispatchQueue.global(qos: .background)
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { (snapshot, error) in
            guard error == nil else { return }

            if let snapshotImage = snapshot?.image, let coordinatePoint = snapshot?.point(for: coordinate) {
                UIGraphicsBeginImageContextWithOptions(snapshotImage.size, true, snapshotImage.scale)
                snapshotImage.draw(at: CGPoint.zero)

                let fixedPinPoint = CGPoint(x: coordinatePoint.x - pin.bounds.width / 2, y: coordinatePoint.y - pin.bounds.height)
                let rect = CGRect(origin: fixedPinPoint, size: CGSize(width: pin.bounds.width, height: pin.bounds.height))
                pin.drawHierarchy(in: rect, afterScreenUpdates: true)

                let mapImage = UIGraphicsGetImageFromCurrentImageContext()

                DispatchQueue.main.async {
                    self.mapImageView.image = mapImage
                    self.activityIndicator.stopAnimating()
                }
                UIGraphicsEndImageContext()
            }
        }

    }
}
