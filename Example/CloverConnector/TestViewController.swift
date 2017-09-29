//
//  JSON_KEYS.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import UIKit
import CloverConnector
import SwiftyJSON
import ObjectMapper

public struct JSON_KEYS {
    
    static let PAYLOAD = "payload"
    static let ORDER_ID = "orderId"
    static let PAYMENT_ID = "paymentId"
    static let ORDER = "order"
    static let PAYMENT = "payment"
    static let VAULTED_CARD = "vaultedCard"
    static let CARD = "card"
    static let NAME = "name"
    static let INPUT_OPTIONS = "inputOptions"
    static let DEVICE_REQUESTS = "deviceRequests"
    static let TYPE = "type"
    static let EXPECT = "expect"
    static let RESPONSE = "response"
    static let CASES = "cases"
    static let METHOD = "method"
    static let REQUEST = "request"
    static let STORE = "store"
    
    static let METHOD_AUTH = "AUTH"
    static let METHOD_SALE = "SALE"
    static let METHOD_PREAUTH = "PREAUTH"
    static let METHOD_MANUAL_REFUND = "MANUAL_REFUND"
    static let METHOD_TIP_ADJUST = "TIP_ADJUST"
    static let METHOD_CAPTURE_PREAUTH = "CAPTURE_PREAUTH"
    static let METHOD_VAULT_CARD = "VAULT_CARD"
    static let METHOD_READ_CARD_DATA = "READ_CARD_DATA"
    static let METHOD_REFUND_PAYMENT = "REFUND_PAYMENT"
    static let METHOD_VOID_PAYMENT = "VOID_PAYMENT"
    static let METHOD_PRINT_TEXT = "PRINT_TEXT"
    static let METHOD_DISPLAY_ORDER = "DISPLAY_ORDER"
    static let METHOD_RETRIEVE_PENDING_PAYMENTS = "RETRIEVE_PENDING_PAYMENTS"
    static let METHOD_OPEN_CASH_DRAWER = "OPEN_CASH_DRAWER"
}

