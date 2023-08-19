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
