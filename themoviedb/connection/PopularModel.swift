//
//  PopularModel.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

final class PopularModel: NSObject {
    
    // MARK: - Properties
    
    let disposaBag: DisposeBag = DisposeBag()
    
    // Input
    let reloadTrigger: PublishSubject<Void> = PublishSubject()
    let nextPageTrigger: PublishSubject<Void> = PublishSubject()
    
    // Output
    lazy private(set) var films: Observable<[MovieItemEntity]> = self.setupFilms()
    
    // MARK: - Reactive Setup
    
    fileprivate func setupFilms() -> Observable<[MovieItemEntity]> {
        
        let trigger = self.nextPageTrigger.asObservable().debounce(0.2, scheduler: MainScheduler.instance)
        
        return self.reloadTrigger
            .asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { (_) -> Observable<[MovieItemEntity]> in
                return ApiHelper.instance.popularFilms(startingAtPage: 0, loadNextPageTrigger: trigger)
            }
            .shareReplay(1)
    }
    
}

