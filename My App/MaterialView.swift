//
//  MaterialView.swift
//  My App
//
//  Created by Ugo Besa on 13/02/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit

class MaterialView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0 // length of the blur
        layer.shadowOffset = CGSizeMake(0, 2.0) // width = 0 because we want the shadow in both side, we use the shadowRadius
    }


}
