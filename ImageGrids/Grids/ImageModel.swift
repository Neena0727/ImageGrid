
import Foundation

struct Thumbnail: Codable {
    let key: String
    let domain: String
    let basePath: String
    
    var imageUrl: URL? {
        let urlString = "\(domain)/\(basePath)/0/\(key)"
        return URL(string: urlString)
    }
}

struct ImageItem: Codable {
    let thumbnail: Thumbnail
}

typealias ImageResponse = [ImageItem]
