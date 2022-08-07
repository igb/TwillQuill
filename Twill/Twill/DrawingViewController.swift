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

      //  cell.backgroundColor = UIColor.blue
        
     //   cell.layer.cornerRadius = 3.0
        cell.layer.borderWidth = 10
    cell.layer.borderColor = CGColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tap(_:))));
        NSLog( "index path " + (indexPath.item as NSNumber).stringValue);
        print(indexPath)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var pkDrawing = appDelegate.getPKDrawing(id:((indexPath.item as NSNumber).stringValue));
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
    
    
  

    @objc func tap(_ sender: UITapGestureRecognizer) {
        print("tapped!");
        print(sender);
        let location = sender.location(in: self.collection)
        print(location)

      // let location = sender.location(in: self.collectionView)
       let indexPath = self.collection.indexPathForItem(at: location)

       if let index = indexPath {
           var selected = (index.item as NSNumber).stringValue;
           print("Got clicked on index: \((index.item as NSNumber).stringValue)!")
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