public class TestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var uiStateLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var testLoadURL: UITextField!
    
    @IBOutlet weak var testResultsTable: UITableView!
    
    var cases:NSMutableArray = NSMutableArray()
    
    var caseRunner:CaseRunner?

    
    public override func viewDidLoad() {
        debugPrint("stuff")
        
        self.testResultsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    public override func viewDidAppear(_ animated: Bool) {
        debugPrint("Test Did Appear")
        debugPrint("adding test listener")
        if let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.cloverConnector?.removeCloverConnectorListener(appDelegate.cloverConnectorListener!)
            //appDelegate.cloverConnector?.addCloverConnectorListener(appDelegate.testCloverConnectorListener!)
            appDelegate.testCloverConnectorListener!.viewController = self
        }
        
        
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        debugPrint("Test Disappeared")
        if let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.cloverConnector?.removeCloverConnectorListener(appDelegate.testCloverConnectorListener!)
            appDelegate.cloverConnector?.addCloverConnectorListener(appDelegate.cloverConnectorListener!)
        }
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            let p = sender.locationInView(testResultsTable)
            let indexPath = testResultsTable.indexPathForRowAtPoint(p)
            
            if let row = indexPath?.row {
                
                if let c = cases.objectAtIndex(row) as? Case {
                    c.passed = nil
                    dispatch_async(dispatch_get_main_queue()){
                        self.testResultsTable.reloadData()
                    }
                    c.run()
                }
            }
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cases.count;
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //        var cell:UITableViewCell = self.testResultsTable.dequeueReusableCell(withIdentifier: "defaultCell") as UITableViewCell
        let cell:UITableViewCell = self.testResultsTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let currentCase = (cases.objectAtIndex(indexPath.row) as! Case)
    
        if let finished = currentCase.passed {
            cell.textLabel?.text = (currentCase.name ?? "?") + ": " + (finished.0 == true ? "✅" : "🛑") + (finished.1 ?? "")
        } else {
            cell.textLabel?.text = (currentCase.name ?? "?") + ": " + "🏃"
        }
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    var selTestCase:Case?
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        selTestCase = cases.objectAtIndex(indexPath.row) as? Case
//        if let tvc = self.storyboard?.instantiateViewController(withIdentifier: "TestDetails") as? TestDetailsViewController {
//            tvc.testCase = selTestCase
//            self.navigationController?.pushViewController(tvc, animated: true)
//        }
        performSegueWithIdentifier("TestDetails", sender: self)
    }
    
    @IBAction
    func prepareforUnwind(segue:UIStoryboardSegue) {
    //
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let td = segue.destinationViewController as? TestDetailsViewController,
            let selectedTestCase = selTestCase {
            td.testCase = selectedTestCase
        }
    }
    
    
    @IBAction func rerunTests(_ sender: AnyObject) {
        self.caseRunner?.restart()
    }

    @IBAction func loadTests(_ sender: UIButton) {
        loadAndRunTests(false)
    }
    
    @IBAction func loadAndRunTests(_ sender: UIButton) {

        loadAndRunTests(true)
    }
    
    
    private func loadAndRunTests(_ autoRun:Bool) {
        var loadData:NSData?
        cases.removeAllObjects()
        testResultsTable.reloadData()
        if testLoadURL.text?.characters.count == 0 {
            if let path = NSBundle.mainBundle().pathForResource( "test1", ofType: "json") {
                do {
                    
                    if let data = NSData(contentsOfURL:NSURL(fileURLWithPath: path)) {
                        let datastring = String(data: data, encoding: NSUTF8StringEncoding)
                        debugPrint("JSON: " + datastring!)
                        
                        loadData = data
                    }
                    
                } catch {
                    debugPrint("error getting file")
                }
            }
            
        } else {
            
            var session:NSURLSession = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithURL(NSURL(string: testLoadURL.text!)!, completionHandler: {data, response, error -> Void in
                //            debugPrint("JSON: " + String(data:data, enco))
                if error != nil {
                    debugPrint("error connecting")
                } else {
                    let datastring = String(data: data!, encoding: NSUTF8StringEncoding)
                    debugPrint("JSON: " + (datastring ?? ""))
                    debugPrint("JSON: " + (response?.MIMEType ?? "unknown"))
                    //let json:JSON = JSON(data: data!)
                    
                    loadData = data
                }
                
            })
            task.resume()
        }
        if let data = loadData {
            
            let json:JSON = JSON(data: data)
            if let jsonCases = json[JSON_KEYS.CASES].array {
                self.caseRunner = CaseRunner(jsonCases)
                self.caseRunner?.onTestStarted = {
                    (cs:Case) -> Void in
                    if(!self.cases.containsObject(cs)) {
                        self.cases.addObject(cs)
                        dispatch_async(dispatch_get_main_queue()){
                            self.testResultsTable.reloadData()
                        }
                    }
                }
                self.caseRunner?.onTestEnded = {
                    (cs:Case) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.testResultsTable.reloadData()
                    }
                }
                if(autoRun) {
                    self.caseRunner?.start()
                } else {
                    self.caseRunner?.register()
                }
            }
        }
        
    }
}

class CaseRunner {
    var cases = NSMutableArray()
    var onTestStarted:((testCase:Case) -> Void)?
    var onTestEnded:((testCase:Case) -> Void)?
    private var runningCase:Case?
    var storedValues = [String: Any]()
    
    private var nextCaseIndex = 0
    
    init(_ jsonCases:[JSON]) {
        debugPrint(cases.count)
        for var jSON in jsonCases {
            let cs = Case(name: jSON["name"].string, json: jSON, onComplete: {})
            cs.onComplete = {
                self.onTestEnded?(testCase: cs); self.runningCase = nil; self.nextCase()
            }
            cs.caseRunner = self
            self.cases.addObject(cs)
        }
    }
    init(cases:[Case]) {
        for aCase in cases {
            self.cases.addObject(aCase)
        }
    }
    func nextCase() {
        
        if self.cases.count > (self.nextCaseIndex) {
            if let currentCase = self.cases.objectAtIndex(self.nextCaseIndex) as? Case
            {
                self.runningCase = currentCase
                //                    self.cases.removeObject(at: 0)
                onTestStarted?(testCase: currentCase)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    currentCase.run()
                })
            }
            self.nextCaseIndex += 1
        } else {
            runningCase = nil
        }
    }
    func runCase(_ index:Int) {
        if self.cases.count > (index-1) {
            
        }
    }
    func start() {
        nextCaseIndex = 0
        nextCase()
    }
    func register() {
        self.nextCaseIndex = cases.count
        for var currentCase in self.cases {
            self.onTestStarted?(testCase: currentCase as! Case)
        }
    }
    func restart() {
        runningCase = nil
        nextCaseIndex = 0
        storedValues = [String: Any]()
        nextCase()
    }
}


