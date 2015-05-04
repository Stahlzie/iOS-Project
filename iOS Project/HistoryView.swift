//
//  HistoryView.swift
//  iOS Project
//
//  Created by Kory Kappel on 4/30/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit

class HistoryView: UIViewController {

    @IBAction func clearButtonPressed(sender: AnyObject) {
        var fm = NSFileManager.defaultManager()
        var fileData = NSData()
        let str : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        
        //clearing username history
        var libPath = str.stringByAppendingPathComponent("usernamehistory")
        fileData = NSData(contentsOfFile: libPath)!
        var newHistoryString = ""
        newHistoryString.writeToFile(libPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        
        //clearing hashtag history
        libPath = str.stringByAppendingPathComponent("hashtaghistory")
        fileData = NSData(contentsOfFile: libPath)!
        newHistoryString = ""
        newHistoryString.writeToFile(libPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        
        usernameTable.history = []
        usernameTable.tableView.reloadData()
        hashtagTable.history = []
        hashtagTable.tableView.reloadData()
    }
    
    var usernameTable : HistoryTableViewController!
    var hashtagTable : HistoryTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTable = self.childViewControllers[0] as! HistoryTableViewController
        hashtagTable = self.childViewControllers[1] as! HistoryTableViewController
        usernameTable.isUserNameTable = true
        hashtagTable.isUserNameTable = false
        //usernameTable.loadTable()
        //hashtagTable.loadTable()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
