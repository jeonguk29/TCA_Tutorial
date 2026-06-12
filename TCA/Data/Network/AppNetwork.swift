//
//  AppNetwork.swift
//  TCA
//
//  Created by 정정욱 on 6/12/26.
//

import Alamofire

/// 앱 검색/상세 API 호출 인터페이스. (테스트 대체·의존성 주입을 위해 프로토콜로 분리)
protocol AppNetworkProtocol {
    func fetchAppList(term: String, limit: Int) async -> Result<[AppListItem], NetworkError>
    func fetchAppDetail(id: Int) async -> Result<[AppDetailItem], NetworkError>
}

/// iTunes Search API용 엔드포인트 구현체. URL을 조립해 NetworkManager에 위임한다.
struct AppNetwork: AppNetworkProtocol {

    private let manager = NetworkManager()
    private let baseURL = "https://itunes.apple.com/"

    // 검색어(term)로 앱 목록 조회 (한국 스토어, software 한정)
    func fetchAppList(term: String, limit: Int) async -> Result<[AppListItem], NetworkError> {
        let url = baseURL + "search?term=\(term)&country=kr&entity=software&limit=\(limit)"
        return await manager.fetchData(url: url, method: .get)
    }

    // 앱 ID로 단일 앱 상세 조회
    func fetchAppDetail(id: Int) async -> Result<[AppDetailItem], NetworkError> {
        let url = baseURL + "lookup?id=\(id)&country=kr"
        return await manager.fetchData(url: url, method: .get)
    }
}