class ResponseCloverConnector : DefaultCloverConnectorListener {
    var deviceRequests:JSON?
    var testCase:Case
    var inputOptions:JSON?
    var ioMap = [String:InputOption]()
    
    init(cloverConnector:ICloverConnector, testCase:Case, deviceRequests:JSON?, inputOptions:JSON?) {
        self.testCase = testCase
        super.init(cloverConnector: cloverConnector)
        self.deviceRequests = deviceRequests
        self.inputOptions = inputOptions
        if let json = self.inputOptions,
            let jsonArray = json.array {
            
            for var ioOpt in jsonArray {
                var on = ioOpt["on"]
                var opt = ioOpt["select"]
                
                if let key = opt.string,
                    let onStr = on.string {
                    
                    let io = InputOption(keyPress: KeyPress(rawValue:key)!, description: key)
                    ioMap[onStr] = io
                }
            }
        }
    }
    override func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        if let json = self.deviceRequests {
            
            let confirmMappings = json["onConfirmPayment"]
            
            for var challenge in request.challenges! {
                if "REJECT" == confirmMappings[(challenge.type?.rawValue)!] {
                    cloverConnector?.rejectPayment(request.payment!, challenge: challenge)
                    return
                }
            }
        }
        
        // accept by default
        cloverConnector?.acceptPayment(request.payment!)
    }
    override func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) {
        if let json = self.deviceRequests {
            if "REJECT" == json["onVerifySignature"] {
                cloverConnector?.rejectSignature(signatureVerifyRequest)
                return
            }
        }
        // accept by default
        cloverConnector?.acceptSignature(signatureVerifyRequest)
    }
    
    override func onDeviceActivityStart(_ deviceEvent: CloverDeviceEvent) {
        if let io = self.ioMap[deviceEvent.eventState ?? ""] {
            cloverConnector?.invokeInputOption(io)
        }
    }
    //
    public func compare(_ jsonA:JSON, within:JSON) -> (Bool, String?) {
        
        if let keys = jsonA.dictionary?.keys {
            
            for var key in (jsonA.dictionary?.keys)! {
                var A = jsonA[key]
                var B = within[key]
                if let bVal = A.bool,
                    let bbVal = B.bool {
                    if bVal != bbVal {
                        return (false, "expected " + String(bVal) + " but got " + String(bbVal))
                    }
                } else if let sVal = A.string {
                    if sVal == "*" {
                        if (B.rawString() == nil || B.type == Type.Null) {
                            return (false, "expected a value, but was nil")
                        }
                    } else if sVal != B.string {
                        return (false, "expected " + sVal + " but got " + (B.string ?? ""))
                    }
                } else if let iVal = A.int,
                    let biVal = B.int {
                    if(iVal != biVal) {
                        return (false, "expected " + String(iVal) + " but got " + String(B.int))
                    }
                } else if let _ = A.dictionary {
                    var result = compare(A, within: B)
                    if !result.0 {
                        return result
                    }
                }
            }
        }
        return (true, nil)
    }
}
class TestResponseCloverConnector : ResponseCloverConnector {
    var expectedResponse:JSON?
    var store:JSON?
    init(cloverConnector: ICloverConnector, testCase:Case, deviceRequests: JSON?, expectedResponse: JSON?, inputOptions: JSON?, store: JSON?) {
        super.init(cloverConnector: cloverConnector, testCase: testCase, deviceRequests: deviceRequests, inputOptions: inputOptions)
        self.expectedResponse = expectedResponse
        self.store = store
    }
    
    override func onSaleResponse(_ response: SaleResponse) {
        let jsonString = Mapper().toJSONString(response, prettyPrint: false)
        storePaymentResponse(response)
        compare(jsonString)
    }
    override func onAuthResponse(_ authResponse: AuthResponse) {
        let jsonString = Mapper().toJSONString(authResponse, prettyPrint: false)
        storePaymentResponse(authResponse)
        compare(jsonString)
    }
    
    override func onPreAuthResponse(_ preAuthResponse: PreAuthResponse) {
        let jsonString = Mapper().toJSONString(preAuthResponse, prettyPrint: false)
        storePaymentResponse(preAuthResponse)
        compare(jsonString)
    }
    
