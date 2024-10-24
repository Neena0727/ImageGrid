import UIKit
import Combine

class ImageLoader: ObservableObject {
    @Published var images: [UIImage?] = []
    
    private var memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private var cacheDirectory: URL
    private var currentTasks: [Int: URLSessionDataTask] = [:]

    init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        fetchImages()
    }

    func fetchImages() {
        guard let url = URL(string: "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=100") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching images: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode([ImageItem].self, from: data)
                DispatchQueue.main.async {
                    self.loadImageThumbnails(imageItems: decodedResponse)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    private func loadImageThumbnails(imageItems: [ImageItem]) {
        images = Array(repeating: nil, count: imageItems.count)

        for (index, item) in imageItems.enumerated() {
            let thumbnail = item.thumbnail
            
            if let cachedImage = memoryCache.object(forKey: NSString(string: thumbnail.key)) {
                images[index] = cachedImage
            } else if let url = thumbnail.imageUrl {
                loadImage(from: url, index: index)
            }
        }
    }

    private func loadImage(from url: URL, index: Int) {
        // Cancel previous task if it exists
        currentTasks[index]?.cancel()
        
        // Create a new task
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                return
            }

            // Cache image
            DispatchQueue.global(qos: .userInitiated).async {
                self.memoryCache.setObject(image, forKey: NSString(string: url.absoluteString))
                self.saveToDisk(image: image, key: url.absoluteString)
                
                DispatchQueue.main.async {
                    self.images[index] = image
                }
            }
        }
        
        currentTasks[index] = task
        task.resume()
    }
    
    private func saveToDisk(image: UIImage, key: String) {
        let filePath = cacheDirectory.appendingPathComponent(key)
        if let data = image.jpegData(compressionQuality: 0.7) {
            try? data.write(to: filePath)
        }
    }
    
    func loadImageFromDisk(key: String) -> UIImage? {
        let filePath = cacheDirectory.appendingPathComponent(key)
        return UIImage(contentsOfFile: filePath.path)
    }
}
