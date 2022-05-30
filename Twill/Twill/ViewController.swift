//
//  ViewController.swift
//  Twill
//
//  Created by Ian Brown on 5/27/22.
//

import UIKit
import PencilKit

class ViewController:  UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var tweetButton: UIButton!
    

    var toolPicker: PKToolPicker!

    
    @IBAction func tweet(_ sender: UIButton) {
        
        // get api & access tokens/secrets from properties
        let defaults = UserDefaults.standard
        let apiKey = defaults.string(forKey: "api_key")
        let apiSecret = defaults.string(forKey: "api_secret")
        let accessToken = defaults.string(forKey: "access_token")
        let accessTokenSecret = defaults.string(forKey: "access_token_secret")
      
        let twitter = TwitterClient(apiKey: apiKey!, apiSecret: apiSecret!, accessToken: accessToken!, accessTokenSecret: accessTokenSecret!);

        
        NSLog("tweet")
       // UIImageWriteToSavedPhotosAlbum(canvasView.asImage(),nil,nil,nil);
     //   twitter.tweet(tweet: "YAIOTCOIYAPL: Yet Another Implementation Of Twitter's Client OAuth In Yet Another Programming Language")
        twitter.tweetImage(image: canvasView.asImage().pngData()!, altText: "A drawing done on an iPad.", status: "scribble scribble")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    /// Set up the drawing initially.
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           navigationController?.setNavigationBarHidden(true, animated: animated)

           
           // Set up the canvas view with the first drawing from the data model.
           canvasView.delegate = self
         //  canvasView.drawing = dataModelController.drawings[drawingIndex]
           canvasView.alwaysBounceVertical = true
           
           canvasView.frame(forAlignmentRect: self.view.frame)

           
           // Set up the tool picker
           if #available(iOS 14.0, *) {
               toolPicker = PKToolPicker()
           } else {
               // Set up the tool picker, using the window of our parent because our view has not
               // been added to a window yet.
               let window = parent?.view.window
               toolPicker = PKToolPicker.shared(for: window!)
           }
           
           toolPicker.setVisible(true, forFirstResponder: canvasView)
           toolPicker.addObserver(canvasView)
           toolPicker.addObserver(self)
        //   updateLayout(for: toolPicker)
           canvasView.becomeFirstResponder()
       }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    
    

    
    
}

/**
 This is how we get the image from the canvas. shrug
 */
extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

