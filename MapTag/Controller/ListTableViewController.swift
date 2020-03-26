//
//  ListTableViewController.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController
{
    @IBOutlet weak var studentTableView: UITableView!
    
    var students = [StudentInformation]()
    var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        indicatorView = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.gray)
        self.view.addSubview(indicatorView)
        indicatorView.bringSubviewToFront(self.view)
        indicatorView.center = self.view.center
        showActivityIndicator()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        refreshTags()
    }
        
    @IBAction func logout(_ sender: UIBarButtonItem)
    {
        showActivityIndicator()
        ServerAPI.logout
        {
            DispatchQueue.main.async
            {
                self.dismiss(animated: true, completion: nil)
                self.hideActivityIndicator()
            }
        }
    }
        
    @IBAction func refreshList(_ sender: UIBarButtonItem)
    {
        refreshTags()
    }
        
    func refreshTags()
    {
        showActivityIndicator()
        ServerAPI.getStudentTags()
            {students, error in
            DispatchQueue.main.async
            {
                if (error == nil)
                {
                    self.students = students ?? []
                    self.tableView.reloadData()
                }
                else
                {
                    self.showAlert(message: "There was an error retrieving tags.", title: "Download Error", error: error)
                }
                self.hideActivityIndicator()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell", for: indexPath)
        let student = students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL ?? "")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let student = students[indexPath.row]
        openLink(student.mediaURL ?? "")
    }
        
    func showActivityIndicator() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    
    func hideActivityIndicator() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
}
