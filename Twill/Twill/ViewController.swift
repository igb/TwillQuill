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
    @IBOutlet weak var newButton: UIButton!

    

    var toolPicker: PKToolPicker!

    
    
    @IBAction func new(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.incrementCurrentIndex();

        canvasView.drawing = PKDrawing();
        canvasView.backgroundColor = UIColor.white
        canvasView.delegate = self;
        

    }

    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Perform action.
        }
    }
    
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        NSLog("drawing changed!");
        var drawing = canvasView.drawing.dataRepresentation();
        var fileManager: FileManager = FileManager.default;
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first;
        do {
            
            try  drawing.write(to: url!.appendingPathComponent("drawing-" + appDelegate.getCurrentIndex()));
        } catch {
            NSLog("writing error");
        }
        NSLog("wrote file " + "drawing-" + appDelegate.getCurrentIndex());
       
        
    }
    
   
    
    
    

    
    
    
    @IBAction func tweet(_ sender: UIButton) {
        
        
        performSegue(withIdentifier: "tweet", sender: self)
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
   //     twitter.tweetImage(image: canvasView.asImage().pngData()!, altText: "A drawing done on an iPad.", status: "scribble scribble")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    /// Set up the drawing initially.
       override func viewWillAppear(_ animated: Bool) {
           let appDelegate = UIApplication.shared.delegate as! AppDelegate

           super.viewWillAppear(animated)
           navigationController?.setNavigationBarHidden(true, animated: animated)

           
           // Set up the canvas view with the first drawing from the data model.
           canvasView.delegate = self
         //  canvasView.drawing = dataModelController.drawings[drawingIndex]
           canvasView.alwaysBounceVertical = true
           
           canvasView.frame(forAlignmentRect: self.view.frame)
           canvasView.backgroundColor = UIColor.white
           
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
           
          
           canvasView.drawing = appDelegate.getPKDrawing(id: appDelegate.getCurrentIndex());

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

/// https://stackoverflow.com/questions/38343186/write-extend-file-attributes-swift-example
extension URL {

    /// Get extended attribute.
    func extendedAttribute(forName name: String) throws -> Data  {
        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in

            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            if (length > 0) {
                // Create buffer with required size:
                var data = Data(count: length)

                // Retrieve attribute:
                let result =  data.withUnsafeMutableBytes { [count = data.count] in
                getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
                }
                return data
            } else {
                return "".data(using: .utf8)!;
            }
        }
            
    
        return data

    }
    
    /// set extended attribute.

    func setExtendedAttribute(data: Data, forName name: String) throws {

            try self.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = data.withUnsafeBytes {
                    setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, 0)
                }
                NSLog("wrote ext attr: " + (result >= 0).description);
            }
        }
}

