//
//  FindServiceTests.swift
//  SwiftModulTests
//
//  Created by wangsicheng on 2019/9/2.
//  Copyright © 2019 fenrir-cd. All rights reserved.
//

import XCTest
import RxSwift
import Moya
import RxBlocking
import RxTest

@testable import SwiftModul

class FindServiceTests: XCTestCase {

    var disposeBag = DisposeBag()
    override func setUp() {

    }

    override func tearDown() {

    }

    func testToError_notFound() {

        let endpointClosure = { (target: NetworkTarget) -> Endpoint in
            let url = URL(target: target).absoluteString
            return Endpoint(url: url, sampleResponseClosure: {.networkError(NSError(domain: "not fount", code: 404, userInfo: nil))}, method: target.method, task: target.task, httpHeaderFields: target.headers)
        }
        let provider = MoyaProvider<NetworkTarget>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub)
        let netwoking = Network(provider: provider)
        var netError: NetworkError?

        ServiceManager(networking: netwoking)
            .findService
            .getAllProducts(page: 0)
            .subscribe(onSuccess: { (_) in

            }, onError: { (error) in
                netError = NetworkError(error: error)
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(netError, NetworkError.notFound)
    }

    func testToError_serverError() {

        let endpointClosure = { (target: NetworkTarget) -> Endpoint in
            let url = URL(target: target).absoluteString
            return Endpoint(url: url, sampleResponseClosure: {.networkError(NSError(domain: "server error", code: 500, userInfo: nil))}, method: target.method, task: target.task, httpHeaderFields: target.headers)
        }
        let provider = MoyaProvider<NetworkTarget>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub)
        let netwoking = Network(provider: provider)
        var netError: NetworkError?

        do {
            _ = try ServiceManager(networking: netwoking)
                .findService
                .getAllProducts(page: 0)
                .toBlocking()
                .first()
        } catch { netError = NetworkError(error: error) }

        XCTAssertEqual(netError, NetworkError.serverError)
    }

    func testToError_authenticationFailed() {

        let endpointClosure = { (target: NetworkTarget) -> Endpoint in
            let url = URL(target: target).absoluteString
            return Endpoint(url: url, sampleResponseClosure: {.networkError(NSError(domain: "authentication failed", code: 401, userInfo: nil))}, method: target.method, task: target.task, httpHeaderFields: target.headers)
        }
        let provider = MoyaProvider<NetworkTarget>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub)
        let netwoking = Network(provider: provider)
        var netError: NetworkError?

        do {
            _ = try ServiceManager(networking: netwoking)
                .findService
                .getAllProducts(page: 0)
                .toBlocking()
                .first()
        } catch { netError = NetworkError(error: error) }

        XCTAssertEqual(netError, NetworkError.authenticationFailed)
    }

    func testToError_incorrectDataReturned() {

        let endpointClosure = { (target: NetworkTarget) -> Endpoint in
            let url = URL(target: target).absoluteString
            return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, "{".data(using: .utf8)!)}, method: target.method, task: target.task, httpHeaderFields: target.headers)
        }
        let provider = MoyaProvider<NetworkTarget>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub)
        let netwoking = Network(provider: provider)
        var netError: NetworkError?
        do {
            _ = try ServiceManager(networking: netwoking)
                .findService
                .getAllProducts(page: 0)
                .toBlocking()
                .first()
        } catch {
            netError = NetworkError(error: error)
        }

        XCTAssertEqual(netError!, NetworkError.incorrectDataReturned)
    }

    func testData_allProductInfos() {

        let endpointClosure = { (target: NetworkTarget) -> Endpoint in
            let url = URL(target: target).absoluteString
            return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task, httpHeaderFields: target.headers)
        }
        let provider = MoyaProvider<NetworkTarget>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub)
        let netwoking = Network(provider: provider)
        var response: [ProductInfoModel]?
        var model: [ProductInfoModel]?

        let netData = CommonTools.shareInstance.loadDataFromBundle(ofName: "AllProductInfo", ext: "json")
        do {
            response = try ServiceManager(networking: netwoking)
                .findService
                .getAllProducts(page: 0)
                .toBlocking()
                .first()

            let jsonObject = try JSONSerialization.jsonObject(with: netData!, options: .allowFragments)
            let data = try JSONSerialization.data(withJSONObject: jsonObject)
            let decode = JSONDecoder()
            let responseModel = try decode.decode(ResponseModel<[ProductInfoModel]>.self, from: data)
            model = responseModel.data
        } catch {}

        XCTAssertEqual(response, model)
    }
}
