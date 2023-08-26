//
//  EndpointTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 26.08.2023.
//

import XCTest
import WeatherApp

class EndpointTests: XCTestCase {
    func test_endpoint_throwsErrorOnInvalidBaseURL() {
        let endpoint = Endpoint(baseURL: "")
        XCTAssertThrowsError(try endpoint.makeUrlRequest())
    }
    
    func test_endpoint_generatesCorrectURLRequestOnBaseURLOnly() throws {
        let endpoint = Endpoint(baseURL: "https://someurl.com")
        let request = try endpoint.makeUrlRequest()
        XCTAssertEqual(request.url?.absoluteString, "https://someurl.com")
    }
    
    func test_endpoint_generatesCorrectURLRequestWithPath() throws {
        let endpoint = Endpoint(baseURL: "https://someurl.com", path: "/mock")
        let request = try endpoint.makeUrlRequest()
        XCTAssertEqual(request.url?.absoluteString, "https://someurl.com/mock")
    }
    
    func test_endpoint_generatesCorrectURLRequestWithQueryParams() throws {
        let endpoint = Endpoint(baseURL: "https://someurl.com", path: "/mock", queryParameters: [
            "c": "c",
            "a": "a",
            "b": "b"
        ])
        let request = try endpoint.makeUrlRequest()
        
        // query parameters should be sorted
        XCTAssertEqual(request.url?.absoluteString, "https://someurl.com/mock?a=a&b=b&c=c")
    }
    
    func test_endpoint_percentEncodesQueryParams() throws {
        let endpoint = Endpoint(baseURL: "https://someurl.com", path: "/mock", queryParameters: [
            "c": "c c",
            "a": "a a",
            "b": "b b"
        ])
        let request = try endpoint.makeUrlRequest()
        
        // query parameters should be sorted
        XCTAssertEqual(request.url?.absoluteString, "https://someurl.com/mock?a=a%20a&b=b%20b&c=c%20c")
    }
}
