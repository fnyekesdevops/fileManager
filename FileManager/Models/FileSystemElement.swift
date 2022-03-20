import Foundation

struct FileSystemElement: Equatable {
    let type: FileSystemElementType
    let url: URL
}

enum FileSystemElementType {
    case directory
    case image
}
