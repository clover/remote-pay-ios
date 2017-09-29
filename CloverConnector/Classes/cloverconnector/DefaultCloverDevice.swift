//
//  DefaultCloverDevice.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class DefaultCloverDevice : CloverDevice, CloverTransportObserver {
    
    private var refRespMsg:RefundResponseMessage?
    private var remoteMessageVersion = 1
    public let maxMessageSizeInChars:Int
    
    let parser:Mapper<RemoteMessage> = Mapper<RemoteMessage>()
    private var id:Int {
        get{
            _messageID += 1
            return _messageID
        }
    }
    private var _messageID:Int = 0
    
    private var config:CloverDeviceConfiguration
    
    deinit {
        debugPrint("deinit DefaultCloverDevice")
    }
    
    init?(config:CloverDeviceConfiguration) {
        self.config = config
        if config.getMaxMessageCharacters() < 1000 {
            print("Message size is too small, reverting to 1000", stderr);
        }
        maxMessageSizeInChars = max(1000, config.getMaxMessageCharacters()) // prevent an accidentally small message size
        if let transport = config.getTransport() {
            super.init(packageName: config.getMessagePackageName(), transport: transport)
            transport.subscribe(self)
            transport.initialize()
        } else {
            return nil      
        }
        
    }
    
    func onDeviceConnected(_ transport:CloverTransport) {
        notifyListenersConnected()
    }
    
    func onDeviceReady(_ transport:CloverTransport) {
        let msg:DiscoveryRequestMessage = DiscoveryRequestMessage()
//        msg.customActivities[FlowTouchPoint.TIP_SCREEN.rawValue] = TouchPointCustomActivity(action: "com.clover.cfp.examples.CustomTip", payload: "")
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: true) {
            sendCommandMessage(payload: msgJSON, method: msg.method)
        } else {
            // couldn't create JSON
            debugPrint("Couldn't create DiscoveryRequest message ", stderr)
        }
    }
    
    func onDeviceDisconnected(_ transport:CloverTransport) {
        notifyListenersDisconnected()
    }
    
    func onDeviceError(_ errorType:CloverDeviceErrorType, int:Int?, cause:NSError?, message:String) {
        notifyListenersDeviceError(errorType, int:int, cause:cause, message:message)
    }
    
    override func dispose() {
        self.transport.dispose()
        super.dispose()
    }
    
    func sendPong(_ messge:RemoteMessage) {
        
        var remoteMessage = RemoteMessage()
        remoteMessage.type = .PONG
        debugPrint("Sending Pong")
        if let remoteMsg = Mapper().toJSONString(remoteMessage, prettyPrint: false) {
            sendRemoteMessage(remoteMessage);
        }
    }
    
    func onMessage(_ message:String) {
        // parse message and call correct CloverDeviceObserver
        // debugPrint("Message received: " + message)
        if let remotemessage = parser.map(message) {
            if remotemessage.type == .PING {
                sendPong(remotemessage)
            } else if remotemessage.type == .COMMAND {
                remoteMessageVersion = max(remoteMessageVersion, remotemessage.version) // if version >= 2, then chunking is supported
                if let rmMethod = remotemessage.method {
                    if let payload = remotemessage.payload {
                        switch rmMethod {
                            case .ACK:
                                if let ackMessage = Mapper<AcknowledgementMessage>().map(payload) {
                                    notifyObserverAck(ackMessage);
                                }
                            case Method.LAST_MSG_RESPONSE: break;
                            case Method.DISCOVERY_RESPONSE:
                                if let drm = Mapper<DiscoveryResponseMessage>().map(payload) {
                                    notifyListenersDiscoveryResponse(drm);
                                }
                            case Method.CLOSEOUT_RESPONSE:
                                if let crm = Mapper<CloseoutResponseMessage>().map(payload) {
                                    notifyListenerCloseoutResponse(crm)
                                }
                            case Method.CAPTURE_PREAUTH:
                                if let cparm = Mapper<CapturePreAuthResponseMessage>().map(payload) {
                                    notifyListenersPreAuthCaptured(cparm)
                                }
                            case Method.TIP_ADJUST_RESPONSE:
                                if let tarm = Mapper<TipAdjustResponseMessage>().map(payload) {
                                    notifyListenersTipAdjustResponse(tarm)
                                }
                            case Method.REFUND_RESPONSE:
                                if let refRespMsg = Mapper<RefundResponseMessage>().map(payload) {
                                    self.refRespMsg = refRespMsg
                                    notifyObserversPaymentRefundResponse(refRespMsg);
                                }
                            case Method.TX_START_RESPONSE:
                                if let txsrm = Mapper<TxStartResponseMessage>().map(payload) {
                                    notifyListenersTxStartResponse(txsrm)
                                }
                            case Method.UI_STATE:
                                if let uiMsg = Mapper<UiStateMessage>().map(payload) {
                                    notifyListenersUIEvent(uiMsg);
                                }
                            case Method.TX_STATE:
                                if let txsm = Mapper<TxStateMessage>().map(payload) {
                                    notifyListenersTxState(txsm)
                                }
                            case Method.FINISH_OK:
                                if let finishOk = Mapper<FinishOkMessage>().map(payload) {
                                    notifyListenersFinishOk(finishOk)
                                }
                            case Method.FINISH_CANCEL:
                                if let finishCx = Mapper<FinishCancelMessage>().map(payload) {
                                    notifyListenersFinishCancel(finishCx)
                                }
                            case Method.TIP_ADDED:
                                if let tam = Mapper<TipAddedMessage>().map(payload) {
                                    notifyListenersTipAdded(tam)
                                }
                            case Method.VERIFY_SIGNATURE:
                                if let svr = Mapper<VerifySignatureRequest>().map(payload) {
                                    notifyListenersVerifySignatureRequest(svr)
                                }
                            case Method.PAYMENT_VOIDED:
                                if let pvm = Mapper<PaymentVoidedMessage>().map(payload) {
                                    notifyListenersPaymentVoided(pvm)
                                }
                            case Method.CASHBACK_SELECTED:
                                if let cbsm = Mapper<CashbackSelectedMessage>().map(payload) {
                                    notifyListenersCashbackSelected(cbsm)
                                }
                            case Method.VAULT_CARD_RESPONSE:
                                if let vcr = Mapper<VaultCardResponseMessage>().map(payload) {
                                    notifyListenersVaultCardResponse(vcr)
                                }
                            case Method.CAPTURE_PREAUTH_RESPONSE:
                                if let cpr = Mapper<CapturePreAuthResponseMessage>().map(payload) {
                                    notifyListenersCapturePreAuthResponse(cpr)
                                }
                            case Method.RETRIEVE_PENDING_PAYMENTS_RESPONSE:
                                if let rpprm = Mapper<RetrievePendingPaymentsResponseMessage>().map(payload) {
                                    notifyObserversPendingPaymentsResponse(rpprm);
                                }
                            case Method.CARD_DATA_RESPONSE :
                                if let rcdrm = Mapper<CardDataResponseMessage>().map(payload) {
                                    notifyObserversReadCardData(rcdrm);
                                }
                            case Method.CONFIRM_PAYMENT_MESSAGE :
                                if let cpm = Mapper<ConfirmPaymentMessage>().map(payload) {
                                    notifyObserverConfirmPayment(cpm)
                                }
                            case Method.ACTIVITY_RESPONSE :
                                if let arm = Mapper<ActivityResponseMessage>().map(payload) {
                                    notifyObserverActivityResponse(arm)
                                }
                            // requests
                            case Method.PRINT_TEXT: break;
                            case Method.PRINT_IMAGE: break;
                            case Method.GET_PRINTERS_REQUEST: break;
                            case Method.GET_PRINTERS_RESPONSE:
                                if let rtrm = Mapper<RetrievePrintersResponseMessage>().map(payload) {
                                    notifyRetrievePrinterResponse(rtrm)
                                }
                            case Method.PRINT_JOB_STATUS_REQUEST: break;
                            case Method.PRINT_JOB_STATUS_RESPONSE:
                                if let pjsr = Mapper<PrintJobStatusResponseMessage>().map(payload) {
                                    notifyRetrievePrintJobStatus(pjsr)
                                }
                            case Method.TERMINAL_MESSAGE: break;
                            case Method.BREAK: break;
                            case Method.VOID_PAYMENT: break;
                            case Method.CLOSEOUT_REQUEST: break;
                            case Method.DISCOVERY_REQUEST: break;
                            case Method.KEY_PRESS: break;
                            case Method.LAST_MSG_REQUEST: break;
                            case Method.OPEN_CASH_DRAWER: break;
                            case Method.ORDER_ACTION_ADD_DISCOUNT: break;
                            case Method.ORDER_ACTION_REMOVE_DISCOUNT: break;
                            case Method.ORDER_ACTION_ADD_LINE_ITEM: break;
                            case Method.ORDER_ACTION_REMOVE_LINE_ITEM: break;
                            case Method.ORDER_ACTION_RESPONSE: break;
                            case Method.ACTIVITY_REQUEST: break;
                            case Method.PARTIAL_AUTH: break;
                            case Method.PRINT_PAYMENT:
                                if let printPayment = Mapper<PaymentPrintMessage>().map(payload) {
                                    notifyPrintPaymentReceipt(printPayment)
                                }
                            case Method.PRINT_CREDIT:
                                if let printCredit = Mapper<CreditPrintMessage>().map(payload) {
                                    notifyPrintCreditReceipt(printCredit)
                                }
                            case Method.PRINT_CREDIT_DECLINE:
                                if let printCreditDecline = Mapper<DeclineCreditPrintMessage>().map(payload) {
                                    notifyPrintCreditDeclineReceipt(printCreditDecline)
                                }
                            case Method.PRINT_PAYMENT_DECLINE:
                                if let printPaymentDecline = Mapper<DeclinePaymentPrintMessage>().map(payload) {
                                    notifyPrintPaymentDecline(printPaymentDecline)
                                }
                            case Method.PRINT_PAYMENT_MERCHANT_COPY:
                                if let printMerchantPayment = Mapper<PaymentPrintMerchantCopyMessage>().map(payload) {
                                    notifyPrintPaymentMerchantCopy(printMerchantPayment)
                                }
                            case Method.REFUND_PRINT_PAYMENT:
                                if let printPaymentRefund = Mapper<RefundPaymentPrintMessage>().map(payload) {
                                    notifyPrintRefundPayment(printPaymentRefund)
                                }
                            case Method.REFUND_REQUEST: break;
                            case Method.SHOW_WELCOME_SCREEN: break;
                            case Method.SHOW_ORDER_SCREEN: break;
                            case Method.SHOW_THANK_YOU_SCREEN: break;
                            case Method.SHOW_PAYMENT_RECEIPT_OPTIONS: break;
                            case Method.SIGNATURE_VERIFIED: break;
                            case Method.TIP_ADJUST: break;
                            case Method.TX_START: break;
                            case Method.VAULT_CARD: break;
                            case Method.RETRIEVE_PENDING_PAYMENTS: break; // outbound request
                            case Method.CARD_DATA: break;
                            case Method.PAYMENT_REJECTED: break;
                            case Method.PAYMENT_CONFIRMED: break;
                            case Method.LOG_MESSAGE: break;
                            case Method.ACTIVITY_MESSAGE_TO_ACTIVITY: break;
                            case Method.ACTIVITY_MESSAGE_FROM_ACTIVITY:
                                if let activityMessageFromActivity = Mapper<ActivityMessageFromActivity>().map(payload) {
                                    notifyMessageFromActivity(activityMessageFromActivity)
                                }
                            case Method.RETRIEVE_PAYMENT_REQUEST: break;
                            case Method.RETRIEVE_PAYMENT_RESPONSE:
                                if let rprm = Mapper<RetrievePaymentResponseMessage>().map(payload) {
                                    notifyRetrievePaymentResponse(rprm)
                                }
                            case Method.REMOTE_ERROR: break;
                            case Method.RETRIEVE_DEVICE_STATUS_REQUEST: break;
                            case Method.RETRIEVE_DEVICE_STATUS_RESPONSE:
                                if let rdrrm = Mapper<RetrieveDeviceStatusResponseMessage>().map(payload) {
                                    notifyDeviceStatusResponse(rdrrm)
                                }
                            case Method.RESET_DEVICE_RESPONSE:
                                if let rdrm = Mapper<ResetDeviceResponseMessage>().map(payload) {
                                    notifyDeviceResetResponse(rdrm)
                                }
                        }
                        
                    }
                    
                }
            }
            
        } else {
            // error parsing to RemoteMessage
        }
    }
    
    private func JSONStringify(_ value: AnyObject,prettyPrinted:Bool = false) -> String{
        
       let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        
        if NSJSONSerialization.isValidJSONObject(value) {
            
            do{
                
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            }catch {
                
                debugPrint("error")
                //Access error here
            }
            
        }
        return ""
        
    }
    
    override func doCaptureAuth(_ paymentID: String, amount: Int, tipAmount: Int) {
        let msg = CapturePreAuthRequestMessage()
        msg.amount = amount
        msg.paymentId = paymentID
        msg.tipAmount = tipAmount
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
        
    }
    
    override func doShowPaymentReceiptScreen(_ orderId: String, paymentId: String) {
        let msg = ShowPaymentReceiptOptionsMessage()
        msg.orderId = orderId
        msg.paymentId = paymentId
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doTipAdjustAuth(_ orderId: String, paymentId: String, amount: Int) {
        let msg = TipAdjustMessage()
        msg.orderId = orderId
        msg.paymentId = paymentId
        msg.tipAmount = amount
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doCloseout(_ allowOpenTabs: Bool, batchId: String?) {
        let msg = CloseoutRequestMessage()
        msg.allowOpenTabs = allowOpenTabs
        msg.batchId = batchId
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doVoidPayment(_ payment: CLVModels.Payments.Payment, reason: String) {
        let msg = VoidPaymentMessage()
        msg.payment = payment
        msg.voidReason = VoidReason(rawValue: reason)
        
        class TempDevObs : DefaultCloverDeviceObserver {
            var ackID:String
            var observers:NSMutableArray
            var payment:CLVModels.Payments.Payment
            var reason:VoidReason
            
            init(_ msgId:String, _ deviceObservers:NSMutableArray, _ payment: CLVModels.Payments.Payment, _ reason: VoidReason) {
                self.ackID = msgId
                self.observers = deviceObservers
                self.payment = payment
                self.reason = reason
            }
            override func onMessageAck(_ sourceMessageId: String) {
                if(sourceMessageId == ackID) {
                    observers.removeObject(self)
                    for observer in observers {
                        (observer as? CloverDeviceObserver)?.onPaymentVoidedResponse(payment, voidReason: reason)
                    }
                }
            }
        }
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            
            if let voidPacketMsgId = sendCommandMessage(payload: msgJSON, method:msg.method) {
                deviceObservers.addObject(TempDevObs(voidPacketMsgId, deviceObservers, payment, VoidReason(rawValue: reason)!))
            }
        }
    }
    
    override func doVaultCard(_ cardEntryMethods: Int) {
        let msg = VaultCardMessage()
        msg.cardEntryMethods = cardEntryMethods
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doPrintText(_ textLines: [String], printRequestId: String?, printDeviceId: String?) {
        let msg = TextPrintMessage()
        msg.textLines = textLines
        msg.printRequestId = printRequestId
        
        if let printerId = printDeviceId {
            let printer = CLVModels.Printer.Printer()
            printer.id = printerId
            msg.printer = printer
        }
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doPrint(request: PrintRequest) {
        if request.text.count > 0 {             //we can print all text lines...
            self.doPrintText(request.text, printRequestId: request.printRequestId, printDeviceId: request.printDeviceId)
        } else if let image = request.images.first {   //...but currently only support one image...
            self.doPrintImage(image, printRequestId: request.printRequestId, printDeviceId: request.printDeviceId)
        } else if let imageURLString = request.imageURLS.first?.absoluteString {   //...and one image URL
            self.doPrintImage(imageURLString, printRequestId: request.printRequestId, printDeviceId: request.printDeviceId)
        } else {
            //if we got here, it's because the printRequest either had nothing on it, or has a new, unhandled content type
            debugPrint("In doPrint: PrintRequest had no content or had an unhandled content type")
        }
    }
    
    override func doRetrievePrinters(_ request:RetrievePrintersRequest) {
        let msg = RetrievePrintersRequestMessage()
        msg.category = request.category
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doRetrievePrintJobStatus(_ request: PrintJobStatusRequest) {
        let msg = PrintJobStatusRequestMessage()
        msg.printRequestId = request.printRequestId
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doOpenCashDrawer(_ reason: String, deviceId: String?) {
        let msg = OpenCashDrawerMessage()
        msg.reason = reason
        
        if let printerId = deviceId {
            let printer = CLVModels.Printer.Printer()
            printer.id = deviceId
            msg.printer = printer
        }
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doShowWelcomeScreen() {
        let msg:ShowWelcomeScreenMessage = ShowWelcomeScreenMessage()
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doShowThankYouScreen() {
        let msg:ShowThankYouScreenMessage = ShowThankYouScreenMessage()
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: true) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doPaymentRefund(_ orderId: String, paymentId: String, amount: Int, fullRefund: Bool) {
        let msg:RefundRequestMessage = RefundRequestMessage(orderId: orderId, paymentId:paymentId, amount:amount, fullRefund:fullRefund)
        msg.orderId = orderId
        msg.paymentId = paymentId
        msg.amount = amount
        msg.fullRefund = fullRefund
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method: msg.method);
        }
        
    }
    
    override func doAcceptPayment(_ payment: CLVModels.Payments.Payment) {
        let msg:PaymentConfirmedMessage = PaymentConfirmedMessage()
        msg.payment = payment

        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method: msg.method);
        }
    }

    override func doRejectPayment(_ payment: CLVModels.Payments.Payment, challenge: Challenge) {
        let msg:PaymentRejectedMessage = PaymentRejectedMessage()
        msg.payment = payment
        msg.reason = challenge.reason

        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method: msg.method);
        }
    }
    
    override func doKeyPress(_ keyPress: KeyPress) {
        let msg = KeyPressMessage(keyPress: keyPress)
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method: msg.method )
        }
        
    }
        
    override func doTerminalMessage(_ text: String) {
        let msg:TerminalMessage = TerminalMessage()
        msg.text = text
        
        if let msgJSON = Mapper().toJSONString(msg) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doTxStart(_ payIntent: PayIntent, order: CLVModels.Order.Order?, suppressTipScreen: Bool, requestInfo:String?) {
        let msg:TxStartRequestMessage = TxStartRequestMessage()
        msg.payIntent = payIntent
        msg.order = order
        msg.suppressOnScreenTips = suppressTipScreen
        msg.requestInfo = requestInfo
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint:false) {
            sendCommandMessage(payload: msgJSON, method:msg.method, version: 1) // since v2 is supported in deployed version, just default to v 2
        }
    }
    
    override func doBreak() {
        let msg:BreakMessage = BreakMessage()
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint:false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
        
    }
    
    override func doSignatureVerified(_ payment: CLVModels.Payments.Payment, verified: Bool) {
        let msg:SignatureVerifiedMessage = SignatureVerifiedMessage(payment: payment, verified: verified)
        
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint:false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doOrderUpdate(_ displayOrder:DisplayOrder, orderOperation operation:DisplayOrderModifiedOperation?) {
        let updateMessage = OrderUpdateMessage(displayOrder: displayOrder, operation: operation)
        
        let msg:OrderUpdateMessage = updateMessage
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint:false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doPrintImage(_ img: ImageClass, printRequestId: String?, printDeviceId: String?) {
        if let imageData = ImagePNGRepresentation(img) {
            let ipm = ImagePrintMessage()
            
            ipm.printRequestId = printRequestId
            
            if let printerId = printDeviceId {
                let printer = CLVModels.Printer.Printer()
                printer.id = printerId
                ipm.printer = printer
            }

            if remoteMessageVersion > 1 {
                // Does Base 64 Fragment processing, the attachment is a byte array that will be chunked, then encoded
                if let msgJSON = Mapper().toJSONString(ipm, prettyPrint:false) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { [weak self] in
                        if self?.sendCommandMessage(payload: msgJSON, method:ipm.method, version: 2, attachmentData: imageData) == nil {
                            debugPrint("Error sending image")
                        }
                    })
                }
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { [weak self] in

                    let base64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                    ipm.png = [UInt8](base64.utf8)
                    if let msgJSON = Mapper().toJSONString(ipm, prettyPrint:false) {
                        if self?.sendCommandMessage(payload: msgJSON, method:ipm.method) == nil {
                            debugPrint("Error sending image")
                        }
                    }
                })
            }
        }
    }
    
    override func doPrintImage(_ url: String, printRequestId: String?, printDeviceId: String?) {
        let printImageMessage = ImagePrintMessage()
        printImageMessage.urlString = url
        printImageMessage.printRequestId = printRequestId
        
        if let printerId = printDeviceId {
            let printer = CLVModels.Printer.Printer()
            printer.id = printerId
            printImageMessage.printer = printer
        }
        
        let msg:ImagePrintMessage = printImageMessage
        if let msgJSON = Mapper().toJSONString(msg, prettyPrint:false) {
            sendCommandMessage(payload: msgJSON, method:msg.method)
        }
    }
    
    override func doReadCardData(_ payIntent: PayIntent) {
        let cdrm:CardDataRequestMessage = CardDataRequestMessage()
        cdrm.payIntent = payIntent
        
        if let msgJSON = Mapper().toJSONString(cdrm, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method: cdrm.method)
        }
    }
    
    override func doRetrievePendingPayments() {
        let rpp:RetrievePendingPaymentsRequestMessage = RetrievePendingPaymentsRequestMessage()
        if let msgJSON = Mapper().toJSONString(rpp, prettyPrint: false) {
            sendCommandMessage(payload: msgJSON, method: rpp.method)
        }
    }
    
    override func doStartActivity(action a: String, payload p: String?, nonBlocking: Bool) {
        let ar:ActivityRequest = ActivityRequest(action: a, payload: p, nonBlocking: nonBlocking, forceLaunch: false)
        
        if let msgJSON = Mapper().toJSONString(ar, prettyPrint:false) {
            sendCommandMessage(payload: msgJSON, method: ar.method)
        }
    }
    
    override func doRetrieveDeviceStatus(sendLast: Bool) {
        let rdsrm = RetrieveDeviceStatusRequestMessage(sendLast)
        if let msgJSON = Mapper().toJSONString(rdsrm) {
            sendCommandMessage(payload: msgJSON, method: rdsrm.method)
        }
    }
    
    override func doRetrievePayment(externalPaymentId: String) {
        let rprm = RetrievePaymentRequestMessage(externalPaymentId)
        if let msgJSON = Mapper().toJSONString(rprm) {
            sendCommandMessage(payload: msgJSON, method: rprm.method)
        }
    }
    
    override func doSendMessageToActivity(action a: String, payload p: String?) {
        let amta = ActivityMessageToActivity(action: a, payload: p)
        if let msgJSON = Mapper().toJSONString(amta) {
            sendCommandMessage(payload: msgJSON, method: amta.method)
        }
    }
    
    func sendCommandMessage(payload msgJSON:String, method:Method, version:Int = 1, attachment:String? = nil, attachmentEncoding:String? = nil, attachmentData:NSData? = nil, attachmentUrl:String? = nil) -> String? {
            let rm:RemoteMessage = RemoteMessage()
            rm.method = method
            rm.type = RemoteMessageType.COMMAND
            rm.payload = msgJSON
            rm.attachment = attachment
            rm.attachmentEncoding = attachmentEncoding
            
        return sendRemoteMessage(rm, version: version, attachmentData: attachmentData, attachmentUrl: attachmentUrl, attachmentEncoding: attachmentEncoding)
    }
    
    func sendRemoteMessage(_ remoteMsg:RemoteMessage, version:Int = 1, attachmentData: NSData? = nil, attachmentUrl: String? = nil, attachmentEncoding: String? = nil) -> String? {
        remoteMsg.packageName = self.packageName
        remoteMsg.remoteApplicationID = config.remoteApplicationID
        remoteMsg.remoteSourceSDK = config.remoteSourceSDK
        remoteMsg.id = String(id)
        remoteMsg.version = version
        
        if remoteMsg.version > 1 { // we CAN send fragments
            // there are 3 paths...
            // 1. The attachment is already a string, so set change the Encoding from "BASE64" to "BASE64.ATTACHMENT" (or we could decode it, and then encode the chunks), or if the Encoding is nil, just write it...e.g. the attachment might be a large text snippet and not encoded
            // 2. The attachmentData is binary, so we encode as "BASE64.FRAGMENT"
            // 3. The attachmentUrl is provided, so we read and encode as "BASE64.FRAGMENT"
            
            
            
            let hasAttachmentURI = attachmentUrl != nil
            let hasAttachmentData = attachmentData != nil
            let payloadTooLarge = ((remoteMsg.attachment?.characters.count ?? 0) + (remoteMsg.payload?.characters.count ?? 0)) > maxMessageSizeInChars
            let shouldFrag = hasAttachmentURI || hasAttachmentData || payloadTooLarge
            if shouldFrag { // we NEED to fragment
                
                // if the payload size exceeds the max, then fail immediately
                // note that this is not exact - data in a String will be a different length than the same data in Data thanks to the JSON conversion and multiple escaping done on messages, but there's enough pad in the max payload to account for this.
                if (remoteMsg.attachment != nil && remoteMsg.attachment!.characters.count > cloverConnector?.MAX_PAYLOAD_SIZE) || // passed in a formatted string, check for length (this isn't actually used anywhere...)
                    (attachmentData != nil && attachmentData!.length > cloverConnector?.MAX_PAYLOAD_SIZE) {                       // passed in a data chunk, check for length
                    debugPrint("Error sending message - payload size is greater than the maximum allowed")
                    return nil
                }

                // let's fragment the payload...
                var fragmentIndex = 0

                var payloadStr = remoteMsg.payload ?? ""
                while payloadStr.characters.count > 0 {
                    // FRAGMENT Payload
                    let range = Range<String.Index>(start: payloadStr.startIndex, end: payloadStr.startIndex.advancedBy(maxMessageSizeInChars < payloadStr.characters.count ? maxMessageSizeInChars : payloadStr.characters.count))
                    
                    let fPayload = payloadStr.substringWithRange(range)
                    //            debugPrint(fragment)
                    
                    payloadStr.removeRange(range)
                    
                    
                    sendMessageFragment(remoteMessage:remoteMsg, payloadFragment: fPayload, attachmentFragment: nil, fragmentIndex: fragmentIndex++, isLastMessage: payloadStr.characters.count == 0 && remoteMsg.attachment?.characters.count ?? 0 == 0 && remoteMsg.attachmentUri?.characters.count ?? 0 == 0 && attachmentData == nil)
                }

                
                // now let's fragment the attachment or attachmentData
                if var attach = remoteMsg.attachment {

                    if remoteMsg.attachmentEncoding == "BASE64" {
                        // TODO: decode, chunk and then encode or
                        // set encoding to BASE64.ATTACHMENT
                        // in this case, change the encoding and chunk as-is
                        remoteMsg.attachmentEncoding = "BASE64.ATTACHMENT" // must reconstruct the entire attachment before decoding
                        var start = 0
                        let count = attach.characters.count
                        while attach.characters.count > 0 {
                            // FRAGMENT Attachment
                            let range = Range<String.Index>(start: attach.startIndex, end: attach.startIndex.advancedBy(maxMessageSizeInChars < attach.characters.count ? maxMessageSizeInChars : attach.characters.count))
                            
                            let aPayload = attach.substringWithRange(range)
                            
                            attach.removeRange(range)
                            
                            
                            sendMessageFragment(remoteMessage:remoteMsg, payloadFragment: nil, attachmentFragment: aPayload, fragmentIndex: fragmentIndex++, isLastMessage: attach.characters.count == 0)
                        }
                        
                    } else {
                        // TODO: chunk as-as
                    }
                } else if let data = attachmentData {
                    var start = 0
                    let count = data.length
                    
                    while start < count {
                        autoreleasepool {
                            let range = NSMakeRange(start, min(maxMessageSizeInChars, count-start)) // loc and len
                            var chunkData:NSData = data.subdataWithRange(range)
                            start = start+maxMessageSizeInChars
                            
                            // FRAGMENT Payload
                            let fAttachment = chunkData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                            sendMessageFragment(remoteMessage:remoteMsg, payloadFragment: nil, attachmentFragment: fAttachment, fragmentIndex: fragmentIndex++, isLastMessage: start > count)
                        }
                    }
                    
                }

                
            } else {
                // we DON'T need to fragment
                if let remoteMsg = Mapper().toJSONString(remoteMsg, prettyPrint: false) {
                    Swift.debugPrint(remoteMsg)
                    self.transport.sendMessage(remoteMsg)
                } else {
                    Swift.debugPrint("Couldn't send message. Couldn't serialize", stderr)
                }
            }
            
        } else {
            // we cannot send fragments, v1 or attachments
            if remoteMsg.attachment != nil || attachmentData != nil || attachmentUrl != nil {
                Swift.debugPrint("Version 1 of remote message doesn't support attachments", stderr)
            }

            if let remoteMsg = Mapper().toJSONString(remoteMsg, prettyPrint: false) {
                Swift.debugPrint(remoteMsg)
                self.transport.sendMessage(remoteMsg)
            } else {
                Swift.debugPrint("Couldn't send message. Couldn't serialize", stderr)
            }
        }
        
        
        return remoteMsg.id!;
    }
        
    private func sendMessageFragment(remoteMessage remoteMsg:RemoteMessage, payloadFragment fPayload:String?, attachmentFragment fAttachment:String?, fragmentIndex index: Int, isLastMessage lastFragment: Bool) {
            
            let fRemoteMessage = RemoteMessage()
            fRemoteMessage.id = remoteMsg.id
            fRemoteMessage.method = remoteMsg.method
            fRemoteMessage.type = remoteMsg.type
            fRemoteMessage.packageName = remoteMsg.packageName
            fRemoteMessage.remoteApplicationID = remoteMsg.remoteApplicationID
            fRemoteMessage.remoteSourceSDK = remoteMsg.remoteSourceSDK
            fRemoteMessage.version = remoteMsg.version
            // changes for the fragment
            fRemoteMessage.payload = fPayload
            fRemoteMessage.attachmentUri = nil
            fRemoteMessage.attachmentEncoding = remoteMsg.attachmentEncoding ?? "BASE64.FRAGMENT"
            fRemoteMessage.attachment = fAttachment
            fRemoteMessage.fragmentIndex = index
            fRemoteMessage.lastFragment = lastFragment
            //                fRemoteMessage.fragmentTotal = payloadFragments + attachmentFragments
            //
            
            if let remoteMsg = Mapper().toJSONString(fRemoteMessage, prettyPrint: false) {
                Swift.debugPrint("Sending Fragment " + String(index) + (lastFragment ? " <last>" : ""))
                self.transport.sendMessage(remoteMsg)
            } else {
                Swift.debugPrint("Couldn't send message. Couldn't serialize", stderr)
            }
        }
    
    func notifyListenerCloseoutResponse(_ response:CloseoutResponseMessage) {
        for listener in deviceObservers {
            if let status = response.status,
                let reason = response.reason,
                let batch = response.batch {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onCloseoutResponse(status, reason: reason, batch: batch)
                })
            } else {
                // send error back
            }
        }
    }
    func notifyListenersDiscoveryResponse(_ response:DiscoveryResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onDeviceReady(self, discoveryResponseMessage: response);
            })
        }
    }
    
    func notifyListenersConnected() {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onDeviceConnected(self)
            })
        }
    }
    
    func notifyListenersDisconnected() {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onDeviceDisconnected(self)
            })
        }
    }
    
    func notifyListenersDeviceError(_ errorType:CloverDeviceErrorType, int:Int?, cause:NSError?, message:String) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onDeviceError(errorType, int: int, cause:cause, message: message)
            })
        }
    }
    
    func notifyListenersTxStartResponse(_ response:TxStartResponseMessage) {
        for listener in deviceObservers {
            if let result = response.result,
                let externalID = response.externalPaymentId {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onTxStartResponse(result, externalId: externalID, requestInfo: response.requestInfo)
                })
            }
        }
        
    }
    
    func notifyListenersTxState(_ response:TxStateMessage) {
        for _ in deviceObservers {
//            (listener as? CloverDeviceObserver)?.onTxState(response.txState)
        }
    }
    
    func notifyListenersUIEvent(_ stateMsg:UiStateMessage) {
        for listener in deviceObservers {
            if let text = stateMsg.uiText,
                let direction = stateMsg.uiDirection,
                let state = stateMsg.uiState {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onUiState(state, uiText:text, uiDirection: direction, inputOptions:stateMsg.inputOptions)
                })
            }
        }
    }
    
    func notifyObserversPaymentRefundResponse(_ response:RefundResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPaymentRefundResponse(response.orderId, paymentId: response.paymentId, refund: response.refund, reason: response.reason, message: response.message, code: response.code!)
            })
        }
    }
    
    func notifyListenersTipAdjustResponse(_ response:TipAdjustResponseMessage) {
        for listener in deviceObservers {
            if let paymentId = response.paymentId,
                let amount = response.amount,
                let success = response.success {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onAuthTipAdjustedResponse(paymentId, amount: amount, success: success)
                })
            }
        }
    }
    
    func notifyListenersPreAuthCaptured(_ preAuthMessage:CapturePreAuthResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onCapturePreAuthResponse(preAuthMessage.status!, reason: preAuthMessage.reason!, paymentId: preAuthMessage.paymentId!, amount: preAuthMessage.amount!, tipAmount: preAuthMessage.tipAmount ?? 0)
            })
        }
    }
    
    func notifyListenersTipAdded(_ response:TipAddedMessage) {
        for listener in deviceObservers {
            if let tipAmount = response.tipAmount {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onTipAddedResponse(tipAmount)
                })
            }
        }
    }
    
    func notifyListenersFinishCancel(_ finishCx:FinishCancelMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onFinishCancel(finishCx.requestInfo)
            })
        }
    }
    
    func notifyListenersFinishOk(_ finishOk:FinishOkMessage) {
        if let credit = finishOk.credit {
            for listener in deviceObservers {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onFinishOk(credit);
                })
            }
        } else if let refund = finishOk.refund {
            for listener in deviceObservers {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onFinishOk(refund, requestInfo: TxStartRequestMessage.REFUND_REQUEST);
                })
            }
        } else if let payment = finishOk.payment {
            for listener in deviceObservers {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onFinishOk(payment, signature: finishOk.signature, requestInfo: finishOk.requestInfo);
                })
            }
        }

    }
    
    func notifyListenersVerifySignatureRequest(_ svr:VerifySignatureRequest) {
        if let payment = svr.payment {
//            doSignatureVerified(payment, verified: true)
            for listener in deviceObservers {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onVerifySignature(payment, signature: svr.signature)
                })
            }
        }
    }
    
    func notifyListenersPaymentVoided(_ response:PaymentVoidedMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPaymentVoidedResponse(response.payment!, voidReason: response.voidReason!)
            })
        }
    }
    
    func notifyListenersCashbackSelected(_ response:CashbackSelectedMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onCashbackSelectedResponse(response.cashbackAmount!)
            })
        }
        
    }
    
    func notifyListenersVaultCardResponse(_ response:VaultCardResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onVaultCardResponse(response.card, code: response.status, reason: response.reason)
            })
        }
    }
    
    func notifyListenersCapturePreAuthResponse(_ response:CapturePreAuthResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onCapturePreAuthResponse(response.status!, reason: response.reason!, paymentId: response.paymentId!, amount: response.amount!, tipAmount: response.tipAmount!)
            })
        }
    }
    
    func notifyObserversPendingPaymentsResponse(_ response:RetrievePendingPaymentsResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPendingPaymentsResponse(response.status == ResultStatus.SUCCESS, payments: response.pendingPaymentEntries)
            })
        }
    }
    
    func notifyObserversReadCardData(_ response:CardDataResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onReadCardResponse(response.status!, reason: response.reason!, cardData: response.cardData)
            })
        }
    }
    
    func notifyObserverConfirmPayment(_ request:ConfirmPaymentMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onConfirmPayment(request.payment, challenges: request.challenges)
            })
        }
    }
    
    func notifyObserverActivityResponse(_ request:ActivityResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let status = request.resultCode == -1 ? ResultCode.SUCCESS : ResultCode.CANCEL
                (listener as? CloverDeviceObserver)?.onActivityResponse(status, action: request.action, payload:request.payload, failReason:  request.failReason)
            })
        }
    }
    
    func notifyRetrievePrinterResponse(_ response:RetrievePrintersResponseMessage) {
        for observer in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (observer as? CloverDeviceObserver)?.onRetrievePrinterResponse(response.printers)
            })
        }
    }
    
    func notifyRetrievePrintJobStatus(_ response:PrintJobStatusResponseMessage) {
        for observer in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (observer as? CloverDeviceObserver)?.onRetrievePrintJobStatus(response.printRequestId, status: response.status)
            })
        }
    }
    
    func notifyPrintPaymentReceipt(_ response:PaymentPrintMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPrintPayment(response.order!, payment: response.payment!)
            })
        }
    }
    
    func notifyPrintCreditReceipt(_ response:CreditPrintMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPrintCredit(response.credit!)
            })
        }
    }
    
    func notifyPrintCreditDeclineReceipt(_ response:DeclineCreditPrintMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPrintCreditDecline(response.reason!, credit: response.credit!)
            })
        }
    }
 
    func notifyPrintPaymentDecline(_ response:DeclinePaymentPrintMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPrintPaymentDecline(response.reason!, payment: response.payment!)
            })
        }
    }
    
    func notifyPrintPaymentMerchantCopy(_ response:PaymentPrintMerchantCopyMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPrintMerchantReceipt(response.payment!)
            })
        }
    }
    
    func notifyPrintRefundPayment(_ response:RefundPaymentPrintMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onPrintRefundPayment(response.refund!, payment:response.payment!, order: response.order!)
            })
        }
    }
    
    func notifyObserverAck(_ ackMessage:AcknowledgementMessage) {
        for listener in deviceObservers {
            if let smi = ackMessage.sourceMessageId {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    (listener as? CloverDeviceObserver)?.onMessageAck(smi)
                })
            }
        }
    }
    
    func notifyDeviceStatusResponse(_ response:RetrieveDeviceStatusResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onDeviceStatusResponse(response.result, reason: response.reason, state: response.state, subState: response.subState, data: response.data)
            })
        }
    }
    
    func notifyDeviceResetResponse(_ response:ResetDeviceResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onResetDeviceResponse(response.result, reason: response.reason, state: response.state)
            })
        }
    }
    
    func notifyRetrievePaymentResponse(_ response:RetrievePaymentResponseMessage) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onRetrievePaymentResponse(response.result, reason: response.reason, queryStatus: response.queryStatus, payment: response.payment, externalPaymentId: response.externalPaymentId)
            })
        }
    }
    
    func notifyMessageFromActivity(_ response:ActivityMessageFromActivity) {
        for listener in deviceObservers {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                (listener as? CloverDeviceObserver)?.onMessageFromActivity(response.action, payload: response.payload)
            })
        }
    }
}