//
//  ApiJson.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct ApiJson: JSONInitializable {
    
    // MARK: - Properties
    
    let imagesBaseURLString: String
    let imagesSecureBaseURLString: String
    let backdropSizes: [String]
    let logoSizes: [String]
    let posterSizes: [String]
    let profileSizes: [String]
    let stillSizes: [String]
    
    // MARK: - JSONInitializable initializer
    
    init(json: JSON) {
        self.imagesBaseURLString = json["images"]["base_url"].stringValue
        self.imagesSecureBaseURLString = json["images"]["secure_base_url"].stringValue
        self.backdropSizes = json["images"]["backdrop_sizes"].arrayValue.map({ $0.stringValue })
        self.logoSizes = json["images"]["logo_sizes"].arrayValue.map({ $0.stringValue })
        self.posterSizes = json["images"]["poster_sizes"].arrayValue.map({ $0.stringValue })
        self.profileSizes = json["images"]["profile_sizes"].arrayValue.map({ $0.stringValue })
        self.stillSizes = json["images"]["still_sizes"].arrayValue.map({ $0.stringValue })
    }
}

