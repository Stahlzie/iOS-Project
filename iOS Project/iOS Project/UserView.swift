//
//  UserView.swift
//  iOS Project
//
//  Created by Kory Kappel on 4/7/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit
import TwitterKit

class UserView: UIViewController {
    
    var tweetView = TWTRTweetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Twitter.sharedInstance().logInGuestWithCompletion { session, error in
            if let validSession = session {
                Twitter.sharedInstance().APIClient.loadTweetWithID("20") { tweet, error in
                    if let t = tweet {
                        self.tweetView.configureWithTweet(t)
                        NSLog("Description: " + t.description)
                        NSLog("/n/n")
                        NSLog("Favorite Count: " + t.favoriteCount.description)
                        NSLog("Retweet Count: " + t.retweetCount.description)
                    } else {
                        NSLog("Failed to load Tweet: \(error.localizedDescription)")
                    }
                }
            } else {
                NSLog("Unable to login as guest: \(error.localizedDescription)")
            }
        }
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
