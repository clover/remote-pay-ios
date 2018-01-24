//
//  TestDefaultCloverConnectorV2.swift
//  CloverConnector_Tests
//
//  Copyright © 2017 Clover Networks, Inc. All rights reserved.
//

import XCTest
@testable import CloverConnector

class Test_cloverconnector_DefaultCloverConnectorV2: XCTestCase {
    
    let remoteApplicationID = "TEST"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    
    // MARK: - Setup Connector
    func setupConnector() -> (connector:ICloverConnector, transport:TestCloverTransport)? {
        let configuration = TestDeviceConfiguration(remoteApplicationID: remoteApplicationID)
        guard let connector = CloverConnectorFactory.createICloverConnector(config: configuration) as? DefaultCloverConnectorV2 else { XCTFail("Failed to instantiate connector"); return nil }
        connector.initializeConnection()
        connector.isReady = true
        guard let transport = connector.device?.transport as? TestCloverTransport else { XCTFail("Failed to instantiate Transport"); return nil }
        return (connector,transport)
    }

    // MARK: - >> Sale and Auth Fail Validity Checks <<
    //
    // These tests implement an ICloverConnectorListener to listen for validation failures on the initial sale and auth requests being passed into the ICloverConnector
    //
    //              This Test   <───────────────┐
    //                  │                       │
    //                  │                ICloverConnectorListener
    //                  V                       │
    //      DefaultCloverConnectorV2 ───────────┘
    //
    
