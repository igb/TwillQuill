//
//  DrawingViewController.swift
//  Twill
//
//  Created by Ian Brown on 7/31/22.
//

import Foundation

import UIKit
import PencilKit

class DrawingViewController:  UIViewController, UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection: UICollectionView!
    var drawings:[String] = [];
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawings.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingCell", for: indexPath) as! DrawingCustomCell

        cell.layer.borderWidth = 1
    cell.layer.borderColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // ADDING TAP GESTURE HANDLER TO SELECT DRAWING
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tap(_:))));
        
        // ADDING LONG PRESS GESTURE HANDLER TO ENABLE DELETE PROMPT

        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action:#selector(long(_:))));
        
        NSLog( "index path " + (indexPath.item as NSNumber).stringValue);
        print(indexPath)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // GET SORTED LIST OF DRAWINGS

        var drawings = appDelegate.sortDocs(drawings:(appDelegate.listDrawings()));
        for drawing in drawings {
            print("drawing:" + drawing)
        }
        
        var drawingID = appDelegate.getDrawingId(drawingName:drawings[(indexPath.item as NSNumber).intValue]);
        var pkDrawing = appDelegate.getPKDrawing(id:drawingID);
        let imageview:UIImageView=UIImageView(frame: CGRect(x: 50, y: 50, width: self.view.frame.width-200, height: 50))

        var image = pkDrawing.image(from: pkDrawing.bounds, scale: 1);
        
        var label = UILabel()
        label.text = "HI!"
        
        

        
        imageview.image=image;
        
        //cell.contentView.addSubview(imageview)
        //cell.contentView.sizeToFit();
        cell.backgroundView = imageview;
        
        //cell.setImage(image: image)
            // Configure the cell
            return cell
        
    }
    
    func deleteHandler(indexPath: IndexPath)->(_: UIAlertAction?)->() {
        return { alertAction in
            print("delete called");
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.deletePKDrawing(id:(indexPath.item as NSNumber).stringValue)
            print("delete worked?");
            self.collection.reloadData();
            }
          }
    
    @objc func long(_ sender:  UILongPressGestureRecognizer)
    {
        let location = sender.location(in: self.collection)
        let indexPath = self.collection?.indexPathForItem(at: location)
        //        let cell = self.collection?.cellForItem(at: indexPath!)
                if indexPath != nil
                {
                    let alertActionCell = UIAlertController(title: "Remove Drawing", message: "Do you want to delete this drawing?", preferredStyle: .actionSheet)
                    alertActionCell.popoverPresentationController?.sourceView=sender.view;

                    // Configure Remove Item Action
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler:deleteHandler(indexPath: indexPath!))

                    // Configure Cancel Action Sheet
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                        print("Cancel actionsheet")
                    })

                    alertActionCell.addAction(deleteAction)
                   // alertActionCell.addAction(cancelAction)
                    self.present(alertActionCell, animated: true, completion: nil)
                        
                }

    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collection)

      // let location = sender.location(in: self.collectionView)
       let indexPath = self.collection.indexPathForItem(at: location)

       if let index = indexPath {
           var selected = (index.item as NSNumber).stringValue;
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           appDelegate.setCurrentIndex(selected);
           performSegue(withIdentifier: "selected", sender: self)

           

       }
        
       
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.drawings = appDelegate.sortDocs(drawings:appDelegate.listDrawings()).reversed();
        
        collection.dataSource=self;
        collection.register(DrawingCustomCell.self, forCellWithReuseIdentifier:"DrawingCell");

        
        
        
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
      ) -> CGSize {
        // 2
          let paddingSpace = 10.0
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / 3
        
        return CGSize(width: 50, height: 50)
      }
    

}

