//
//  UserView.swift
//  iOS Project
//
//  Created by Kory Kappel on 4/7/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit
//import TwitterKit

class UserView: UIViewController, UISearchBarDelegate {
    
//    var tweetView = TWTRTweetView()
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //var searchActive : Bool!
    //var searchString : String!
    var childTable : UserTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        //searchActive = false
        //searchString = ""
        
        childTable = self.childViewControllers[0] as! UserTableViewController
        
//        Twitter.sharedInstance().logInGuestWithCompletion { session, error in
//            if let validSession = session {
//                Twitter.sharedInstance().APIClient.loadTweetWithID("20") { tweet, error in
//                    if let t = tweet {
//                        self.tweetView.configureWithTweet(t)
//                        NSLog("Description: " + t.description)
//                        NSLog("/n/n")
//                        NSLog("Favorite Count: " + t.favoriteCount.description)
//                        NSLog("Retweet Count: " + t.retweetCount.description)
//                    } else {
//                        NSLog("Failed to load Tweet: \(error.localizedDescription)")
//                    }
//                }
//            } else {
//                NSLog("Unable to login as guest: \(error.localizedDescription)")
//            }
//        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        childTable.userToSearch = searchBar.text
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
