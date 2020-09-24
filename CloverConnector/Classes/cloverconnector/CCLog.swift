//
//  CCLog.swift
//  CloverConnector
//
//

import Foundation

///
///  The Log class provides generic logging functionality with overridable closures to be used for redirecting log output.
///
///  The logger provides closures for overriding various behaviors:
///    Logging proceeds through the following path: CCLog.x --> xPrint --> xFormatter --> defaultLogPrint
///       - CCLog.x :          - Log entry point for all logging.  Static, cannot be overriden.
///       - xPrint  :          - Calls the formatter to obtain the log format, then defaultLogPrint on the
///                              proper queue to perform the logging.
///                            - Debug (.d, dPrint) and Test (.t, tPrint) calls are compiler flagged out using
///                              the DEBUG flag
///                            - This is a static var containing a closure.  Assign your own closure at runtime
///                              to override the default behavior, for example if you want the debug or test
///                              log statements to occur without the DEBUG flag set.
///                            - If you do override, please ensure that you spin off your logging onto the
///                              dispatchQueue (note the lowercase...) for optimal performance.
///                              defaultLogPrint will correct the queue if you forget, but this will involve
///                              an extra call.
///       - xFormatter:        - Processes the provided inputs into the formatted string for output on screen.
///                            - This is a static var containing a closure.  Assign your own closure at
///                              runtime to override the default behavior, for example to remove the [TEST] or
///                              DEBUG formatting.
///       - defaultLogPrint:   - Final log function, which iterates through the user assigned log handlers and
///                              finally prints to console.  Static, cannot be overriden.
///       - addLogHandler:     - Log handlers are called every time a CCLog.x call is made (inside defaultLogPrint).
///                            - Called from the dispatchQueue (lowercase...) queue.
///                            - Returns an integer which can be used to remove the log handler in the future
///                              (for example once your ViewController closes).  Contains weak references to
///                              the handlers, but if you don't tell us to remove the handler it will still
///                              cost cycles to iterate over the no longer valid handlers.
///       - removeLogHandler:  - Removes a log handler using the integer index returned from addLogHandler
///       - timeStampEnabled:  - When true, a timestamp will be added to the beginning of every statement (default false)
///       - dateFormatter:     - The formatter used to provide the time stamp for timeStampEnabled.
///                            - Set the format at runtime to change the time stamp format.
///       - verbosePrinting:   - When true, logs are printed in full
///                            - When false, logs are truncated to the maxPrintingLength (default)
///       - maxPrintingLength: - The maximum length of logs printed when verbsePrinting is false
///
///  By default, Debug and Test level logs do nothing unless the DEBUG compiler flag is set.
///
public class CCLog {
    
    /// true: a timestamp will be added to the beggining of the log statments.  Defaults to false.
    public static var timestampEnabled = false
    /// false: log statements are truncated to the length specified in maxPrintingLength
    /// true:  log statements are not truncated
    public static var verbosePrinting = false
    /// when verbosePrinting is set to false, all log statements will be truncated to this length
    public static var maxPrintingLength = 160
    /// the DateFormatter used to print the timestamp on log statements.  Default format is "yyyy-MM-dd HH:mm:ss.SSS".
    public static var dateFormatter = DateFormatter(withFormat: "yyyy-MM-dd HH:mm:ss.SSS  ")
    
