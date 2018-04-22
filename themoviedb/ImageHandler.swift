//
//  ImageHandler.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import SwiftyJSON


public enum ImgSize {
    
    
    case small
    case medium
    case big
    case original
    
    static var posterRatio: CGFloat = (2.0 / 3.0)
    static var backdropRatio: CGFloat = (300.0 / 169.0)
}


public enum ImgPath {
    
    case backdrop(path: String)
    case logo(path: String)
    case poster(path: String)
    case profile(path: String)
    case still(path: String)
    
    
    var path: String {
        switch self {
        case .backdrop(let path): return path
        case .logo(let path): return path
        case .poster(let path): return path
        case .profile(let path): return path
        case .still(let path): return path
        }
    }
}

public final class ImageHandler: NSObject {
    
    // MARK: - Properties
    
    fileprivate let apiData: ApiJson
    
    // MARK: - Initializer
    
    public init(apiData: ApiJson) {
        self.apiData = apiData
    }
    
    // MARK: - Helper functions
    
    private func pathComponent(forSize size: ImgSize, andPath imagePath: ImgPath) -> String {
        let array: [String] = {
            switch imagePath {
            case .backdrop: return self.apiData.backdropSizes
            case .logo: return self.apiData.logoSizes
            case .poster: return self.apiData.posterSizes
            case .profile: return self.apiData.profileSizes
            case .still: return self.apiData.stillSizes
            }
        }()
        let sizeComponentIndex: Int = {
            switch size {
            case .small: return 0
            case .medium: return array.count / 2
            case .big: return array.count - 2
            case .original: return array.count - 1
            }
        }()
        let sizeComponent: String = array[sizeComponentIndex]
        return "\(sizeComponent)/\(imagePath.path)"
    }
    
    func url(fromDBPath imagePath: ImgPath, withSize size: ImgSize) -> URL? {
        let pathComponent = self.pathComponent(forSize: size, andPath: imagePath)
        let url = URL(string: self.apiData.imagesSecureBaseURLString)?.appendingPathComponent(pathComponent)
        return url
    }
}


