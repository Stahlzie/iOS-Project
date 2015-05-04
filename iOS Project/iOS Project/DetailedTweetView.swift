//
//  DetailedTweetView.swift
//  iOS Project
//
//  Created by Kory Kappel on 5/3/15.
//  Copyright (c) 2015 The Organization. All rights reserved.
//

import UIKit

//used to dismiss this view when back button is pressed
protocol ChildDelegate {
    func done(child: DetailedTweetView)
}

class DetailedTweetView: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var url : NSURL!
    var delegate : ChildDelegate!
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        delegate.done(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //let url = NSURL(string: text)
        let request = NSURLRequest(URL: url!)
        self.webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
