//
//  AppRespository.swift
//  TCA
//
//  Created by 정정욱 on 6/12/26.
//

import Foundation

/// 도메인 계층과 네트워크 사이의 중간 계층.
/// 네트워크를 프로토콜로 주입받아, 데이터 출처가 바뀌어도 상위 코드가 영향받지 않게 한다.
struct AppRespository {

    private let network: AppNetworkProtocol

    init(network: AppNetworkProtocol) {
        self.network = network
    }

    // 현재는 네트워크 호출을 그대로 전달. (추후 캐싱·가공 로직을 넣을 자리)
    func fetchAppList(term: String, limit: Int) async -> Result<[AppListItem], NetworkError> {
        return await network.fetchAppList(term: term, limit: limit)
    }

    func fetchAppDetail(id: Int) async -> Result<[AppDetailItem], NetworkError> {
        return await network.fetchAppDetail(id: id)
    }
}
