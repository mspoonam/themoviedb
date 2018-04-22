//
//  MovieItemEntity.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import SwiftyJSON

public class MovieItemEntity: NSObject, JSONInitializable {
    
    // MARK: - Properties
    
    let id: Int
    let posterPathString: String?
    let adult: Bool
    let overview: String
    let releaseDate: Date
    let genreIds: [Int]
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let backdropPathString: String?
    let popularity: Double
    let voteCount: Int
    let video: Bool
    let voteAverage: Double
    let favourite: Bool
    
    // MARK: - Computed properties
    
    var fullTitle: String {
        return self.title     }
    
    var posterPath: ImgPath? {
        guard let posterPathString = self.posterPathString else { return nil }
        return ImgPath.poster(path: posterPathString)
    }
    
    var backdropPath: ImgPath? {
        guard let backdropPathString = self.backdropPathString else { return nil }
        return ImgPath.backdrop(path: backdropPathString)
    }
    
    // MARK: - JSONInitializable initializer
    
    public required init(json: JSON) {
        self.id = json["id"].intValue
        self.posterPathString = json["poster_path"].string
        self.adult = json["adult"].boolValue
        self.overview = json["overview"].stringValue
        self.releaseDate = json["release_date"].dateValue
        self.genreIds = json["genre_ids"].arrayValue.flatMap({ $0.int })
        self.originalTitle = json["original_title"].stringValue
        self.originalLanguage = json["original_language"].stringValue
        self.title = json["title"].stringValue
        self.backdropPathString = json["backdrop_path"].string
        self.popularity = json["popularity"].doubleValue
        self.voteCount = json["popularity"].intValue
        self.video = json["video"].boolValue
        self.voteAverage = json["vote_average"].doubleValue
        self.favourite = false
        
        super.init()
    }
}

// MARK: -

extension MovieItemEntity {
    
    // MARK: - Description
    
    public override var description: String {
        let dateString: String = DtHandler.SharedFormatter.string(from: self.releaseDate)
        return "\(self.originalTitle) (\(dateString))"
    }
    
    public override var debugDescription: String { return self.description }
}

// MARK: -

extension Array where Element: MovieItemEntity {
    
    var withoutDuplicates: [MovieItemEntity] {
        var exists: [Int: Bool] = [:]
        return self.filter { exists.updateValue(true, forKey: $0.id) == nil }
    }
}