    /// Debug level print statement
    /// Calls dPrint with the arguments provided
    public static func d(_ format : String, args : CVarArg..., line: Int = #line, file: String = #file) {
        dPrint(format,args,line,file)
    }
    /// Test level print statement
    /// Calls tPrint with the arguments provided
    public static func t(_ format : String, args : CVarArg..., line: Int = #line, file: String = #file) {
        tPrint(format,args,line,file)
    }
    /// Warning level print statement
    /// Calls wPrint with the arguments provided
    public static func w(_ format : String, args : CVarArg..., line: Int = #line, file: String = #file) {
        wPrint(format,args,line,file)
    }
    /// Serious level print statement
    /// Calls sPrint with the arguments provided
    public static func s(_ format : String, args : CVarArg..., line: Int = #line, file: String = #file) {
        sPrint(format,args,line,file)
    }
    
    
    /// Override point for debug level print statements
    /// Calls dFormatter to obtain the formatted string
    /// Calls defaultLogPrint on the dispatchQueue
    /// By default does not run unless the DEBUG compiler flag is set
    public static var dPrint:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->() = { (format:String, args:[CVarArg], line:Int, file:String)->() in
        #if DEBUG
        dispatchQueue.async {
            CCLog.defaultLogPrint(dFormatter(format,args,line,file))
        }
        #endif
    }
    /// Override point for test level print statements
    /// Calls tFormatter to obtain the formatted string
    /// Calls defaultLogPrint on the dispatchQueue
    /// By default does not run unless the DEBUG compiler flag is set
    public static var tPrint:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->() = { (format:String, args:[CVarArg], line:Int, file:String)->() in
        #if DEBUG
        dispatchQueue.async {
            CCLog.defaultLogPrint(tFormatter(format,args,line,file))
        }
        #endif
    }
    /// Override point for warning level print statements
    /// Calls wFormatter to obtain the formatted string
    /// Calls defaultLogPrint on the dispatchQueue
    public static var wPrint:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->() = { (format:String, args:[CVarArg], line:Int, file:String)->() in
        dispatchQueue.async {
            CCLog.defaultLogPrint(wFormatter(format,args,line,file))
        }
    }
    /// Override point for serious level print statements
    /// Calls sFormatter to obtain the formatted string
    /// Calls defaultLogPrint on the dispatchQueue
    public static var sPrint:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->() = { (format:String, args:[CVarArg], line:Int, file:String)->() in
        dispatchQueue.async {
            CCLog.defaultLogPrint(sFormatter(format,args,line,file))
        }
    }
    
    
    /// Override point for debug level print statement formatting
    /// Without overriding, prints with the format  "LineNumber : FileName     DEBUG    <print>"
    public static var dFormatter:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->(String) = { (format:String, args:[CVarArg], line:Int, file:String) -> (String) in
        let fileName = CCLog.fileName(path:file)
        if fileName.count > maxWidth { setMaxWidth(fileName.count) }
        return "\(timestampEnabled ? dateFormatter.string(from:Date()) : "")\(fixedWidthString(string: fileName, length: maxWidth)) : \(String(format: "%4 i", line))          DEBUG  \(String(format: format, arguments: args))"
    }
    /// Override point for test level print statement formatting
    /// Without overriding, prints with the format  "LineNumber : FileName     [TEST]    <print>"
    public static var tFormatter:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->(String) = { (format:String, args:[CVarArg], line:Int, file:String) -> (String) in
        let fileName = CCLog.fileName(path:file)
        if fileName.count > maxWidth { setMaxWidth(fileName.count) }
        return "\(timestampEnabled ? dateFormatter.string(from:Date()) : "")\(fixedWidthString(string: fileName, length: maxWidth)) : \(String(format: "%4 i", line))        [TEST]   \(String(format: format, arguments: args))"
    }
    /// Override point for warning level print statement formatting
    /// Without overriding, prints with the format  "LineNumber : FileName     ! WARNING !    <print>"
    public static var wFormatter:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->(String) = { (format:String, args:[CVarArg], line:Int, file:String) -> (String) in
        let fileName = CCLog.fileName(path:file)
        if fileName.count > maxWidth { setMaxWidth(fileName.count) }
        return "\(timestampEnabled ? dateFormatter.string(from:Date()) : "")\(fixedWidthString(string: fileName, length: maxWidth)) : \(String(format: "%4 i", line))     ! WARNING ! \(String(format: format, arguments: args))"
    }
    /// Override point for severe level print statement formatting
    /// Without overriding, prints with the format  "LineNumber : FileName    !! SEVERE !!   <print>"
    public static var sFormatter:(_ format: String, _ args: [CVarArg] , _  line: Int, _  file: String)->(String) = { (format:String, args:[CVarArg], line:Int, file:String) -> (String) in
        let fileName = CCLog.fileName(path:file)
        if fileName.count > maxWidth { setMaxWidth(fileName.count) }
        return "\(timestampEnabled ? dateFormatter.string(from:Date()) : "")\(fixedWidthString(string: fileName, length: maxWidth)) : \(String(format: "%4 i", line))  !! SEVERE !!   \(String(format: format, arguments: args))"
    }
    
    
    // The DispatchQueue that each notification will take place on.  Used to make the listeners array thread safe.
    // If you override the xPrint functions, ensure that your overridden closure executes on this queue.
    public static var dispatchQueue = DispatchQueue(label: "com.clover.cclog.\(UUID().uuidString)")
    
