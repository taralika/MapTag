//
//  MapViewController.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import MapKit

class MapViewController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locations = [StudentInformation]()
    var annotations = [MKPointAnnotation]()
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTags()
    }
        
    @IBAction func logout(_ sender: UIBarButtonItem)
    {
        self.activityIndicator.startAnimating()
        ServerAPI.logout
        {
            DispatchQueue.main.async
            {
                self.dismiss(animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
            }
        }
    }
        
    @IBAction func refreshMap(_ sender: UIBarButtonItem)
    {
        refreshTags()
    }
        
    func refreshTags()
    {
        self.activityIndicator.startAnimating()
        ServerAPI.getStudentTags()
        { locations, error in
            DispatchQueue.main.async
            {
                if (error == nil)
                {
                    self.mapView.removeAnnotations(self.annotations)
                    self.annotations.removeAll()
                    self.locations = locations ?? []
                    for dictionary in locations ?? []
                    {
                        let latitude = CLLocationDegrees(dictionary.latitude ?? 0.0)
                        let longitude = CLLocationDegrees(dictionary.longitude ?? 0.0)
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let firstName = dictionary.firstName
                        let lastName = dictionary.lastName
                        let mediaURL = dictionary.mediaURL
                        let tag = MKPointAnnotation()
                        tag.coordinate = coordinate
                        tag.title = "\(firstName) \(lastName)"
                        tag.subtitle = mediaURL
                        self.annotations.append(tag)
                    }
                
                    self.mapView.addAnnotations(self.annotations)
                }
                else
                {
                    self.showAlert(message: "There was an error retrieving tags.", title: "Download Error", error: error)
                }
                
                self.activityIndicator.stopAnimating()
            }
        }
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let tagID = "tag"
        var tagView = mapView.dequeueReusableAnnotationView(withIdentifier: tagID) as? MKPinAnnotationView
        if tagView == nil
        {
            tagView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: tagID)
            tagView!.canShowCallout = true
            tagView!.pinTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            tagView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else
        {
            tagView!.annotation = annotation
        }
        return tagView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView
        {
            if let toOpen = view.annotation?.subtitle
            {
                openLink(toOpen ?? "")
            }
        }
    }
}