    override func onManualRefundResponse(_ manualRefundResponse: ManualRefundResponse) {
        let jsonString = Mapper().toJSONString(manualRefundResponse, prettyPrint: false)
        compare(jsonString)
    }
    
    override func onVaultCardResponse(_ vaultCardResponse: VaultCardResponse) {
        let jsonString = Mapper().toJSONString(vaultCardResponse, prettyPrint: false)
        
        if store?["vaultedCard"] != nil,
            let key = store?["vaultedCard"].string,
            let vaultedCard = vaultCardResponse.card {
            testCase.caseRunner?.storedValues[key] = vaultedCard
        }
        compare(jsonString)
    }
    
    override func onTipAdjustAuthResponse(_ tipAdjustAuthResponse: TipAdjustAuthResponse) {
        let jsonString = Mapper().toJSONString(tipAdjustAuthResponse, prettyPrint: false)
        if store?[JSON_KEYS.PAYMENT_ID] != nil {
            if let key = store?[JSON_KEYS.PAYMENT_ID].string {
                testCase.caseRunner?.storedValues[key] = tipAdjustAuthResponse.paymentId
            }
        }
        compare(jsonString)
    }
    
    override func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) {
        let jsonString = Mapper().toJSONString(refundPaymentResponse, prettyPrint: false)
        compare(jsonString)
    }
    
    override func onVoidPaymentResponse(_ voidPaymentResponse: VoidPaymentResponse) {
        let jsonString = Mapper().toJSONString(voidPaymentResponse, prettyPrint: false)
        compare(jsonString)
    }
    
    override func onCapturePreAuthResponse(_ capturePreAuthResponse: CapturePreAuthResponse) {
        let jsonString = Mapper().toJSONString(capturePreAuthResponse, prettyPrint: false)
        
        if store?[JSON_KEYS.PAYMENT_ID] != nil {
            if let key = store?[JSON_KEYS.PAYMENT_ID].string {
                testCase.caseRunner?.storedValues[key] = capturePreAuthResponse.paymentId
            }
        }
        if store?["amount"] != nil {
            if let key = store?["amount"].string {
                testCase.caseRunner?.storedValues[key] = capturePreAuthResponse.amount
            }
        }
        if store?["tipAmount"] != nil {
            if let key = store?["tipAmount"].string {
                testCase.caseRunner?.storedValues[key] = capturePreAuthResponse.tipAmount
            }
        }
        
        compare(jsonString)
    }
    
    override func onReadCardDataResponse(_ readCardDataResponse: ReadCardDataResponse) {
        let jsonString = Mapper().toJSONString(readCardDataResponse, prettyPrint: false)
        compare(jsonString)
    }

    override func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse: RetrievePendingPaymentsResponse) {
        let jsonString = Mapper().toJSONString(retrievePendingPaymentResponse, prettyPrint: false)
        compare(jsonString)
    }
    
    override func onDeviceError(_ deviceError: CloverDeviceErrorEvent) {
        self.testCase.done((false, "Device Error"))
    }

    
    private func storePaymentResponse(_ response:PaymentResponse) {
        if store?[JSON_KEYS.PAYMENT] != nil,
            let key = store?[JSON_KEYS.PAYMENT].string,
            let payment = response.payment {
            testCase.caseRunner?.storedValues[key] = payment
        }
        if store?[JSON_KEYS.PAYMENT_ID] != nil,
            let key = store?[JSON_KEYS.PAYMENT_ID].string,
            let paymentId = response.payment?.id {
            testCase.caseRunner?.storedValues[key] = paymentId
        }
        if store?[JSON_KEYS.ORDER] != nil,
            let key = store?[JSON_KEYS.ORDER].string,
            let order = response.payment?.order {
            testCase.caseRunner?.storedValues[key] = order
        }
        if store?[JSON_KEYS.ORDER_ID] != nil,
            let key = store?[JSON_KEYS.ORDER_ID].string,
            let orderId = response.payment?.order?.id {
            testCase.caseRunner?.storedValues[key] = orderId
        }
        if store?["amount"] != nil,
            let key = store?["amount"].string,
            let amount = response.payment?.amount {
            testCase.caseRunner?.storedValues[key] = amount
        }
    }
    
    private func compare(jsonString:String?) {
        if let data = jsonString!.dataUsingEncoding(NSUTF8StringEncoding) {
            debugPrint("response is: " + jsonString!)
            
            let match = compare(expectedResponse!, within: JSON(data: data))
            self.testCase.response = jsonString
            self.testCase.done( match)
        } else {
            self.testCase.done((false,"Couldn't compare"))
        }
    }
}


