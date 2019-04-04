//
//  ARFormTextField+Appearance.swift
//  Arrow
//
//  Created by Kiarash on 12/2/16.
//  Copyright © 2016 Arrow Application, LLC. All rights reserved.
//

import UIKit

extension ARFormTextField {
    
    public struct Appearance {
        public static var textFont: UIFont = R.font.alegreyaSansRegular(size: 24.0)!
        public static var messageFont: UIFont = R.font.alegreyaSansRegular(size: 16.0)!
        public static var textColor: UIColor = R.color.arrowColors.plainBlack()
        public static var errorMessageTextColor: UIColor = R.color.arrowColors.scarletRed()
        public static var placeholderTextColor: UIColor = R.color.arrowColors.silver()
        public static var separatorLineFocusedColor: UIColor = R.color.arrowColors.oceanBlue()
    }
    
}
