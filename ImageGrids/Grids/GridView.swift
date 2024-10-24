
import SwiftUI

struct ImageGridView: View {
    @StateObject var imageLoader = ImageLoader()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<imageLoader.images.count, id: \.self) { index in
                    if let image = imageLoader.images[index] {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }.padding()
            .background(Color.black)
        .onAppear {
            imageLoader.fetchImages()
        }
    }
}
