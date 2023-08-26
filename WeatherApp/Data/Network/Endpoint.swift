//
//  Endpoint.swift
//  WeatherApp
//
//  Created by Alex Motoc on 26.08.2023.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
}

public struct Endpoint {
    public let baseURL: String
    public let path: String?
    public let httpMethod: HTTPMethod
    public let queryParameters: [String: String]
    
    public init(
        baseURL: String,
        path: String? = nil,
        httpMethod: HTTPMethod = .get,
        queryParameters: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.path = path
        self.httpMethod = httpMethod
        self.queryParameters = queryParameters
    }
    
    public func makeUrlRequest() throws -> URLRequest {
        guard var url = URL(string: baseURL) else { throw Error.invalidBaseURL }
        if let path { url.append(path: path) }
        let queryItems = queryParameters
            .map { URLQueryItem(name: $0, value: $1) }
            .sorted { $0.name < $1.name }
        url.append(queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        return request
    }
    
    private enum Error: Swift.Error {
        case invalidBaseURL
    }
}
