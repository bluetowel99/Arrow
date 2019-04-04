
import Foundation

extension FileManager {
    
    static func deleteFile(at filePath: URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        } catch {
            fatalError("Unable to delete file:\n\(error.localizedDescription)")
        }
    }
    
}
