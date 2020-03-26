//
//  FinishAddTagViewController.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import MapKit

class FinishAddTagViewController: UIViewController
{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishAddLocationButton: UIButton!
    
    var studentInformation: StudentInformation?
        
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let studentLocation = studentInformation
        {
            let studentLocation = Location(
                objectId: studentLocation.objectId ?? "",
                uniqueKey: studentLocation.uniqueKey,
                firstName: studentLocation.firstName,
                lastName: studentLocation.lastName,
                mapString: studentLocation.mapString,
                mediaURL: studentLocation.mediaURL,
                latitude: studentLocation.latitude,
                longitude: studentLocation.longitude,
                createdAt: studentLocation.createdAt ?? "",
                updatedAt: studentLocation.updatedAt ?? ""
            )
            showTags(location: studentLocation)
        }
    }
    
    @IBAction func finishAddLocation(_ sender: UIButton)
    {
        self.setLoading(true)
        if let studentLocation = studentInformation
        {
            if ServerAPI.Auth.objectId == ""
            {
                ServerAPI.addStudentTag(information: studentLocation)
                { (success, error) in
                        if success
                        {
                            DispatchQueue.main.async
                            {
                                self.setLoading(true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async
                            {
                                self.showAlert(message: error?.localizedDescription ?? "", title: "Error", error: error)
                                self.setLoading(false)
                            }
                        }
                    }
            }
            else
            {
                let alertVC = UIAlertController(title: "Location Exists", message: "Someone has already set this location. Would you like to still update it?", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action: UIAlertAction) in
                    ServerAPI.updateStudentTag(information: studentLocation)
                    { (success, error) in
                        if success
                        {
                            DispatchQueue.main.async
                            {
                                self.setLoading(true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async
                            {
                                self.showAlert(message: error?.localizedDescription ?? "", title: "Error", error: error)
                                self.setLoading(false)
                            }
                        }
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async
                    {
                        self.setLoading(false)
                        alertVC.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alertVC, animated: true)
            }
        }
    }
    
    private func showTags(location: Location)
    {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = findCoordinates(location: location)
        {
            let tag = MKPointAnnotation()
            tag.title = location.locationLabel
            tag.subtitle = location.mediaURL ?? ""
            tag.coordinate = coordinate
            mapView.addAnnotation(tag)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    private func findCoordinates(location: Location) -> CLLocationCoordinate2D?
    {
        if let latitude = location.latitude, let longitude = location.longitude
        {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
        return nil
    }
        
    func setLoading(_ loading: Bool)
    {
        if loading
        {
            DispatchQueue.main.async
            {
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.finishAddLocationButton)
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.finishAddLocationButton)
            }
        }
        DispatchQueue.main.async
        {
            self.finishAddLocationButton.isEnabled = !loading
        }
    }
}
