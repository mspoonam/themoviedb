//
//  ApiHelper.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import SwiftyJSON

public final class ApiHelper {
    
    // MARK: - singleton
    
    static let instance: ApiHelper = ApiHelper()
    
    // MARK: - Properties
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    fileprivate(set) var imgHandler: ImageHandler? = nil
    
    // MARK: - Initializer (private)
    
    fileprivate init() {}
    
    // MARK: -
    
    public func start() {
        
        // Start updating the API configuration (Every four days)
        // FIXME: - Improve this by performing background fetch
        let days: RxTimeInterval = 4.0 * 60.0 * 60.0 * 24.0
        Observable<Int>
            .timer(0, period: days, scheduler: MainScheduler.instance)
            .flatMap { (_) -> Observable<ApiJson> in
                return self.configuration()
            }.map { (apiConfiguration) -> ImageHandler in
                return ImageHandler(apiData: apiConfiguration)
            }.subscribe(onNext: { (imgHandler) in
                self.imgHandler = imgHandler
            }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Configuration
    
    fileprivate func configuration() -> Observable<ApiJson> {
        return Observable.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.configuration)
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        let apiConfiguration = ApiJson(json: JSON(data))
                        observer.onNext(apiConfiguration)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
            }
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Search films
    
    public func films(withTitle title: String, startingAtPage page: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<[MovieItemEntity]> {
        let parameters: FilmSearchParameters = FilmSearchParameters(query: title, atPage: page)
        return ApiHelper.instance.films(fromList: [], with: parameters, loadNextPageTrigger: trigger)
    }
    
    fileprivate func films(fromList currentList: [MovieItemEntity], with parameters: FilmSearchParameters, loadNextPageTrigger trigger: Observable<Void>) -> Observable<[MovieItemEntity]> {
        return self.films(with: parameters).flatMap { (Paginator) -> Observable<[MovieItemEntity]> in
            let newList = currentList + Paginator.results
            if let _ = Paginator.nextPage {
                return Observable.concat([
                    Observable.just(newList),
                    Observable.never().takeUntil(trigger),
                    self.films(fromList: newList, with: parameters.nextPage, loadNextPageTrigger: trigger)
                    ])
            } else { return Observable.just(newList) }
        }
    }
    
    fileprivate func films(with parameters: FilmSearchParameters) -> Observable<Paginator<MovieItemEntity>> {
        guard !parameters.query.isEmpty else { return Observable.just(Paginator.Empty()) }
        return Observable<Paginator<MovieItemEntity>>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.searchFilms(parameters: parameters))
                .validate()
                .responsePaginatedFilms(queue: nil, completionHandler: { (response) in
                    switch response.result {
                    case .success(let Paginator):
                        observer.onNext(Paginator)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Popular films
    
    public func popularFilms(startingAtPage page: Int = 0, loadNextPageTrigger trigger: Observable<Void> = Observable.empty()) -> Observable<[MovieItemEntity]> {
        return ApiHelper.instance.popularFilms(fromList: [], atPage: page, loadNextPageTrigger: trigger)
    }
    
    fileprivate func popularFilms(fromList currentList: [MovieItemEntity], atPage page: Int, loadNextPageTrigger trigger: Observable<Void>) -> Observable<[MovieItemEntity]> {
        return self.popularFilms(atPage: page).flatMap { (Paginator) -> Observable<[MovieItemEntity]> in
            let newList = currentList + Paginator.results
            if let nextPage = Paginator.nextPage {
                return Observable.concat([
                    Observable.just(newList),
                    Observable.never().takeUntil(trigger),
                    self.popularFilms(fromList: newList, atPage: nextPage, loadNextPageTrigger: trigger)
                    ])
            } else { return Observable.just(newList) }
        }
    }
    
    fileprivate func popularFilms(atPage page: Int = 0) -> Observable<Paginator<MovieItemEntity>> {
        return Observable<Paginator<MovieItemEntity>>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.popularFilms(page: page))
                .validate()
                .responsePaginatedFilms(queue: nil, completionHandler: { (response) in
                    switch response.result {
                    case .success(let Paginator):
                        observer.onNext(Paginator)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create { request.cancel() }
        }
    }
    
    // MARK: - Film detail
    
    public func filmDetail(fromId filmId: Int) -> Observable<MovieDetailItemEntity> {
        return Observable<MovieDetailItemEntity>.create { (observer) -> Disposable in
            let request = Alamofire
                .request(Router.filmDetail(filmId: filmId))
                .validate()
                .responseFilmDetail { (response) in
                    switch response.result {
                    case .success(let filmDetail):
                        observer.onNext(filmDetail)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
            }
            return Disposables.create { request.cancel() }
        }
    }
    
    
    //    // MARK: - Person
    //
    //    public func person(forId id: Int) -> Observable<PersonDetail> {
    //        return Observable<PersonDetail>.create { (observer) -> Disposable in
    //            let request = Alamofire
    //                .request(Router.person(id: id))
    //                .validate()
    //                .responsePersonDetail { (response) in
    //                    switch response.result {
    //                    case .success(let personDetail):
    //                        observer.onNext(personDetail)
    //                        observer.onCompleted()
    //                    case .failure(let error):
    //                        observer.onError(error)
    //                    }
    //            }
    //            return Disposables.create { request.cancel() }
    //        }
    //    }
    //
    //    public func filmsCredited(forPersonId id: Int) -> Observable<FilmsCredited> {
    //        return Observable<FilmsCredited>.create { (observer) -> Disposable in
    //            let request = Alamofire
    //                .request(Router.personCredits(id: id))
    //                .validate()
    //                .responseCreditedFilms { (response) in
    //                    switch response.result {
    //                    case .success(let creditedFilms):
    //                        observer.onNext(creditedFilms)
    //                        observer.onCompleted()
    //                    case .failure(let error):
    //                        observer.onError(error)
    //                    }
    //            }
    //            return Disposables.create { request.cancel() }
    //        }
    //    }
}

// MARK: -

extension Alamofire.DataRequest {
    
    // MARK: - Films response serializer
    
    static func filmsResponseSerializer() -> DataResponseSerializer<[MovieItemEntity]> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .success([]) }
                let jsonArray = JSON(data: data)["results"].arrayValue
                return .success(jsonArray.map({ MovieItemEntity(json: $0) }))
            }
        }
    }
    
    @discardableResult func responseFilms(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[MovieItemEntity]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.filmsResponseSerializer(), completionHandler: completionHandler)
    }
    
    // MARK: - Paginated list of films response serializer
    
    static func paginatedFilmsResponseSerializer() -> DataResponseSerializer<Paginator<MovieItemEntity>> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .success(Paginator.Empty()) }
                let json = JSON(data: data)
                guard
                    let page = json["page"].int,
                    let totalResults = json["total_results"].int,
                    let totalPages = json["total_pages"].int else { return .success(Paginator.Empty()) }
                let films = json["results"].arrayValue.map({ MovieItemEntity(json: $0) })
                let paginator = Paginator(page: page - 1, totalResults: totalResults, totalPages: totalPages, results: films)
                return .success(paginator)
            }
        }
    }
    
    @discardableResult func responsePaginatedFilms(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Paginator<MovieItemEntity>>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.paginatedFilmsResponseSerializer(), completionHandler: completionHandler)
    }
    
    // MARK: - Film detail response serializer
    
    static func filmDetailResponseSerializer() -> DataResponseSerializer<MovieDetailItemEntity> {
        return DataResponseSerializer { (request, response, data, error) in
            if let error = error { return .failure(error) }
            else {
                guard let data = data else { return .failure(DataError.noData) }
                let json = JSON(data: data)
                let filmDetail = MovieDetailItemEntity(json: json)
                return .success(filmDetail)
            }
        }
    }
    
    @discardableResult func responseFilmDetail(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<MovieDetailItemEntity>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.filmDetailResponseSerializer(), completionHandler: completionHandler)
    }
   
}

