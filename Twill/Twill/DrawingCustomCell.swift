//
//  DrawingCustomCell.swift
//  Twill
//
//  Created by Ian Brown on 8/1/22.
//

import Foundation

import UIKit
import PencilKit

class DrawingCustomCell:  UICollectionViewCell {
    
    func setImage(image:UIImage){
        
        var imageview:UIImageView=UIImageView(frame: CGRect(x: 50, y: 50, width: 200, height: 200));

       
       
        
        imageview.image = image;
        
        var label = UILabel()
        label.text = "HI!"
        
        self.contentView.addSubview(label)
        

       // contentView.addSubview(imageview)
    }

        
    
   
}

       
    


