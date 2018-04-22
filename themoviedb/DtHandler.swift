//
//  DtHandler.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import Foundation
import UIKit

public final class DtHandler: NSObject {
    
    // MARK: - Properties
    
    static var SharedFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: - Initializer
    
    fileprivate override init() { super.init() }
}