class Case {
    var name:String?
    var json:JSON?
    var onComplete:() -> Void
    var cloverConnectorListener:ICloverConnectorListener?
    var cloverConnector:ICloverConnector
    var passed:(Bool, String?)?
    var caseRunner:CaseRunner?
    var testJSON:JSON?
    var request:String?
    var response:String?
    
    init(name:String?, json:JSON, onComplete:() -> Void) {
        self.name = name
        self.json = json
        self.onComplete = onComplete
        self.cloverConnector = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.cloverConnector)!
    }
    
    func resolveVaultedCard(_ payload:JSON) -> CLVModels.Payments.VaultedCard? {
        var vaultedCard:CLVModels.Payments.VaultedCard?
        
        if payload[JSON_KEYS.VAULTED_CARD].dictionary != nil {
            if let vcStr = (payload[JSON_KEYS.VAULTED_CARD] as JSON).rawString(NSUTF8StringEncoding) {
                vaultedCard = Mapper<CLVModels.Payments.VaultedCard>().map(vcStr)
                
            }
        } else if let vcVarMarker = payload[JSON_KEYS.VAULTED_CARD].string where
            vcVarMarker.substringToIndex(vcVarMarker.startIndex.advancedBy(1)) == "$" &&
            vcVarMarker.characters.count > 1 {
            let key = vcVarMarker.substringFromIndex(vcVarMarker.startIndex.advancedBy(1))
            if let vc = self.caseRunner?.storedValues[key] as? CLVModels.Payments.VaultedCard {
                vaultedCard = vc
            }
        }
        return vaultedCard
    }
    
    func resolvePrimitive(_ key:String?) -> Any?
    {
        if let key = key {
            if key.substringToIndex(key.startIndex.advancedBy(1)) == "$" &&
                key.characters.count > 1 {
                let keyName = key.substringFromIndex(key.startIndex.advancedBy(1))
                return caseRunner?.storedValues[keyName]
            }
        }
        return key
    }
    
    public func done(_ withResult: (Bool, String?)) {
        passed = withResult
        if let ccl = cloverConnectorListener {
            self.cloverConnector.removeCloverConnectorListener(ccl)
        }
        onComplete()
    }
    
    public func run() {
        guard let method = json?[JSON_KEYS.METHOD].string else {
            debugPrint("No method")
            return
        }
        
        debugPrint("method is " + method)
        
        
        self.testJSON = json
        if method == JSON_KEYS.METHOD_SALE {
            if json?[JSON_KEYS.REQUEST][JSON_KEYS.TYPE] == "SaleRequest" {
                if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                    let amount = payload["amount"].int ?? 1234
                    let externalId = payload["externalId"].string ?? String(arc4random())
                    
                    let sr = SaleRequest(amount: amount, externalId: externalId)
                    sr.tipAmount = payload["tipAmount"].int
                    if let _ = sr.tipAmount {
                        sr.tipMode = SaleRequest.TipMode.TIP_PROVIDED
                    }
                    sr.disablePrinting = payload["disablePrinting"].bool
                    sr.tippableAmount = payload["tippableAmount"].int
                    sr.disableCashback = payload["disableCashback"].bool
                    sr.disableTipOnScreen = payload["disableTipOnScreen"].bool
                    sr.allowOfflinePayment = payload["allowOfflinePayment"].bool
                    sr.approveOfflinePaymentWithoutPrompt = payload["approveOfflinePaymentWithoutPrompt"].bool
                    sr.taxAmount = payload["taxAmount"].int
                    if let cem = payload["cardEntryMethods"].int {
                        sr.cardEntryMethods = cem
                    }
                    sr.cardNotPresent = payload["cardNotPresent"].bool
                    sr.disableRestartTransactionOnFail = payload["disableRestartTransactionOnFail"].bool
                    sr.vaultedCard = resolveVaultedCard(payload)
                    sr.autoAcceptSignature = payload["autoAcceptSignature"].bool
                    sr.autoAcceptPaymentConfirmations = payload["autoAcceptPaymentConfirmations"].bool
                    
                    request = Mapper<SaleRequest>.toJSONString(sr, prettyPrint:true)
                    
                    cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                    cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                    cloverConnector.sale(sr)
                } else {
                    done((false, "Couldn't get payload"))
                }
            } else {
                done((false, "Couldn't get type"))
            }
        } else if method == JSON_KEYS.METHOD_AUTH {
            if json?[JSON_KEYS.REQUEST][JSON_KEYS.TYPE] == "AuthRequest" {
                if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                    let amount = payload["amount"].int ?? 1234
                    let externalId = payload["externalId"].string ?? String(arc4random())
                    
                    let ar = AuthRequest(amount: amount, externalId: externalId)
                    ar.disablePrinting = payload["disablePrinting"].bool
                    ar.disableCashback = payload["disableCashback"].bool
                    ar.allowOfflinePayment = payload["allowOfflinePayment"].bool
                    ar.approveOfflinePaymentWithoutPrompt = payload["approveOfflinePaymentWithoutPrompt"].bool
                    ar.taxAmount = payload["taxAmount"].int
                    if let cem = payload["cardEntryMethods"].int {
                        ar.cardEntryMethods = cem
                    }
                    ar.cardNotPresent = payload["cardNotPresent"].bool
                    ar.disableRestartTransactionOnFail = payload["disableRestartTransactionOnFail"].bool
                    ar.vaultedCard = resolveVaultedCard(payload)
                    
                    ar.autoAcceptSignature = payload["autoAcceptSignature"].bool
                    ar.autoAcceptPaymentConfirmations = payload["autoAcceptPaymentConfirmations"].bool
                    
                    request = Mapper<AuthRequest>.toJSONString(ar, prettyPrint:true)
                    
                    cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                    cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                    cloverConnector.auth(ar)
                    
                } else {
                    done((false, "Couldn't get payload"))
                }
            } else {
                done((false, "Couldn't get type"))
            }
        } else if method == JSON_KEYS.METHOD_PREAUTH {
            if json?[JSON_KEYS.REQUEST][JSON_KEYS.TYPE] == "PreAuthRequest" {
                if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                    let amount = payload["amount"].int ?? 1234
                    let externalId = payload["externalId"].string ?? String(arc4random())
                    
                    let par = PreAuthRequest(amount: amount, externalId: externalId)
                    par.disablePrinting = payload["disablePrinting"].bool
                    if let cem = payload["cardEntryMethods"].int {
                        par.cardEntryMethods = cem
                    }
                    par.cardNotPresent = payload["cardNotPresent"].bool
                    par.disableRestartTransactionOnFail = payload["disableRestartTransactionOnFail"].bool
                    par.vaultedCard = resolveVaultedCard(payload)
                    
                    par.autoAcceptSignature = payload["autoAcceptSignature"].bool
                    par.autoAcceptPaymentConfirmations = payload["autoAcceptPaymentConfirmations"].bool
                    
                    request = Mapper<PreAuthRequest>.toJSONString(par, prettyPrint:true)
                    
                    cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                    cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                    cloverConnector.preAuth(par)
                    
                } else {
                    done((false, "Couldn't get payload"))
                }
            } else {
                done((false, "Couldn't get type"))
            }
        } else if method == JSON_KEYS.METHOD_MANUAL_REFUND {
            if json?[JSON_KEYS.REQUEST][JSON_KEYS.TYPE] == "ManualRefundRequest" {
                if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                    let amount = payload["amount"].int ?? 1234
                    let externalId = payload["externalId"].string ?? String(arc4random())
                    
                    let mrr = ManualRefundRequest(amount: amount, externalId: externalId)
                    
                    if let cem = payload["cardEntryMethods"].int {
                        mrr.cardEntryMethods = cem
                    }
                    mrr.cardNotPresent = payload["cardNotPresent"].bool
                    mrr.disablePrinting = payload["disablePrinting"].bool
                    mrr.disableRestartTransactionOnFail = payload["disableRestartTransactionOnFail"].bool
                    mrr.vaultedCard = resolveVaultedCard(payload)
                    
                    mrr.autoAcceptSignature = payload["autoAcceptSignature"].bool
                    mrr.autoAcceptPaymentConfirmations = payload["autoAcceptPaymentConfirmations"].bool
                    
                    request = Mapper<ManualRefundRequest>.toJSONString(mrr, prettyPrint:true)
                    
                    cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                    cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                    cloverConnector.manualRefund(mrr)
                    
                } else {
                    done((false, "Couldn't get payload"))
                }
            } else {
                done((false, "Couldn't get type"))
            }
        } else if method == JSON_KEYS.METHOD_TIP_ADJUST {
            if let orderIdKey = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD][JSON_KEYS.ORDER_ID].string,
                let orderId = resolvePrimitive(orderIdKey) as? String,
                let paymentIdKey = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD][JSON_KEYS.PAYMENT_ID].string,
                let paymentId = resolvePrimitive(paymentIdKey) as? String,
                let tipAmount = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["tipAmount"].int {
                
                let tar = TipAdjustAuthRequest(orderId: orderId, paymentId: paymentId, tipAmount: tipAmount)
                
                request = Mapper<TipAdjustAuthRequest>.toJSONString(tar, prettyPrint:true)
                
                cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                cloverConnector.tipAdjustAuth(tar)
                
            } else {
                done( (false, "Error getting orderId, paymentId and tipAmount"))
            }
            
        } else if method == JSON_KEYS.METHOD_CAPTURE_PREAUTH {
            if let paymentIdKey = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD][JSON_KEYS.PAYMENT_ID].string,
                let paymentId = resolvePrimitive(paymentIdKey) as? String {
                let amount = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["amount"].int ?? 1234
                
                let cpa = CapturePreAuthRequest(amount: amount, paymentId: paymentId)
                cpa.tipAmount = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["tipAmount"].int
                
                request = Mapper<CapturePreAuthRequest>.toJSONString(cpa, prettyPrint:true)
                
                cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                cloverConnector.capturePreAuth(cpa)
            } else {
                done( (false, "Couldn't get paymentId"))
            }
            
        } else if method == JSON_KEYS.METHOD_VAULT_CARD {
            let vcr = VaultCardRequest()
            if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                if let cem = payload["cardEntryMethods"].int {
                    vcr.cardEntryMethods = cem
                }
            }
            
            request = Mapper<VaultCardRequest>.toJSONString(vcr, prettyPrint:true)
            
            cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
            cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
            cloverConnector.vaultCard(vcr)
        } else if method == JSON_KEYS.METHOD_READ_CARD_DATA {
            let rcdr = ReadCardDataRequest()
            if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                if let cem = payload["cardEntryMethods"].int {
                    rcdr.cardEntryMethods = cem
                }
                if let fspe = payload["forceSwipePinEntry"].bool {
                    rcdr.forceSwipePinEntry = fspe
                }
            }
            
            request = Mapper<ReadCardDataRequest>.toJSONString(rcdr, prettyPrint:true)
            
            cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
            cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
            cloverConnector.readCardData(rcdr)
        } else if method == JSON_KEYS.METHOD_REFUND_PAYMENT {
            if let orderIdKey = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD][JSON_KEYS.ORDER_ID].string,
                let orderId = resolvePrimitive(orderIdKey) as? String,
                let paymentIdKey = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD][JSON_KEYS.PAYMENT_ID].string,
                let paymentId = resolvePrimitive(paymentIdKey) as? String {
                
                let amount = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["amount"].int
                let isFullRefund = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["fullRefund"].bool
                // either amount or full refund = true
                let rpr = RefundPaymentRequest(orderId: orderId, paymentId: paymentId, amount: amount, fullRefund: isFullRefund)
                
                request = Mapper<RefundPaymentRequest>.toJSONString(rpr, prettyPrint:true)
                
                cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                cloverConnector.refundPayment(rpr)
            } else {
                done( (false, "Couldn't get orderId and paymentId"))
            }
        } else if method == JSON_KEYS.METHOD_VOID_PAYMENT {
            if let orderIdKey = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD][JSON_KEYS.ORDER_ID].string,
                let orderId = resolvePrimitive(orderIdKey) as? String,
                let paymentIdKey = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD][JSON_KEYS.PAYMENT_ID].string,
                let paymentId = resolvePrimitive(paymentIdKey) as? String {
                
                let voidReason = VoidReason(rawValue: json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["voidReason"].string ?? VoidReason.USER_CANCEL.rawValue)
                let vpr = VoidPaymentRequest(orderId: orderId, paymentId: paymentId, voidReason: voidReason ?? .USER_CANCEL)
                
                request = Mapper<VoidPaymentRequest>.toJSONString(vpr, prettyPrint:true)
                
                cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                cloverConnector.addCloverConnectorListener(cloverConnectorListener!)
                cloverConnector.voidPayment(vpr)
            } else {
                done( (false, "Couldn't get orderId and paymentId"))
            }
        } else if method == JSON_KEYS.METHOD_PRINT_TEXT {
            if let textLines = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["text"].array {
                var text = [String](count:textLines.count, repeatedValue: "")
                for (index, line) in textLines.enumerate() {
                    text[index] = line.string ?? "N/A"
                }
                
                done( (true,nil))
                cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                
                if let request = PrintRequest(text: text, printRequestId: nil, printDeviceId: nil) {
                    cloverConnector.print(request)
                }
            } else {
                done( (false, "Couldn't create print message"))
            }
        } else if method == JSON_KEYS.METHOD_DISPLAY_ORDER {
            if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                let displayOrder = DisplayOrder()
                displayOrder.total = payload["total"].string ?? "$-0.00"
                displayOrder.subtotal = payload["subTotal"].string ?? "$-0.00"
                displayOrder.tax = payload["tax"].string ?? "$-0.00"
                if let items = payload["displayOrderItems"].array {
                    for (index, item) in items.enumerate() {
                        let dli = DisplayLineItem(id: String(index), name: item["name"].string ?? "Unknown", price: item["unitPrice"].string ?? "$0.00", quantity: String(item["quantity"].int ?? 1))
                        dli.alternateName = item["alternateName"].string
                        dli.binName = item["binName"].string
                        dli.discountAmount = item["discountAmount"].string
                        dli.exchanged = item["exchanged"].bool ?? false
                        dli.exchangedAmount = item["exchangedAmount"].string
                        dli.note = item["note"].string
                        dli.percent = item["percent"].string
                        dli.printed = item["printed"].bool ?? false
                        dli.refunded = item["refunded"].bool ?? false
                        dli.refundedAmount = item["refundedAmount"].string
                        dli.unitPrice = item["unitPrice"].string
                        dli.unitQuantity = item["unityQuantity"].string ?? nil
                        if let mods = item["modifications"].array {
                            let dlMods = [DisplayModification]()
                            for (modIndex, mod) in mods.enumerate() {
                                
                                let dm = DisplayModification()
                                dm.id = String(arc4random())
                                dm.name = mod["name"].string ?? "Unnamed"
                                dm.amount = mod["amount"].string ?? "$-0.00"
                            }
                            dli.modifications = dlMods
                        }
                        if let discounts = item["discounts"].array {
                            let diDiscounts = [DisplayDiscount]()
                            for (discountIndex, discount) in discounts.enumerate() {
                                
                                let dd = DisplayDiscount()
                                dd.id = String(discountIndex)
                                dd.lineItemId = dli.id
                                dd.amount = discount["amount"].string
                                dd.percentage = discount["percentage"].string
                                
                            }
                            dli.discounts = diDiscounts
                        }
                        
                        
                        displayOrder.lineItems.append(dli)
                    }
                }
                done((true, nil))
                cloverConnector.showDisplayOrder(displayOrder)
                
            } else {
                done((false, "Couldn't build Display Order"))
            }
        } else if method == JSON_KEYS.METHOD_RETRIEVE_PENDING_PAYMENTS {
            if let payload = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD] {
                done((true,nil))
                cloverConnectorListener = TestResponseCloverConnector(cloverConnector: self.cloverConnector, testCase: self, deviceRequests: json?[JSON_KEYS.DEVICE_REQUESTS], expectedResponse: json?[JSON_KEYS.EXPECT][JSON_KEYS.RESPONSE][JSON_KEYS.PAYLOAD], inputOptions: json?[JSON_KEYS.INPUT_OPTIONS], store: json?[JSON_KEYS.EXPECT][JSON_KEYS.STORE])
                cloverConnector.retrievePendingPayments()
            } else {
                done((false, "Error getting payload"))
            }
        } else if method == JSON_KEYS.METHOD_OPEN_CASH_DRAWER {
            let reason = json?[JSON_KEYS.REQUEST][JSON_KEYS.PAYLOAD]["reason"].string ?? "Unset"
            let request = OpenCashDrawerRequest(reason, deviceId: nil)
            cloverConnector.openCashDrawer(request)
            done((true, nil))
        } else {
            self.done((false, "Unsupported test type: " + method))
        }
    }
    
}
