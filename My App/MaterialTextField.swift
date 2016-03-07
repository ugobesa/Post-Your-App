//
//  MaterialTextField.swift
//  My App
//
//  Created by Ugo Besa on 13/02/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        
    }

    //For placeholder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0) // will move the text to te right by 10.
    }
    
    // For editable text
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
}
