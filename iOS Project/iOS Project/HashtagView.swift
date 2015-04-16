//
//  HashtagView.swift
//  iOS Project
//
//  Created by Kory Kappel on 4/7/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit

class HashtagView: UIViewController, UISearchBarDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var container: UIView!
    
    var childTable : HashtagTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        childTable = self.childViewControllers[0] as! HashtagTableViewController


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        childTable.hashtagToSearch = searchBar.text
        searchBar.resignFirstResponder()
        container.hidden = false
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.container.hidden = true
        
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        let item = UIBarButtonItem(title: "Dismiss", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("endEditingNow") )
        var toolbarButtons = [item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        searchBar.inputAccessoryView = keyboardDoneButtonView
    }
    
    func endEditingNow() {
        searchBar.resignFirstResponder()
        container.hidden = false
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
