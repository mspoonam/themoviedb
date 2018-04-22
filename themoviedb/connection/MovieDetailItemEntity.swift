//
//  MovieDetailItemEntity.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import SwiftyJSON

public final class MovieDetailItemEntity: MovieItemEntity {
    
    // MARK: - Properties
    
    let homepage: URL?
    let detailId: Int?
    let filmOverview: String?
    let runtime: Int?
    
    // MARK: - JSONInitializable initializer
    
    public required init(json: JSON) {
        self.homepage = json["homepage"].URL
        self.detailId = json["imdb_id"].int
        self.filmOverview = json["overview"].string
        self.runtime = json["runtime"].int
        super.init(json: json)
    }
}


