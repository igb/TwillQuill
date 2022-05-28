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
    var toolPicker: PKToolPicker!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    /// Set up the drawing initially.
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
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



    

    
    
}

