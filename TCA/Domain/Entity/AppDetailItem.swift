//
//  AppDetailitem.swift
//  TCA
//
//  Created by 퀀타리움 on 6/12/26.
//

import Foundation

/// 앱 상세 화면에 표시할 앱 정보 모델.
/// iTunes Search API 응답을 디코딩해 사용한다.
struct AppDetailItem: Decodable {

    let id: Int                    // 앱 고유 ID (trackId)
    let name : String              // 앱 이름 (trackName)
    let iconUrl: String            // 아이콘 이미지 URL (artworkUrl100)
    let userRatingCount: Int       // 평가 참여 수
    let averageUserRating: Float   // 평균 별점
    let genres: [String]           // 장르 목록
    let screenshotUrls: [String]   // 스크린샷 URL 목록

    // 서버(JSON) 키와 프로퍼티 이름을 매핑하는 표. (이름이 다른 키 연결용)
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case id = "trackId"
        case iconUrl = "artworkUrl100"
        case userRatingCount
        case averageUserRating
        case genres
        case screenshotUrls
    }
}
