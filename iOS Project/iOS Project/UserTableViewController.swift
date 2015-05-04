//
//  UserTableViewController.swift
//  iOS Project
//
//  Created by Zachary D. Stahl on 4/8/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit
import TwitterKit

class UserTableViewController: UITableViewController, TWTRTweetViewDelegate, ChildDelegate {
    
    var labels:[UILabel] = []
    var parent : UserView!
    var actInd : UIActivityIndicatorView!
    var everythingSetUp : Bool = false //necessary because "scrollViewDidScroll" was running before table was set up
    var tweetToLoadInWebView : TWTRTweet!
    
    override func viewDidLoad() {
        // Setup the table view
        tableView.estimatedRowHeight = 150
        tableView.allowsSelection = true
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        
        //Default user to search
        userToSearch = "verge"
    }
    
    let tweetTableReuseIdentifier = "UserCell"
    // Hold all the loaded Tweets
    var tweets: [TWTRTweet] = [] {
        didSet {
            tweets.sort{ $0.retweetCount > $1.retweetCount }
            tableView.reloadData()
            self.everythingSetUp = true
        }
    }
    
    func done(child: DetailedTweetView) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    var userToSearch: String = "" {
        didSet {
            if(oldValue != userToSearch && userToSearch != "") {
                
                //set up the spinner
                actInd = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
                actInd.center = self.parent.view.center
                actInd.hidesWhenStopped = true
                actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                view.addSubview(actInd)
                
                //START SPINNER:
                actInd.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                
                self.searchTweetsByUser() //runs the Twitter API function (in background)
                
                
                //low priority because it's not a UI element (saves search to file)
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)) {
                    var fm = NSFileManager.defaultManager()
                    var fileData = NSData()
                    let str : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
                    let libPath = str.stringByAppendingPathComponent("usernamehistory")
                    if (fm.fileExistsAtPath(libPath)) {
                        fileData = NSData(contentsOfFile: libPath)!
                        var historyString = NSString(data: fileData, encoding: NSUTF8StringEncoding)! as String
                        var historyArray = historyString.componentsSeparatedByString(",")
                        if !contains(historyArray, self.userToSearch) {
                            historyArray.append(self.userToSearch)
                        }
                        var newHistoryString = ""
                        for (index, element) in enumerate(historyArray) {
                            if (index != historyArray.count-1) {
                                newHistoryString += element + ","
                            } else {
                                newHistoryString += element
                            }
                        }
                        newHistoryString.writeToFile(libPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
                        
                    } else {
                        fm.createFileAtPath(libPath, contents: fileData, attributes: nil)
                    }
                }
            }
        }
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
        
        //show the tweet's corresponding retweet count label
        labels[indexPath.row].hidden = false
        var rectInTableView = tableView.rectForRowAtIndexPath(indexPath)
        var rectInSuperView = tableView.convertRect(rectInTableView, toView: self.parent.view)
        labels[indexPath.row].center = CGPointMake(17, rectInSuperView.midY)
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        return TWTRTweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds))
    }
    
    //passes selected tweet's permalink to the webview
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let child = segue.destinationViewController as! DetailedTweetView
        child.url = tweetToLoadInWebView.permalink
        child.delegate = self
    }
    
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
        tweetToLoadInWebView = tweet
        performSegueWithIdentifier("userTweetDetailSegue", sender: self)
    }
    
    private func searchTweetsByUser() -> Void {
        Twitter.sharedInstance().logInGuestWithCompletion { session, error in
            if let validSession = session {
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
                                self.stopSpinner()
                            } else {
                                // Extract the Tweets and create Tweet objects from the JSON data.
                                let jsonTweets = jsonData as! NSArray
                                let resultTweets = TWTRTweet.tweetsWithJSONArray(jsonTweets as [AnyObject]) as! [TWTRTweet]
                                
                                self.tweets =  resultTweets
                                
                                self.labels.removeAll(keepCapacity: false)
                                //create retweet count labels for every tweet
                                for tweet in self.tweets {
                                    var label = UILabel(frame: CGRectMake(0, 0, 80, 21))
                                    label.textAlignment = NSTextAlignment.Right
                                    label.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
                                    label.text = tweet.retweetCount.description
                                    label.hidden = true
                                    label.textColor = UIColor.redColor()
                                    self.parent.view.addSubview(label)
                                    self.labels.append(label)
                                }
                                self.parent.view.bringSubviewToFront(self.parent.searchBar)
                                
                                self.stopSpinner()
                            }
                        }
                        else {
                            NSLog("Error: \(connectionError)")
                            self.stopSpinner()
                        }
                    }
                }
                else {
                    println("Error: \(clientError)")
                    self.stopSpinner()
                }
                
            } else {
                NSLog("Unable to login as guest: \(error.localizedDescription)")
                self.stopSpinner()
            }
        }
    }
    
    func stopSpinner() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.actInd.stopAnimating()
        self.actInd.removeFromSuperview()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !everythingSetUp {return}
        
        var visibleRows = tableView.indexPathsForVisibleRows() as! [NSIndexPath]
        for visibleRow in visibleRows {
            var rectInTableView = tableView.rectForRowAtIndexPath(visibleRow)
            var rectInSuperView = tableView.convertRect(rectInTableView, toView: self.parent.view)
            
            //make sure it's been loaded
            if labels.count > 0 {
                labels[visibleRow.row].center = CGPointMake(17, rectInSuperView.midY)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        labels[indexPath.row].hidden = true
    }
}
