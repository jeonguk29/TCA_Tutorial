//
//  AppListItem.swift
//  TCA
//
//  Created by 정정욱 on 6/12/26.
//

import Foundation

/// 검색 결과 목록에 표시할 앱 정보 모델.
/// iTunes Search API 응답을 디코딩해 사용한다.
struct AppListItem: Decodable, Identifiable {
    let id: Int                    // 앱 고유 ID (trackId)
    let name : String              // 앱 이름 (trackName)
    let iconUrl: String            // 아이콘 이미지 URL (artworkUrl100)
    let userRatingCount: Int       // 평가 참여 수
    let averageUserRating: Float   // 평균 별점
    let genres: [String]           // 장르 목록
    let screenshotUrls: [String]   // 스크린샷 URL 목록

    // 서버(JSON) 키와 프로퍼티 이름을 매핑하는 표.
    // 이름이 다른 키(trackName 등)를 연결하기 위해 직접 선언했고,
    // CodingKeys를 직접 쓰면 이름이 같은 키도 모두 나열해야 디코딩 대상에 포함된다.
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
