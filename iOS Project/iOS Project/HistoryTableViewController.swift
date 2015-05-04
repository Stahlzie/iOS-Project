//
//  HistoryTableViewController.swift
//  iOS Project
//
//  Created by Kory Kappel on 4/30/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit

//@objc protocol HistoryDelegate {
//    optional func usernameSelected(searchString : String)
//    optional func hashtagSelected(searchString : String)
//}

class HistoryTableViewController: UITableViewController {

    var history : [String] = []
    //var delegate : HistoryDelegate!
    
    //if hashtag table, will be false
    var isUserNameTable : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return history.count - 1
    }
    
    //every time this view appears, update the table (use activity indicator)
    override func viewDidAppear(animated: Bool) {
        var fm = NSFileManager.defaultManager()
        var fileData = NSData()
        let str : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        var libPath = ""
        if isUserNameTable == true {
            libPath = str.stringByAppendingPathComponent("usernamehistory")
        } else {
            libPath = str.stringByAppendingPathComponent("hashtaghistory")
        }
        if (fm.fileExistsAtPath(libPath)) {
            fileData = NSData(contentsOfFile: libPath)!
            var historyString = NSString(data: fileData, encoding: NSUTF8StringEncoding)! as String
            history = historyString.componentsSeparatedByString(",")
        } else {
            fm.createFileAtPath(libPath, contents: fileData, attributes: nil)
        }
        
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! HistoryCell
        
        cell.searchString.text = history[history.count - indexPath.row - 1] //shows in reverse order (most recent first)
        
        return cell
    }
    
    //selecting an item from either table switches to that view and loads that string
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if isUserNameTable == true {
            //delegate.usernameSelected!(history[indexPath.row])
            tabBarController?.selectedIndex = 0
            var controllers = tabBarController?.viewControllers as! [UIViewController]
            var controller = controllers[0] as! UserView
            controller.childTable.userToSearch = history[history.count - indexPath.row - 1]
            controller.searchBar.text = ""
            
        } else {
            //delegate.hashtagSelected!(history[indexPath.row])
            tabBarController?.selectedIndex = 1
            var controllers = tabBarController?.viewControllers as! [UIViewController]
            var controller = controllers[1] as! HashtagView
            controller.childTable.hashtagToSearch = history[history.count - indexPath.row - 1]
            controller.searchBar.text = ""
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
