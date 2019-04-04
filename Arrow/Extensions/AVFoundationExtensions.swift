
import AVFoundation

//extension AVAsset {
//
//    enum AVFileType {
//        case quickTimeMovie
//        case mpeg4
//
//        var stringValue: String {
//            switch self {
//            case .mpeg4:
//                return AVFileType.mpeg4.fileExtension
//            case .quickTimeMovie:
//                return AVFileType.quickTimeMovie.fileExtension
//            }
//        }
//
//        var fileExtension: String {
//            switch self {
//            case .mpeg4:
//                return "mp4"
//            case .quickTimeMovie:
//                return "mov"
//            }
//        }
//
//    }
//
//}

extension AVAsset {
    
    func encodeVideo(to fileType: AVFileType, completion: @escaping ((URL) -> Void), failure: ((Error?) -> Void)?, cancelled: (() -> Void)?) -> AVAssetExportSession? {
        
        // Create Export session
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetPassthrough) else {
            return nil
        }
        
        // Creating temp path to save the converted video
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let filePath = documentsDirectory.appendingPathComponent("rendered-Video.\(fileType.rawValue)")
        FileManager.deleteFile(at: filePath)
        
        exportSession.outputURL = filePath
        exportSession.outputFileType = fileType
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, 0)
        let range = CMTimeRangeMake(start, self.duration)
        exportSession.timeRange = range
        
        exportSession.exportAsynchronously {() -> Void in
            switch exportSession.status {
            case .failed:
                failure?(exportSession.error)
            case .cancelled:
                cancelled?()
            case .completed:
                if let outputURL = exportSession.outputURL {
                    completion(outputURL)
                }
                
            default:
                break
            }
            
        }
        
        return exportSession
    }
    
}
