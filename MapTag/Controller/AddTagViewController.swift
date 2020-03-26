//
//  AddTagViewController.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import MapKit

class AddTagViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var objectId: String?
    
    var locationTextFieldIsEmpty = true
    var urlTextFieldIsEmpty = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        locationTextField.delegate = self
        urlTextField.delegate = self
        locationTextField.borderStyle = .roundedRect
        urlTextField.borderStyle = .roundedRect
        findLocationButton.layer.cornerRadius = 5
        buttonEnabled(false, button: findLocationButton)
    }
    
    @IBAction func cancelAddTag(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(sender: UIButton)
    {
        self.setLoading(true)
        let userLocation = locationTextField.text
        
        guard let url = URL(string: self.urlTextField.text!), UIApplication.shared.canOpenURL(url) else
        {
            self.showAlert(message: "Please enter a valid URL", title: "Invalid URL")
            setLoading(false)
            return
        }

        geocode(location: userLocation ?? "")
    }
    
    private func geocode(location: String)
    {
        CLGeocoder().geocodeAddressString(location) { (newMarker, error) in
            if let error = error
            {
                self.showAlert(message: "Please check the location name and try again.", title: "Location Not Found", error: error)
                self.setLoading(false)
            }
            else
            {
                var firstLocation: CLLocation?
                
                // if multiple matches, pick first match
                if let marker = newMarker, marker.count > 0
                {
                    firstLocation = marker.first?.location
                }
                
                if let location = firstLocation
                {
                    self.loadUserLocation(location.coordinate)
                }
                else
                {
                    self.showAlert(message: "Drat! Something went wrong.", title: "Error")
                    self.setLoading(false)
                }
            }
        }
    }
    
    private func loadUserLocation(_ coordinate: CLLocationCoordinate2D)
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "FinishAddTagViewController") as! FinishAddTagViewController
        controller.studentInformation = buildStudentInfo(coordinate)
        self.navigationController?.pushViewController(controller, animated: true)
    }
        
    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInformation
    {
        var studentInfo = [
            "uniqueKey": ServerAPI.Auth.key,
            "firstName": ServerAPI.Auth.firstName,
            "lastName": ServerAPI.Auth.lastName,
            "mapString": locationTextField.text!,
            "mediaURL": urlTextField.text!,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            ] as [String: AnyObject]
        
        if let objectId = objectId
        {
            studentInfo["objectId"] = objectId as AnyObject
        }

        return StudentInformation(studentInfo)

    }
        
    func setLoading(_ loading: Bool)
    {
        if loading
        {
            DispatchQueue.main.async
            {
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.findLocationButton)
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.findLocationButton)
            }
        }
        DispatchQueue.main.async
        {
            self.locationTextField.isEnabled = !loading
            self.urlTextField.isEnabled = !loading
            self.findLocationButton.isEnabled = !loading
        }
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let userText = textField.text ?? ""
        guard let stringRange = Range(range, in: userText) else { return false }
        let updatedText = userText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty && updatedText == ""
        {
            if textField == locationTextField
            {
                locationTextFieldIsEmpty = true
            }
            else
            {
                urlTextFieldIsEmpty = true
            }
        }
        else
        {
            if textField == locationTextField
            {
                locationTextFieldIsEmpty = false
            }
            else
            {
                urlTextFieldIsEmpty = false
            }
        }
        
        if locationTextFieldIsEmpty == false && urlTextFieldIsEmpty == false
        {
            buttonEnabled(true, button: findLocationButton)
        }
        else
        {
            buttonEnabled(false, button: findLocationButton)
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        buttonEnabled(false, button: findLocationButton)
        if textField == locationTextField
        {
            locationTextFieldIsEmpty = true
        }
        if textField == urlTextField
        {
            urlTextFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField
        {
            nextField.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
            findLocation(sender: findLocationButton)
        }
        
        return true
    }
}
