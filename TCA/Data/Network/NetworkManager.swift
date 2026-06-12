//
//  Networkmanager.swift
//  TCA
//
//  Created by 정정욱 on 6/12/26.
//

import Alamofire
import Foundation

/// Alamofire 기반 네트워크 요청을 담당하는 공용 매니저.
/// 제네릭으로 응답 모델을 받아 디코딩까지 처리하고, 결과를 Result로 반환한다.
final class NetworkManager {

    // 모든 요청에서 공유하는 세션. 캐시가 있으면 캐시를, 없으면 네트워크에서 받아오도록 설정.
    private let session: Session = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        return Session(configuration: config)
    }()

    /// 지정한 URL로 요청을 보내고 응답을 `[T]`로 디코딩해 반환한다.
    /// - Parameters:
    ///   - url: 요청 주소(문자열). 변환 실패 시 `.urlError`
    ///   - method: HTTP 메서드(GET/POST 등)
    ///   - parameter: 쿼리/바디 파라미터(옵션)
    ///   - encoding: 파라미터 인코딩 방식(기본 URLEncoding)
    /// - Returns: 성공 시 디코딩된 모델 배열, 실패 시 단계별 `NetworkError`
    func fetchData<T: Decodable>(url: String, method: HTTPMethod, parameter: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default) async -> Result<[T], NetworkError> {

        // 1. 문자열 → URL 변환 (실패하면 요청 자체가 불가)
        guard let url = URL(string: url) else { return .failure(.urlError)}

        // 2. 요청 전송 후 응답 대기
        let result = await session.request(url, method: method, parameters: parameter, encoding: encoding)

        // 3. 전송 중 에러(네트워크 끊김 등)가 있으면 실패 처리
        if let error = result.error {
            return .failure(NetworkError.requestFail)
        }

        // 4. 응답 본문/메타데이터 유효성 확인
        guard let data = result.data else { return .failure(.detaNil) }
        guard let response = result.response else { return .failure(.invalid)}

        // 5. 상태 코드가 정상 범위(2xx~3xx)면 디코딩, 아니면 서버 에러
        if 200..<400 ~= response.statusCode {
            do{
                // 공통 응답 래퍼(NetworkResponse)로 감싼 뒤 실제 데이터(results)만 꺼내 반환
                let networkResponse = try JSONDecoder().decode(NetworkResponse<T>.self, from: data)

                return .success(networkResponse.results)
            } catch {
                return .failure(.failToDecode)
            }
        } else {
            return .failure(.serverError(response.statusCode))
        }
    }
}

/// 서버 응답을 감싸는 공통 래퍼. 실제 데이터는 `results`에 배열로 담겨 온다.
struct NetworkResponse<T: Decodable>: Decodable {
    let resultCount: Int   // 결과 개수
    let results: [T]       // 실제 응답 데이터 목록
}

/// 네트워크 처리 단계별로 구분한 에러 타입.
enum NetworkError: Error {
    case urlError          // URL 변환 실패
    case requestFail       // 요청 전송 실패
    case detaNil           // 응답 본문(data)이 없음
    case invalid           // 응답 메타데이터(response)가 없음
    case serverError(Int)  // 비정상 상태 코드(연관값: statusCode)
    case failToDecode      // 디코딩 실패
}
