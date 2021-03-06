//
//  NibLoadView.swift
//  LiveProduct
//
//  Created by kaito on 2018/1/23.
//  Copyright © 2018年 kaito. All rights reserved.
//

import UIKit

protocol NibLoadView {
    
}

extension NibLoadView where Self: UIView {
    
    static var nib: UINib {
        return UINib(nibName: self.className, bundle: Bundle(for: self))
    }
}

extension NibLoadView where Self: NSObject {
    
    /// loadViewFromXibName
    ///
    /// - Parameter nibname: xibName
    /// - Returns: view
    static func loadFromNib(_ nibname: String? = nil) -> Self? {
        let loadName = nibname == nil ? "\(self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as? Self
    }
}
