//
//  TweetModalController.swift
//  Twill
//
//  Created by Ian Brown on 7/31/22.
//


import Foundation

import UIKit
import PencilKit

class TweetModalController:  UIViewController, UITextViewDelegate {
    
    let WHATS_HAPPENING = "What's happening?";
    let DEFAULT_ALT_TEXT =  "A drawing done on an iPad."
    
    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var altText: UITextView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tcc: UILabel!
    @IBOutlet weak var acc: UILabel!
    @IBOutlet weak var tweet: UIButton!



    
    @IBAction func sendTweet(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        let apiKey = defaults.string(forKey: "api_key")
        let apiSecret = defaults.string(forKey: "api_secret")
        let accessToken = defaults.string(forKey: "access_token")
        let accessTokenSecret = defaults.string(forKey: "access_token_secret")
      
        let twitter = TwitterClient(apiKey: apiKey!, apiSecret: apiSecret!, accessToken: accessToken!, accessTokenSecret: accessTokenSecret!);

        
        NSLog("tweeting...")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let pkDrawing = appDelegate.getPKDrawing(id: appDelegate.getCurrentIndex());

        twitter.tweetImage(image: pkDrawing.image(from: pkDrawing.bounds, scale: 1).pngData()!, altText: altText.text, status: tweetText.text);
        NSLog("tweeted...")
        performSegue(withIdentifier: "cancel", sender: self)


        
    }
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        performSegue(withIdentifier: "cancel", sender: self)

    }
    func initializeTextView(textView: UITextView, defaultText: String, counter:UILabel) {
        if (textView.text == defaultText) {
            textView.textColor = UIColor.black;
            textView.text = "";
            counter.text = "0";
        }
    }

    func validateTweet(textView: UITextView, counter: UILabel) {
        counter.text = (textView.text.count as NSNumber).stringValue;
        var limit = 0;
        
        switch (textView) {
        case tweetText: limit = 280
        case altText: limit = 1000
        default: break
        }
        
        if (textView.text.count > limit) {
            counter.textColor = UIColor.red;
            tweet.isEnabled = false;
        } else if (textView.text.count > (limit - 20)) {
            counter.textColor = UIColor.orange;
        } else {
            counter.textColor = UIColor.black;
            tweet.isEnabled = true;
        }
        
    }

    func textViewDidChange(_ textView: UITextView) {
        switch (textView) {
        case tweetText: validateTweet(textView:tweetText, counter:tcc)
        case altText: validateTweet(textView:altText, counter:acc)
        default: break
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch (textView) {
        case tweetText: initializeTextView(textView:tweetText, defaultText:WHATS_HAPPENING, counter:tcc)
        case altText: initializeTextView(textView:altText, defaultText:DEFAULT_ALT_TEXT, counter:acc)
        default: break
        }
        
    }



    

    /// Set up the drawing initially.
       override func viewWillAppear(_ animated: Bool) {
           
           let appDelegate = UIApplication.shared.delegate as! AppDelegate

           
           super.viewWillAppear(animated)
           tweetText.layer.cornerRadius = 3
                 // Add borderWidth as otherwise you are having a 0 point wide border
           tweetText.layer.borderWidth = 1
           tweetText.layer.borderColor = UIColor.blue.cgColor
           tweetText.text = WHATS_HAPPENING;
           tweetText.delegate = self;
           tweetText.textColor = UIColor.lightGray;
           
           tcc.text="";

           
           let pkDrawing = appDelegate.getPKDrawing(id: appDelegate.getCurrentIndex());
           
           let nsImage = pkDrawing.image(from: pkDrawing.bounds, scale: 1);
           image.image=nsImage;
             
           
           
           
           altText.layer.cornerRadius = 3
                 // Add borderWidth as otherwise you are having a 0 point wide border
           altText.layer.borderWidth = 1
           altText.layer.borderColor = UIColor.blue.cgColor
           
           altText.text = DEFAULT_ALT_TEXT;
           altText.delegate = self;
           altText.textColor = UIColor.lightGray;
           
           acc.text="";
           
           appDelegate.listDrawings();
       }
    
}