    // MARK: Tests
    func testSaleValidityCheckFailure() {
        guard let connection = setupConnector() else { XCTFail("Failed to Initialize Connection"); return }
        
        wait(for: [singleTestFailureValidityCheck(sale:true, saleAmount: 0, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestFailureValidityCheck(sale:true, saleAmount: -1, externalId: "1", onConnection: connection)], timeout: 1)
    }
    func testAuthValidityCheckFailure() {
        guard let connection = setupConnector() else { XCTFail("Failed to Initialize Connection"); return }
        
        wait(for: [singleTestFailureValidityCheck(sale:false, saleAmount: 0, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestFailureValidityCheck(sale:false, saleAmount: -1, externalId: "1", onConnection: connection)], timeout: 1)
    }
    
    // MARK: Support
    func singleTestFailureValidityCheck(sale:Bool, saleAmount:Int, externalId:String, onConnection connection:(connector:ICloverConnector,transport:TestCloverTransport)) -> XCTestExpectation {
        class CCL: ICloverConnectorListener {
            init(expectation:XCTestExpectation, connector:ICloverConnector) {
                self.expectation = expectation
                self.connector = connector
            }
            var expectation:XCTestExpectation?
            var connector:ICloverConnector
            func onSaleResponse(_ response: SaleResponse) {
                XCTAssertEqual(response.result, ResultCode.FAIL)
                expectation?.fulfill()
                connector.removeCloverConnectorListener(self)
            }
            func onAuthResponse(_ authResponse: AuthResponse) {
                XCTAssertEqual(authResponse.result, ResultCode.FAIL)
                expectation?.fulfill()
                connector.removeCloverConnectorListener(self)
                
            }
            func onPreAuthResponse(_ preAuthResponse: PreAuthResponse) { }
            func onCapturePreAuthResponse(_ capturePreAuthResponse: CapturePreAuthResponse) { }
            func onTipAdjustAuthResponse(_ tipAdjustAuthResponse: TipAdjustAuthResponse) { }
            func onVoidPaymentResponse(_ voidPaymentResponse: VoidPaymentResponse) { }
            func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) { }
            func onManualRefundResponse(_ manualRefundResponse: ManualRefundResponse) { }
            func onCloseoutResponse(_ closeoutResponse: CloseoutResponse) { }
            func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) { }
            func onVaultCardResponse(_ vaultCardResponse: VaultCardResponse) { }
            func onDeviceActivityStart(_ deviceEvent: CloverDeviceEvent) { }
            func onDeviceActivityEnd(_ deviceEvent: CloverDeviceEvent) { }
            func onDeviceError(_ deviceErrorEvent: CloverDeviceErrorEvent) { }
            func onDeviceConnected() { }
            func onDeviceReady(_ merchantInfo: MerchantInfo) { }
            func onDeviceDisconnected() { }
            func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) { }
            func onTipAdded(_ message: TipAddedMessage) { }
            func onPrintManualRefundReceipt(_ printManualRefundReceiptMessage: PrintManualRefundReceiptMessage) { }
            func onPrintManualRefundDeclineReceipt(_ printManualRefundDeclineReceiptMessage: PrintManualRefundDeclineReceiptMessage) { }
            func onPrintPaymentReceipt(_ printPaymentReceiptMessage: PrintPaymentReceiptMessage) { }
            func onPrintPaymentDeclineReceipt(_ printPaymentDeclineReceiptMessage: PrintPaymentDeclineReceiptMessage) { }
            func onPrintPaymentMerchantCopyReceipt(_ printPaymentMerchantCopyReceiptMessage: PrintPaymentMerchantCopyReceiptMessage) { }
            func onPrintRefundPaymentReceipt(_ printRefundPaymentReceiptMessage: PrintRefundPaymentReceiptMessage) { }
            func onRetrievePrintersResponse(_ retrievePrintersResponse: RetrievePrintersResponse) { }
            func onPrintJobStatusResponse(_ printJobStatusResponse: PrintJobStatusResponse) { }
            func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse: RetrievePendingPaymentsResponse) { }
            func onReadCardDataResponse(_ readCardDataResponse: ReadCardDataResponse) { }
            func onCustomActivityResponse(_ customActivityResponse: CustomActivityResponse) { }
            func onResetDeviceResponse(_ response: ResetDeviceResponse) { }
            func onMessageFromActivity(_ response: MessageFromActivity) { }
            func onRetrievePaymentResponse(_ response: RetrievePaymentResponse) { }
            func onRetrieveDeviceStatusResponse(_ response: RetrieveDeviceStatusResponse) { }
        }
        let expectation = self.expectation(description: "Fail Validation")
        connection.connector.addCloverConnectorListener(CCL(expectation:expectation, connector:connection.connector))
        if sale {
            connection.connector.sale(SaleRequest(amount: saleAmount, externalId: externalId))
        } else {
            connection.connector.auth(AuthRequest(amount: saleAmount, externalId: externalId))
        }
        return expectation
    }
    
    
    
    // MARK: - >> Sale and Auth Valid Messages <<
    // These tests utilize TestCloverTransport to short circuit the actual transport and provide the message intended for transmission back to this test for analysis
    //
    //              This Test   <───────────────┐
    //                  │                       │
    //                  V                       │
    //      DefaultCloverConnectorV2            │
    //                  │                onMessageCallback
    //                  V                       │
    //         DefaultCloverDevice              │
    //                  │                       │
    //                  V                       │
    //         TestCloverTransport  ────────────┘
    //
    
    
    // MARK: Tests
    func testSingleValidSale() {
        guard let connection = setupConnector() else { XCTFail("Failed to Initialize Connection"); return }
        
        wait(for: [singleTestSaleAmount(500, externalId: "1", onConnection: connection)], timeout: 1)
    }
    func testMultipleValidSale() {
        guard let connection = setupConnector() else { XCTFail("Failed to Initialize Connection"); return }
        
        wait(for: [singleTestSaleAmount(500, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestSaleAmount(500, externalId: "abcdefghijklmnopqrstuvwxyz", onConnection: connection)], timeout: 1)
        wait(for: [singleTestSaleAmount(500, externalId: "100000", onConnection: connection)], timeout: 1)
        wait(for: [singleTestSaleAmount(500, externalId: "🍔", onConnection: connection)], timeout: 1)
        wait(for: [singleTestSaleAmount(1, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestSaleAmount(500, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestSaleAmount(50000, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestSaleAmount(5000000000000, externalId: "1", onConnection: connection)], timeout: 1)
    }
    func testSingleValidAuth() {
        guard let connection = setupConnector() else { XCTFail("Failed to Initialize Connection"); return }
        
        wait(for: [singleTestAuthAmount(500, externalId: "1", onConnection: connection)], timeout: 1)
    }
    func testMultipleValidAuth() {
        guard let connection = setupConnector() else { XCTFail("Failed to Initialize Connection"); return }
        
        wait(for: [singleTestAuthAmount(500, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestAuthAmount(500, externalId: "abcdefghijklmnopqrstuvwxyz", onConnection: connection)], timeout: 1)
        wait(for: [singleTestAuthAmount(500, externalId: "100000", onConnection: connection)], timeout: 1)
        wait(for: [singleTestAuthAmount(500, externalId: "🍔", onConnection: connection)], timeout: 1)
        wait(for: [singleTestAuthAmount(1, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestAuthAmount(500, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestAuthAmount(50000, externalId: "1", onConnection: connection)], timeout: 1)
        wait(for: [singleTestAuthAmount(5000000000000, externalId: "1", onConnection: connection)], timeout: 1)
    }

    // MARK: Support
    func singleTestSaleAmount(_ saleAmount:Int, externalId:String, onConnection connection:(connector:ICloverConnector,transport:TestCloverTransport)) -> XCTestExpectation {
        let expectation = self.expectation(description: "Sale Return")
        connection.transport.onMessageCallback = setupTransportOnMessageCallbackSale(sale: true, saleAmount: 500, externalId: "1", expectation: expectation)
        connection.connector.sale(SaleRequest(amount: 500, externalId: "1"))
        return expectation
    }
    func singleTestAuthAmount(_ saleAmount:Int, externalId:String, onConnection connection:(connector:ICloverConnector,transport:TestCloverTransport)) -> XCTestExpectation {
        let expectation = self.expectation(description: "Auth Return")
        connection.transport.onMessageCallback = setupTransportOnMessageCallbackSale(sale: false, saleAmount: 500, externalId: "1", expectation: expectation)
        connection.connector.auth(AuthRequest(amount: 500, externalId: "1"))
        return expectation
    }
    func setupTransportOnMessageCallbackSale(sale:Bool,saleAmount:Int, externalId:String, expectation:XCTestExpectation) -> ((_ message: [String:Any])->()) {
        return { (message:[String:Any]) in
            guard let defaultData = self.checkMessageDefaults(message) else { return }
            if defaultData.type == "COMMAND" && defaultData.method == "TX_START" {
                guard let payload = message["payload"] as? [String:Any] else { XCTFail("Failed to Parse Payload"); return }
                guard let requestInfo = payload["requestInfo"] as? String else { return } // don't need to fail for this one
                if requestInfo == (sale ? "SALE" : "AUTH") {
                    guard let payIntent = payload["payIntent"] as? [String:Any] else { XCTFail("Failed to Parse Pay Intent"); return }
                    guard let transactionType = payIntent["transactionType"] as? String else { XCTFail("Failed to Parse Transaction Type"); return }
                    XCTAssertEqual(transactionType, "PAYMENT")
                    guard let amount = payIntent["amount"] as? Int else { XCTFail("Failed to Parse Amount"); return }
                    XCTAssertEqual(amount, saleAmount)
                    guard let externalPaymentId = payIntent["externalPaymentId"] as? String else { XCTFail("Failed to Parse External Id"); return }
                    XCTAssertEqual(externalPaymentId, externalId)
                    expectation.fulfill()
                }
            }
        }
    }
    func checkMessageDefaults(_ message:[String:Any]) -> (id:String, type:String, method:String)? {
        guard let method = message["method"] as? String else { XCTFail("Failed to Parse Message Method"); return nil }
        guard let id = message["id"] as? String else { XCTFail("Failed to Parse ID"); return nil }
        guard let type = message["type"] as? String else { XCTFail("Failed to Parse Message Type"); return nil }
        
        guard let packageName = message["packageName"] as? String else { XCTFail("Failed to Parse Package Name"); return nil }
        XCTAssertEqual(packageName, "com.clover.remote_protocol_broadcast.app")
        
        guard let remoteSourceSDK = message["remoteSourceSDK"] as? String else { XCTFail("Failed to Parse remoteSourceSDK"); return nil }
        XCTAssertEqual(remoteSourceSDK, "com.cloverconnector.ios.test")
        
        guard let remoteApplicationID = message["remoteApplicationID"] as? String else { XCTFail("Failed to Parse remoteApplicationID"); return nil }
        XCTAssertEqual(remoteApplicationID, self.remoteApplicationID)
        
        return(id,type,method)
    }
    
}
