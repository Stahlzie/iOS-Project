//
//  UserView.swift
//  iOS Project
//
//  Created by Kory Kappel on 4/7/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit

class UserView: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var childTable : UserTableViewController!
    
    var labelsThatWereVisible : [UILabel] = []
    
    var topTwitterAccounts : [String] = ["katyperry", "justinbieber", "barackobama", "taylorswift13", "jtimberlake", "theellenshow", "cristiano", "kimkardashian", "cnnbrk", "jimmyfallon", "billgates", "kingjames", "espn", "conanobrien", "nytimes", "nba", "facebook", "leodicaprio", "kanyewest", "google", "stephenathome", "nfl", "mcuban", "neymarjr", "gordonramsay", "oprah"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        childTable = self.childViewControllers[0] as! UserTableViewController
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var child = segue.destinationViewController as! UserTableViewController
        child.parent = self
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        childTable.userToSearch = searchBar.text
        searchBar.resignFirstResponder()
        container.hidden = false
        labelsThatWereVisible = []
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.container.hidden = true
        //stops scrolling
        childTable.tableView.setContentOffset(childTable.tableView.contentOffset, animated: false)
        
        //hides the retweet labels
        for label in childTable.labels {
            if label.hidden == false {
                labelsThatWereVisible.append(label)
                label.hidden = true
            }
        }
        
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
        for label in labelsThatWereVisible {
            label.hidden = false
        }
        labelsThatWereVisible = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //allows the view controller to respond to motion events
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            let randomIndex = Int(arc4random_uniform(UInt32(topTwitterAccounts.count)))
            childTable.userToSearch = topTwitterAccounts[randomIndex]
            searchBar.text = ""
        }
    }
}
