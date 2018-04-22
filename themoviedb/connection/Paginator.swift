//
//  Paginator.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit

public struct Paginator<T> {
    
    // MARK: - Properties
    
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [T]
    
    // MARK: - Initializer
    
    init(page: Int, totalResults: Int, totalPages: Int, results: [T]) {
        self.page = page
        self.totalResults = totalResults
        self.totalPages = totalPages
        self.results = results
    }
    
    // MARK: - Helper functions / properties
    
    var count: Int { return self.results.count }
    
    var nextPage: Int? {
        let nextPage = self.page + 1
        guard nextPage < self.totalPages else { return nil }
        return nextPage
    }
    
    static func Empty() -> Paginator { return Paginator(page: 0, totalResults: 0, totalPages: 0, results: []) }
}

extension Paginator {
    
    // MARK: - Subscript
    
    subscript(index: Int) -> T {
        return self.results[index]
    }
}

