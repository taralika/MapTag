//
//  LoginViewController.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    var emailFieldIsEmpty = true
    var passwordFieldIsEmpty = true
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        emailField.text = ""
        passwordField.text = ""
        emailField.delegate = self
        passwordField.delegate = self
        emailField.borderStyle = .roundedRect
        passwordField.borderStyle = .roundedRect
        loginButton.layer.cornerRadius = 5
        buttonEnabled(false, button: loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        emailField.text = ""
        passwordField.text = ""
    }
        
    @IBAction func loginPressed(_ sender: UIButton)
    {
        setLoggingIn(true)
        ServerAPI.login(email: self.emailField.text ?? "", password: self.passwordField.text ?? "", completion: handleLoginResponse(success:error:))
    }
        
    @IBAction func signUp(_ sender: Any)
    {
        UIApplication.shared.open(ServerAPI.Endpoints.signup.url, options: [:], completionHandler: nil)
    }
        
    func handleLoginResponse(success: Bool, error: Error?)
    {
        setLoggingIn(false)
        if success
        {
            DispatchQueue.main.async
            {
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        }
        else
        {
            showAlert(message: "Please enter valid credentials.", title: "Login Error", error: error)
        }
    }
        
    func setLoggingIn(_ loggingIn: Bool)
    {
        if loggingIn
        {
            DispatchQueue.main.async
            {
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.loginButton)
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.loginButton)
            }
        }
        DispatchQueue.main.async
        {
            self.emailField.isEnabled = !loggingIn
            self.passwordField.isEnabled = !loggingIn
            self.loginButton.isEnabled = !loggingIn
            self.signUpButton.isEnabled = !loggingIn
        }
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let userText = textField.text ?? ""
        guard let stringRange = Range(range, in: userText) else { return false }
        let updatedText = userText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty && updatedText == ""
        {
            if textField == emailField
            {
                emailFieldIsEmpty = true
            }
            else
            {
                passwordFieldIsEmpty = true
            }
        }
        else
        {
            if textField == emailField
            {
                emailFieldIsEmpty = false
            }
            else
            {
                passwordFieldIsEmpty = false
            }
        }
        
        if emailFieldIsEmpty == false && passwordFieldIsEmpty == false
        {
            buttonEnabled(true, button: loginButton)
        }
        else
        {
            buttonEnabled(false, button: loginButton)
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        buttonEnabled(false, button: loginButton)
       
        if textField == emailField
        {
            emailFieldIsEmpty = true
        }
        
        if textField == passwordField
        {
            passwordFieldIsEmpty = true
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
            loginPressed(loginButton)
        }
        
        return true
    }
}
