//
//  HTTPClient.swift
//  WeatherApp
//
//  Created by Alex Motoc on 19.08.2023.
//

import Foundation

public protocol HTTPClient {
    func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse)
}

// MARK: - Implementation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    private enum Error: Swift.Error {
        case invalidResponse
    }
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: urlReqeust)
        guard let response = response as? HTTPURLResponse else {
            throw Error.invalidResponse
        }
        return (data, response)
    }
}
