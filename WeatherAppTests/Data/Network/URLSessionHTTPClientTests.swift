//
//  URLSessionHTTPClientTests.swift
//  WeatherAppTests
//
//  Created by Alex Motoc on 20.08.2023.
//

import XCTest
import WeatherApp

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

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_load_throwsEncounteredError() async throws {
        let mockError = makeNSError()
        var didThrow = false
        
        URLProtocolStub.stub(data: nil, response: nil, error: mockError)
        
        do {
            _ = try await makeSUT().load(urlReqeust: makeURLRequest())
        } catch {
            XCTAssertEqual((error as NSError).domain, mockError.domain)
            XCTAssertEqual((error as NSError).code, mockError.code)
            didThrow = true
        }
        
        XCTAssertTrue(didThrow)
    }
    
    func test_load_executesTheAppropriateURLRequest() async throws {
        
        let mockRequest = makeURLRequest()
        let sut = makeSUT()
        
        URLProtocolStub.stub(data: Data(), response: HTTPURLResponse(), error: nil)
        
        let exp = expectation(description: "wait for request to complete")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, mockRequest.url)
            exp.fulfill()
        }
        
        _ = try await sut.load(urlReqeust: mockRequest)
        
        await fulfillment(of: [exp], timeout: 1)
    }
    
    func test_load_failsWhenInvalidCaseIsEncountered() async throws {
        var err = try await getResultingError(data: nil, response: makeURLResponse(), error: nil)
        XCTAssertNotNil(err)
        
        err = try await getResultingError(data: makeData(), response: nil, error: makeNSError())
        XCTAssertNotNil(err)
        
        err = try await getResultingError(data: nil, response: makeURLResponse(), error: makeNSError())
        XCTAssertNotNil(err)
        
        err = try await getResultingError(data: nil, response: makeHTTPURLResponse(), error: makeNSError())
        XCTAssertNotNil(err)
        
        err = try await getResultingError(data: makeData(), response: makeURLResponse(), error: makeNSError())
        XCTAssertNotNil(err)
        
        err = try await getResultingError(data: makeData(), response: makeHTTPURLResponse(), error: makeNSError())
        XCTAssertNotNil(err)
        
        err = try await getResultingError(data: makeData(), response: makeURLResponse(), error: makeNSError())
        XCTAssertNotNil(err)
    }
    
    func test_load_deliversEmptyDataWhenStubbedWithNilDataAndHTTPURLResponse() async throws {
        let mockResponse = makeHTTPURLResponse()
        let sut = makeSUT()
        
        URLProtocolStub.stub(data: nil, response: mockResponse, error: nil)
        
        let (data, response) = try await sut.load(urlReqeust: makeURLRequest())
        
        XCTAssertEqual(data, Data())
        XCTAssertEqual(response.url, mockResponse.url)
        XCTAssertEqual(response.statusCode, mockResponse.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        checkIsDeallocated(sut: sut, file: file, line: line)
        return sut
    }
    
    private func makeURLRequest() -> URLRequest {
        try! WeatherAPIURLRequestBuilder().path("/mock").build()
    }
    
    private func makeData() -> Data {
        .init("some data".utf8)
    }
    
    private func makeURLResponse() -> URLResponse {
        .init(url: URL(string: "https://someurl.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeHTTPURLResponse() -> HTTPURLResponse {
        .init(url: URL(string: "https://someurl.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func getResultingError(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        var encounteredError: Error?
        
        do {
            _ = try await makeSUT(file: file, line: line).load(urlReqeust: makeURLRequest())
        } catch {
            encounteredError = error
        }
        
        return encounteredError
    }
    
    /// This class allows us to intercept network requests and bypass the actual exection of the request.
    /// It is the most elegant solution for testing URLSession calls, in favour of subclassing or interfacing with protocols
    ///
    private class URLProtocolStub: URLProtocol {
        var requestedURLs: [URL] = []
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = .init(data: data, response: response, error: error)
        }
        
        static func observeRequests(closure: @escaping (URLRequest) -> Void) {
            requestObserver = closure
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            
            if let observer = Self.requestObserver {
                observer(request)
            }
            
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
