//
//  HTTPClientSpy.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 28.08.2023.
//

import Foundation
import WeatherApp

class HTTPClientSpy: HTTPClient {
    struct Stub {
        let data: Data?
        let response: HTTPURLResponse?
        let error: Error?
    }
    
    var loadCalledCount = 0
    var stubs: [URLRequest: Stub] = [:]
    
    func load(urlReqeust: URLRequest) async throws -> (Data, HTTPURLResponse) {
        loadCalledCount += 1
        
        let stub = stubs[urlReqeust]
        
        if let error = stub?.error {
            throw error
        }
        
        if let data = stub?.data, let response = stub?.response {
            return (data, response)
        }
        
        return (Data(), HTTPURLResponse())
    }
}
