//
//  PopularDetailModel.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public final class PopularDetailModel: NSObject {
    
    // MARK: - Properties
    
    let filmId: Int
    let filmDetail: Observable<MovieDetailItemEntity>
    
    // MARK: - Initializer
    
    init(withFilmId id: Int) {
        self.filmId = id
        
        self.filmDetail = Observable
            .just(())
            .flatMapLatest { (_) -> Observable<MovieDetailItemEntity> in
                return ApiHelper.instance.filmDetail(fromId: id)
            }.shareReplay(1)
        
        
        super.init()
    }
}

