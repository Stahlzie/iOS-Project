//
//  UserTableViewController.swift
//  iOS Project
//
//  Created by Zachary D. Stahl on 4/8/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit
import TwitterKit

class UserTableViewController: UITableViewController, TWTRTweetViewDelegate {
    let tweetTableReuseIdentifier = "UserCell"
    // Hold all the loaded Tweets
    var tweets: [TWTRTweet] = [] {
        didSet {
            tweets.sort{ $0.0.retweetCount > $1.retweetCount }
            tableView.reloadData()
        }
    }

    var userToSearch: String = "" {
        didSet {
            if(oldValue != userToSearch) {
                searchTweetsByUser()
                
            }
        }
    }
    
    var labels:[UILabel] = []
    var firstTimeRan : [Bool]!
    
    override func viewDidLoad() {
        // Setup the table view
        tableView.estimatedRowHeight = 150
        //tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        
        //LoadTweets
        userToSearch = "verge"
        
        labels.reserveCapacity(50)
        //firstTimeRan.reserveCapacity(50)
        let label = UILabel()
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        label.textColor = UIColor.blackColor()
        for i in 0...50 {
            labels.append(label)
            //firstTimeRan[i] = true
        }
        
        //tableView.hidden = true
        
        //TWTRTweetView.appearance().theme = .Light
    }
    
    // MARK: UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tweet = tweets[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as! TWTRTweetTableViewCell
        cell.configureWithTweet(tweet)
        cell.tweetView.delegate = self
        
        
        //self.labels[indexPath.row].removeFromSuperview()
        
        
        //add our own retweet count label to the cell
        
        //var lab = UILabel()
//        if firstTimeRan[indexPath.row] {
//            labels[indexPath.row].frame = CGRectMake(10, cell.frame.size.height/2, 30, 20)
//            
//            cell.addSubview(labels[indexPath.row])
//            labels[indexPath.row].tag = 101
//            firstTimeRan[indexPath.row] = false
//        } else {
//            lab = labels[indexPath.row].viewWithTag(101)
//        }
//        lab.text = tweet.retweetCount.description
        
        //cell.addSubview(labels[indexPath.row])
        
        
        
        //this worked, but was pushing the tweet off the screen:
        //cell.textLabel!.text = tweet.retweetCount.description
        //        cell.textLabel!.frame = CGRectMake(10, cell.frame.size.height/2, 30, 20)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        return TWTRTweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds))
    }
    
    
    //COULD POTENTIALLY USE THIS LATER TO DO STUFF
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
    }
    
    private func searchTweetsByUser() -> Void {
        Twitter.sharedInstance().logInGuestWithCompletion { session, error in
            if let validSession = session {
                //let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
                let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
                var params = Dictionary<String,String>()
                params["screen_name"] = self.userToSearch
                params["include_rts"] = "false"
                params["count"] = "50"
                params["result_type"] = "popular"
                var clientError : NSError?
                
                let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params, error: &clientError)
                
                if request != nil {
                    Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                        (response, data, connectionError) -> Void in
                        if (connectionError == nil) {
                            
                            var maybeJSONError: NSError?
                            let jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &maybeJSONError)
                            
                            // Check for parsing errors.
                            if let JSONError = maybeJSONError {
                                NSLog(JSONError.description)
                            } else {
                                // Extract the Tweets and create Tweet objects from the JSON data.
                                let jsonTweets = jsonData as! NSArray
                                let resultTweets = TWTRTweet.tweetsWithJSONArray(jsonTweets as [AnyObject]) as! [TWTRTweet]
                                
                                self.tweets =  resultTweets
                                
//                                self.labels.removeAll(keepCapacity: false)
//                                for tweet in resultTweets {
//                                    self.labels.append(UILabel())
//                                }
                                //self.labels.reserveCapacity(resultTweets.count)
                            }
                        }
                        else {
                            NSLog("Error: \(connectionError)")
                        }
                    }
                }
                else {
                    println("Error: \(clientError)")
                }
                
            } else {
                NSLog("Unable to login as guest: \(error.localizedDescription)")
            }
        }
    }
}

//class UserTableViewController: UITableViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }
//
//    /*
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
//
//        // Configure the cell...
//
//        return cell
//    }
//    */
//
//    /*
//    // Override to support conditional editing of the table view.
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return NO if you do not want the specified item to be editable.
//        return true
//    }
//    */
//
//    /*
//    // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
//    */
//
//    /*
//    // Override to support rearranging the table view.
//    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//
//    }
//    */
//
//    /*
//    // Override to support conditional rearranging of the table view.
//    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return NO if you do not want the item to be re-orderable.
//        return true
//    }
//    */
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