    /// the default logger - always call this last if you override xPrint.
    /// always call on the dispatchQueue thread.
    public static func defaultLogPrint(_ string:String, respawn:Bool = true)->() {
        // check the queue we're on, and if we're not on the right one then spin off onto the right one
        guard String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) == dispatchQueue.label else {
            if respawn { // check to prevent an infinite loop if the gcd call above starts failing due to a future change in the underlying system
                dispatchQueue.async {
                    defaultLogPrint(string, respawn: false) // set to false in case of a gcd lookup failure so we don't infinite loop
                }
            }
            return
        }
        // figure out what we'll be printing first
        let outString = verbosePrinting ? string : fixedWidthString(string: string, length: maxPrintingLength, endString: "...")
        for logHandler in CCLog.logHandlers {
            // this is happening on our dedicated queue, so consumers will need to make sure their callbacks are happening on the thread they want it on...
            logHandler.handler(string)
        }
        // need to spin these out onto the main queue so that they show up timely to the console
        DispatchQueue.main.async {
            Swift.print(outString)
        }
    }
    
    
    
    
    /// Add a custom log handler to receive callbacks whenever a Log.x statement is posted.
    /// Returns the index value for use in removing your handler at a later time
    /// Log handlers will be called from a background thread
    public static func addLogHandler(handler:@escaping (_ string:String)->()) -> Int {
        // use objc_sync_enter to lock the lastHandlerIndex against mutation while we're using it.
        // can't use the dispatchQueue for lastHandlerIndex because we want to return the value from this function.
        objc_sync_enter(self)
        defer {objc_sync_exit(self)}
        CCLog.lastHandlerIndex += 1
        let index = CCLog.lastHandlerIndex
        CCLog.dispatchQueue.async { // do the modifications of the logHandlers inside the dispatchQueue
            CCLog.logHandlers.append((index,handler))
        }
        return CCLog.lastHandlerIndex
    }
    /// Removes a log handler from the system.
    /// Pass in the index value you received when you called addLogHandler.
    public static func removeLogHandler(handlerIndex:Int) {
        CCLog.dispatchQueue.async {
            guard let index = CCLog.logHandlers.firstIndex(where: {$0.handlerIndex == handlerIndex}) else { return }
            CCLog.logHandlers.remove(at: index)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    /// array of log handlers which will be called whenever a Log.x call is made
    fileprivate static var logHandlers = [(handlerIndex:Int,handler:(string:String)->())]()
    /// the index of the last handler added.  Used to ensure we hand out unique indices for each add call.
    fileprivate static var lastHandlerIndex = 0
    
    
    fileprivate static var maxWidth = 20
    fileprivate static func setMaxWidth(_ maxWidth:Int) {
        objc_sync_enter(self)
        defer {objc_sync_exit(self)}
        self.maxWidth = maxWidth
    }
    
    fileprivate static func fixedWidthString(string:String, length:Int, endString:String = "") -> String {
        let postFix = string.count > length ? endString : ""
        return String(string.prefix(length)).padding(toLength: length, withPad: " ", startingAt: 0) + postFix
    }
    fileprivate static func fileName(path:String) -> String {
        return (path.components(separatedBy: "/").last ?? "").components(separatedBy: ".").first ?? ""
    }
}

fileprivate extension DateFormatter {
    convenience init(withFormat format : String) {
        self.init()
        dateFormat = format
    }
}
