//
//  PhotoManager.swift
//  TCA
//
//  Created by 정욱 on 5/24/26.
//

import Photos
import UIKit

struct PhotoManager {
    
    // MARK: - 카메라 권한 설정 메서드
    static func requestAuthorization() async -> Bool {
        let auth = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
        // 권한 결과 값을 받아올 수 있음
        let authResult = switch auth {
        case .authorized, .limited: true
        default: false
        }
        
        return authResult
    }
    
    static func getAssets() -> [PHAsset] {
        let option = PHFetchOptions()
        
        // 가장 최근에 찍은 사진이 상단에 올라오도록 구현
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assetResult = PHAsset.fetchAssets(with: .image, options: option)
        let assets = assetResult.objects(at: .init(0..<assetResult.count))
        
        return assets
    }
    
     
    static func fetchImage(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        
        // PHAsset을 Image타입으로 변환해주는게 PHCachingImageManager임
        let manager = PHCachingImageManager()
        manager.requestImage(for: asset, targetSize: .init(width: 60, height: 60), contentMode: .aspectFill, options: nil) { image, _ in
            completion(image)
        }
    }
}
