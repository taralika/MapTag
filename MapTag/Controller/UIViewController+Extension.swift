//
//  UIViewController+Extension.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit
import CoreLocation

extension UIViewController
{
    @IBAction func addLocation(sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "addLocation", sender: sender)
    }
        
    func buttonEnabled(_ enabled: Bool, button: UIButton)
    {
        if enabled
        {
            button.isEnabled = true
            button.alpha = 1.0
        }
        else
        {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
        
    func showAlert(message: String, title: String, error: Error? = nil)
    {
        DispatchQueue.main.async
        {
            var message = message
            var title = title
            
            if error != nil && ((error! as NSError).code == NSURLErrorTimedOut || (error! as NSError).code == NSURLErrorNotConnectedToInternet || (error! as NSError).code == NSURLErrorNetworkConnectionLost || (error! as NSError).code == NSURLErrorCannotConnectToHost || (error! as NSError).code == NSURLErrorDataNotAllowed || (error! as NSError).code == NSURLErrorInternationalRoamingOff || (error! as NSError).code == CLError.network.rawValue)
            {
                message = "Please check your network connection and try again."
                title = "Connection Error"
            }
            
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true)
        }
    }
        
    func openLink(_ url: String)
    {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showAlert(message: "Cannot open URL.", title: "Invalid URL")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
}
