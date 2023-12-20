//
//  Network.swift
//  SeSACConcurrency
//
//  Created by 서승우 on 2023/12/19.
//

import UIKit

enum NetworkError: Error {
    case invalidResponse
    case unknown
    case invalidImage
}

/*
 GCD vs Swift Concurrency
 - completion handler
 - 비동기를 동기처럼

 - Thread Explosion
 - Context Switching
 -> 코어의 수와 쓰레드의 수를 같게
 -> 같은 쓰레드 내에서 Continuation 전환 형식으로 방식을 변경

 - async throws / try await : 비동기를 동기처럼
 - Task : 비동기 함수와 동기 함수를 연결
 - async let : (ex. dispatchGroup)
 - taskGroup:
 */

class Network {
    static let shared = Network()

    private init() {}

    func fetchThumbnail(completion: @escaping (UIImage) -> Void) {
        let url = "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/tpUhFQWn5gV7GnagWOOMHToJOsX.jpg"

        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: URL(string: url)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }
    }

    func fetchThumbnailURLSession(completion: @escaping (UIImage?, NetworkError?) -> Void) {
        let url = URL(string: "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/tpUhFQWn5gV7GnagWOOMHToJOsX.jpg")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(nil, .unknown)
                return
            }

            guard let data else {
                completion(nil, .unknown)
                return
            }

            guard let response = response as? HTTPURLResponse,
            response.statusCode == 200 else {
                completion(nil, .invalidResponse)
                return
            }

            guard let image = UIImage(data: data) else {
                completion(nil, .invalidImage)
                return
            }

            DispatchQueue.main.async {
                completion(image, nil)
            }
        }
        .resume()
    }

    func fetchThumbnailURLSession(completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        let url = URL(string: "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/tpUhFQWn5gV7GnagWOOMHToJOsX.jpg")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.unknown))
                return
            }

            guard let data else {
                completion(.failure(.unknown))
                return
            }

            guard let response = response as? HTTPURLResponse,
            response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let image = UIImage(data: data) else {
                completion(.failure(.invalidImage))
                return
            }

            DispatchQueue.main.async {
                completion(.success(image))
            }
        }
        .resume()
    }

    // 단일
    func fetchThumbnailAsyncAwait(value: String) async throws -> UIImage {
        print(#function, "1", Thread.isMainThread)

        let url = URL(string: "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/\(value).jpg")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)

        print(#function, "2", Thread.isMainThread)

        let (data, response) = try await URLSession.shared.data(for: request)

        print(#function, "3", Thread.isMainThread)

        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else {
            throw NetworkError.invalidResponse
        }

        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidImage
        }

        print(#function, "4", Thread.isMainThread)

        return image
    }

    // 여러개를 순서대로 사용할 때, 하지만 갯수가 명확해야함
    @MainActor
    func fetchThumbnailAsyncLet() async throws -> [UIImage] {
        print(#function, "1", Thread.isMainThread)

        async let result = Network.shared.fetchThumbnailAsyncAwait(value: "eDps1ZhI8IOlbEC7nFg6eTk4jnb")
        async let result1 = Network.shared.fetchThumbnailAsyncAwait(value: "5Afx73NwXPdgHd3Kt1tU7ig4Vox")
        async let result2 = Network.shared.fetchThumbnailAsyncAwait(value: "9f9YsmXoy9ghqZKIVuKHkmGGZCY")

        print(#function, "2", Thread.isMainThread)

        return try await [result, result1, result2]
    }

    // 갯수도 랜덤에 순서까지도 상관없을 때
    func fetchThumbnailTaskGroup() async throws -> [UIImage] {
        let poster = [
            "eDps1ZhI8IOlbEC7nFg6eTk4jnb",
            "5Afx73NwXPdgHd3Kt1tU7ig4Vox",
            "9f9YsmXoy9ghqZKIVuKHkmGGZCY"
        ]

        return try await withThrowingTaskGroup(of: UIImage.self) { (group) in
            for item in poster {
                group.addTask {
                    try await self.fetchThumbnailAsyncAwait(value: item)
                }
            }

            var resultImages: [UIImage] = []

            for try await item in group {
                resultImages.append(item)
            }

            return resultImages
        }
    }

}
