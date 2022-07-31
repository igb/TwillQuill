//
//  TwitterClient.swift
//  Twill
//
//  Created by Ian Brown on 5/28/22.
//

import Foundation
import CryptoKit
import Network

class TwitterClient {
    
    let apiKey:String;
    let apiSecret:String;
    let accessToken:String;
    let accessTokenSecret:String;
    
    //set this for testing
    let uploadUrl:String;

    init(apiKey:String, apiSecret:String, accessToken:String, accessTokenSecret:String) {
        self.apiKey=apiKey
        self.apiSecret=apiSecret
        self.accessToken=accessToken
        self.accessTokenSecret=accessTokenSecret
        self.uploadUrl="";
    }
    
    init() {
        self.apiKey=""
        self.apiSecret=""
        self.accessToken=""
        self.accessTokenSecret=""
        self.uploadUrl="";
    }
    
    
    init(uploadUrl:String) {
        self.apiKey=""
        self.apiSecret=""
        self.accessToken=""
        self.accessTokenSecret=""
        self.uploadUrl=uploadUrl;
    }
    
    func tweet(tweet: String) {
        
        

        
        NSLog(tweet)
        var body="status="
        body+=escapeUri(uri: tweet)
        let url = URL(string: "https://api.twitter.com/1.1/statuses/update.json")!
        var request = URLRequest(url: url)
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("api.twitter.com", forHTTPHeaderField: "Host")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let auth = createOAuthHeader(params: [("status", tweet)], url: "https://api.twitter.com/1.1/statuses/update.json", apiKey: self.apiKey, apiSecret: self.apiSecret, accessToken: self.accessToken, accessTokenSecret: self.accessTokenSecret, nonce: getOauthNonce(), timestamp: getOauthTimestamp(), method: "post")

        
        request.addValue(auth, forHTTPHeaderField: "Authorization")

        
        
        request.httpMethod = "POST"
        request.httpBody = Data(body.utf8)
        
        request.log();
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                }
        }
        task.resume()
        
        
    }
    
    
    
    func tweetImage(image: Data, altText: String, status: String) {
      
        NSLog("start upload")
        let mediaId=upload(image:image)
        
        addAltText(mediaId: mediaId, altText:altText)
        let headers=[("Accept", "*/*"),
                ("Host","api.twitter.com"),
                ("Content-Type","application/x-www-form-urlencoded"),
                ("Authorization",
                 createOAuthHeader(params:[("status", status), ("media_ids", mediaId)], url:"https://api.twitter.com/1.1/statuses/update.json", apiKey:apiKey, apiSecret:apiSecret, accessToken:accessToken, accessTokenSecret:accessTokenSecret, nonce:getOauthNonce(), timestamp:getOauthTimestamp(), method:"Post"))]
              
                 
        let url = URL(string: "https://api.twitter.com/1.1/statuses/update.json?status=" + self.escapeUri(uri:status)  + "&media_ids=" + mediaId)!
                 var request = URLRequest(url: url)
                 
                 for (index, (key, value)) in headers.enumerated() {
                     request.addValue(value, forHTTPHeaderField: key)
                 }
                 
                request.httpMethod = "POST"

                 // Perform HTTP Request
                 let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                         
                         // Check for Error
                         if let error = error {
                             print("Error took place \(error)")
                             return
                         }
                  
                         // Convert HTTP Response Data to a String
                         if let data = data, let dataString = String(data: data, encoding: .utf8) {
                             print("Response data string:\n \(dataString)")
                         }
                 }
        task.resume()
                 
                 
          
                   
    }
    
    func upload(image:Data) -> String {
        
        NSLog("in upload...calling init")
        let mediaId = uploadInit(image:image)

        NSLog("chunking...")

        let chunks=chunk(image:image, size:10485760)
        NSLog("upload append...")

        uploadAppend(chunks:chunks, mediaId:mediaId)
        uploadFinalize(mediaId:mediaId)
        return mediaId
        
    }
    
    func chunk(image:Data, size:Int) -> [Data] {
        var chunks = [Data]();
        if (image.count < size) {
            chunks.append(image)
        } else {
            NSLog("image needs to be split...")
                  
                  }
        return chunks
    }
    
    func generatePost(headers:[(String, String)], path:String, body:Data) -> NSData {
        var postData = NSMutableData();
        
        var request = "POST " + path + "  HTTP/1.1\r\n";
        for (key, value) in headers {
            request += key + ": " + value + "\r\n";
        }
        
        request += "\r\n"
        
        postData.append(request.data(using: .utf8) ?? NSMutableData() as Data)
        postData.append(body)
        request += body.toString() ?? "";
        request += "\r\n"
        postData.append("\r\n".data(using: .utf8) ?? NSMutableData() as Data)
        
        NSLog("post string length %d", request.count);

        
        let requestData = request.data(using: .utf8)
        
        NSLog("post data length %d", requestData?.count ?? 0);
        
        return postData;
    }
    
    
    func post(hostname:String, portNumber:UInt16, headers:[(String, String)], path:String, body:Data, secure:Bool, semaphore:DispatchSemaphore) {
        
        var postData = generatePost(headers:headers, path: path, body: body);
        
        
        let queue = DispatchQueue(label: "Client connection Q")

        
        let host = NWEndpoint.Host(hostname)
        let port = NWEndpoint.Port(rawValue: portNumber)!
        let tcpOptions = NWProtocolTCP.Options();
        let tlsOptions = NWProtocolTLS.Options();
        

        let nwConnection = NWConnection(host: host, port: port, using: secure ? .tls : .tcp);
        nwConnection.start(queue: queue)

        nwConnection.send(content: postData, completion: .contentProcessed( { error in
            if let error = error {
                NSLog("error!! sock")
                NSLog(error.debugDescription)
                //self.connectionDidFail(error: error)
                return
            }
            NSLog("worked?! sock");
                print("connection did send, data: \(body as NSData)")
        }))
        
        
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
                    if let data = data, !data.isEmpty {
                        let message = String(data: data, encoding: .utf8)
                        print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
                    }
                    if isComplete {
                        NSLog("post complete");
                        semaphore.signal();
                    } else if let error = error {
                        NSLog(error.debugDescription);
                        semaphore.signal();
                    } else {
                        NSLog("shrug");
                        semaphore.signal();
                    }
                }
        
        semaphore.signal();
        
        
        
    }
    
    func uploadAppend(chunks:[Data], mediaId:String) {
        
        
        
        let decodedData = String(decoding: chunks[0], as: UTF8.self)
        NSLog("lnght %d", decodedData.count)
        NSLog("olnght %d", chunks[0].count)
        
        let params = [("segment_index", String(0).data(using: .utf8) ?? NSMutableData() as Data ),
              ("media_id", mediaId.data(using: .utf8) ?? NSMutableData() as Data),
              ("command", "APPEND".data(using: .utf8) ?? NSMutableData() as Data),
              ("media", chunks[0])
        ]
        
        let urlString = uploadUrl.count > 0 ? uploadUrl :  "https://upload.twitter.com/1.1/media/upload.json"


        let multiPartBody=generateMultipartBody(params:params, boundary:"00Twurl788615393766630399lruwT99")
        

        let contentLength = String(multiPartBody.toString()?.count ?? 0);
        NSLog("content length %@", contentLength)

        let headers =  [("Accept", "*/*"),
                        ("Host", "upload.twitter.com"),
                        ("Content-Type", "multipart/form-data; boundary=\"00Twurl788615393766630399lruwT99\""),
                        ("Content-Length", contentLength),
                        ("Authorization",
                         createOAuthHeader(params:[], url:urlString, apiKey: apiKey, apiSecret: apiSecret, accessToken: accessToken, accessTokenSecret: accessTokenSecret, nonce: getOauthNonce(),timestamp: getOauthTimestamp(),method: "Post"))]

        
        
        
        
        
        
        
       
      /*  NSLog("socket 2me")

        //   post(hostname: "127.0.0.1", portNumber: 8080, headers: headers, path: "/postest/diff/SwiftVsErlang/2", body: multiPartBody, secure: false)
        
        let semaphore = DispatchSemaphore(value: 0)

        post(hostname: "upload.twitter.com", portNumber: 443, headers: headers, path: "/1.1/media/upload.json", body: multiPartBody, secure: true, semaphore:semaphore)
    
        semaphore.wait()
       */

    
      
        let url = URL(string:urlString)
        var request = URLRequest(url: url!)


        
             
        request.allHTTPHeaderFields = headersDict(parameters: headers);
        
         request.httpMethod = "POST"
        request.httpBody = multiPartBody;

        // request.log();
        let semaphore = DispatchSemaphore(value: 0)

         // Perform HTTP Request
         let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                 
                 // Check for Error
                 if let error = error {
                     print("Error took place \(error)")
                     semaphore.signal()

                     return
                 }
          
                 // Convert HTTP Response Data to a String
                 if let data = data, let dataString = String(data: data, encoding: .utf8) {
                     print("Append Response data string:\n \(dataString)")
                     print("Append Response resp string:\n \(response?.description)")
                     
                     semaphore.signal()


                 }
         }
         task.resume()
            
        semaphore.wait()

        
    }
    
    func uploadFinalize(mediaId:String) {
        
      
            
            let headers = [("Accept", "*/*"), ("Host", "upload.twitter.com"), ("Content-Type", "application/x-www-form-urlencoded"), ("Authorization", createOAuthHeader(params:[("command", "FINALIZE"), ("media_id", mediaId)], url:"https://upload.twitter.com/1.1/media/upload.json", apiKey:apiKey, apiSecret:apiSecret, accessToken:accessToken, accessTokenSecret:accessTokenSecret, nonce:getOauthNonce(), timestamp:getOauthTimestamp(), method:"Post"))]


        let urlString = "https://upload.twitter.com/1.1/media/upload.json?command=FINALIZE&media_id=" + mediaId
        let url = URL(string:urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"


         for (index, (key, value)) in headers.enumerated() {
             request.addValue(value, forHTTPHeaderField: key)
         }
        
        
        request.log();
       let semaphore = DispatchSemaphore(value: 0)

        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    semaphore.signal()

                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Finalize Response data string:\n \(dataString)")
                    print("FInalise Response resp string:\n \(response?.description)")
                    
                    semaphore.signal()


                }
        }
        task.resume()
           
       semaphore.wait()
        
        
        
        
    }
    
    fileprivate func stringToData(string: String) -> Data {
        return string.data(using: .utf8) ?? NSMutableData() as Data;
    }
    
    func generateMultipartBody(params:[(String, Data)], boundary:String) -> Data {
        
        
        
        let part = NSMutableData();
        for (_, (name, value)) in params.enumerated() {
            part.append(stringToData(string:"--"));
            part.append(stringToData(string:boundary));
            part.append(stringToData(string:"\r\nContent-Disposition: form-data; name=\""));
            part.append(stringToData(string:name));
            part.append(stringToData(string:"\""));

            if (name == "media") {
                part.append(stringToData(string:"; filename=\"foo1.png\"\nContent-Type: application/octet-stream"))
            }
            
            part.append(stringToData(string:"\r\n\r\n"));
           
            part.append(value);
               
            part.append(stringToData(string:"\r\n"));
            NSLog("PART %d", value.count);
        }
        
        part.append(stringToData(string:"--"));
        part.append(stringToData(string:boundary));
        part.append(stringToData(string:"--\r\n"));
       
        return part as Data;

        
        
        
    }

    
    func uploadInit(image:Data) -> String {
        let totalBytes =  String(image.count)

            
            let headers = [("Accept", "*/*"),
                ("Host","upload.twitter.com"),
                ("Content-Type","application/x-www-form-urlencoded"),
                ("Authorization", createOAuthHeader(params: [("command", "INIT"),
                                                             ("total_bytes", totalBytes),
                                                             ("media_type", "img/png")], url: "https://upload.twitter.com/1.1/media/upload.json", apiKey: apiKey, apiSecret: apiSecret, accessToken: accessToken, accessTokenSecret: accessTokenSecret, nonce: getOauthNonce(), timestamp: getOauthTimestamp(), method: "Post"))]
            
        
        if (uploadUrl.count > 0) {
            return "FAKE-MEDIA-ID";
        }
        
        let url = URL(string: "https://upload.twitter.com/1.1/media/upload.json?command=INIT&total_bytes=" + totalBytes  + "&media_type=img%2Fpng")!
        
        
        
        var request = URLRequest(url: url)
        request.log()
        for (index, (key, value)) in headers.enumerated() {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
       request.httpMethod = "POST"
        
        
        var mediaId=""
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Init Response data string:\n \(dataString)")
                    mediaId =  self.handleMediaResponse(json:dataString)
                }
        }
        task.resume()
        while (mediaId == "") {
            //di i need this?/
        }
        return mediaId
    }
        
    
    func handleMediaResponse(json:String) -> String {
       
        let jsonObj = try? JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any]
        return jsonObj?["media_id_string"] as! String
        
    }
   
        
    func addAltText(mediaId:String, altText:String) {
       let json = "{\"media_id\":\"" + mediaId + "\", \"alt_text\": {\"text\":\"" + altText + "\"}}"
    
        let headers =  [("Accept", "*/*"),
            ("Host","upload.twitter.com"),
            ("Content-Type","application/json"),
            ("Authorization",
             createOauthHeaderWithBody(body:json,
                                       url: "https://upload.twitter.com/1.1/media/metadata/create.json",
                                       apiKey:apiKey,
                                       apiSecret:apiSecret,
                                       accessToken: accessToken,
                                       accessTokenSecret:accessTokenSecret,
                                       nonce:"getOauthNonce()",
                                       timestamp:"getOauthTimestamp()",
                                       method:"Post")),
                        ("Content-Length", String(json.utf8.count))]
         
       let url = URL(string:"https://upload.twitter.com/1.1/media/metadata/create.json")
        var request = URLRequest(url: url!)
        

        for (index, (key, value)) in headers.enumerated() {
            request.addValue(value, forHTTPHeaderField: key)
        }
            
        request.httpMethod = "POST"
        request.httpBody = Data(json.utf8)

        request.log();
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("alt Response data string:\n \(dataString)")
                }
        }
        task.resume()
    }
    
    func createOauthHeaderWithBody(body: String, url: String, apiKey: String, apiSecret: String, accessToken: String, accessTokenSecret: String, nonce: String, timestamp: String, method: String) -> String {
            
             
        let oauthSignatureMethod="HMAC-SHA1"
        let oauthVersion="1.0"
        let oauthParameters=[("oauth_body_hash", Data(Insecure.SHA1.hash(data:Data(body.utf8))).base64EncodedString()),
                       ("oauth_consumer_key", apiKey),
                       ("oauth_nonce", nonce),
                       ("oauth_signature_method", oauthSignatureMethod),
                       ("oauth_timestamp", timestamp),
                       ("oauth_token", accessToken),
                       ("oauth_version", oauthVersion)]
                              
                              
                let signingParameters = oauthParameters
                let oauthSignature=sign(parameters: signingParameters, url: url, consumerSecret: apiSecret, oauthTokenSecret: accessTokenSecret, httpMethod: method)
                let signedOauthParameters = oauthParameters  + [("oauth_signature", oauthSignature)]
                return createOauthHeaderString(signedOauthParameters: signedOauthParameters)
    }
                 
             
    func createOAuthHeader(params: [(String,String)], url: String, apiKey: String, apiSecret: String, accessToken: String, accessTokenSecret: String, nonce: String, timestamp: String, method: String) -> String {
        
        
        let oauthSignatureMethod="HMAC-SHA1"
        let oauthVersion="1.0"
        let oauthParameters=[("oauth_consumer_key", apiKey),
                       ("oauth_nonce", nonce),
                       ("oauth_signature_method", oauthSignatureMethod),
                       ("oauth_timestamp", timestamp),
                       ("oauth_token", accessToken),
                       ("oauth_version", oauthVersion)]
              
        let signingParameters = oauthParameters + params
        let oauthSignature=sign(parameters: signingParameters, url: url, consumerSecret: apiSecret, oauthTokenSecret: accessTokenSecret, httpMethod: method)
        let signedOauthParameters = oauthParameters  + [("oauth_signature", oauthSignature)]
        return createOauthHeaderString(signedOauthParameters: signedOauthParameters)
        
        
        
        
    }
    /**
     Encode and concatenate the OAuth parameters into the OAuth headers string
     */
    func createOauthHeaderString(signedOauthParameters:[(String, String)]) -> String {
        let encodedParameters = encodeParameters(parameters:signedOauthParameters)
        
        let sortedEncodedParameters = sortParameters(parameters:encodedParameters)
         var header = "OAuth "
        for (index, (key, value)) in sortedEncodedParameters.enumerated() {
            header+=(key + "=\"" + value + "\"")
            if (index < (sortedEncodedParameters.count - 1)) {
                header+=", "
            }
        }
            
            return header
    
    }
    
    func sign(parameters:[(String, String)], url: String, consumerSecret: String, oauthTokenSecret: String, httpMethod: String) -> String {
        let parameterString=createParameterString(parameters:parameters)
        let signatureBaseString=createSignatureBaseString(parameterString:parameterString, url:url,  httpMethod:httpMethod)
        
        // should return data protocol
        let signingKey=getSigningKey(consumerSecret:consumerSecret,  oauthTokenSecret:oauthTokenSecret)
        
        let hmac = HMAC<Insecure.SHA1>.authenticationCode(
            for: Data(signatureBaseString.utf8),
            using: SymmetricKey.init(data:Data(signingKey.utf8)))
        return Data(hmac).base64EncodedString() //no fucking idea if this works or not
    }
    
    func createSignatureBaseString(parameterString:String, url:String,  httpMethod:String) -> String {
        return httpMethod.uppercased() + "&" + escapeUri(uri:url) +  "&" + escapeUri(uri:parameterString)
    }
        
    
    func getSigningKey(consumerSecret: String,  oauthTokenSecret: String) -> String { return escapeUri(uri:consumerSecret) +  "&" + escapeUri(uri:oauthTokenSecret)
    }

        func createParameterString(parameters:[(String, String)]) -> String {
            
            let encodedParameters=encodeParameters(parameters:parameters)
            let sortedEncodedParameters=sortParameters(parameters:encodedParameters)
            
            var parameterString=""
         
            for (index, (key, value)) in sortedEncodedParameters.enumerated() {
                parameterString+=key + "=" + value
                if (index < (parameters.count - 1)) {
                    parameterString+="&"
                }
            }
            return parameterString
        }
        
    
    
    func escapeUri(uri:String)->String {
        
        var twitterCharacterSet = CharacterSet.urlQueryAllowed
        twitterCharacterSet.remove(charactersIn: "+!,&=:/'")
        return uri.addingPercentEncoding(withAllowedCharacters: twitterCharacterSet)!
    }
    
    
        func encodeParameters(parameters:[(String, String)])->[(String, String)] {
            var encodedParamters: [(String, String)] =  [];
            
            for (key, value) in parameters {
                encodedParamters.append((escapeUri(uri:key), escapeUri(uri:value)))
            }
            return encodedParamters;
        }
        
        
        func sortParameters(parameters:[(String, String)])->[(String, String)] {
            return parameters.sorted(by:{$0.0 < $1.0 })
        }

        
    
    func getOauthNonce()->String {
        return UUID().uuidString
    }
    
    func getOauthTimestamp() -> String {
        let seconds = NSDate().timeIntervalSince1970
        let longSeconds = CUnsignedLongLong(seconds)
        return String(longSeconds)
        
    }
    
    
    func headersDict(parameters:[(String, String)]) -> [String: String] {
        var headersDict = [String: String]();
        
        for (key, value) in parameters {
            headersDict.updateValue(value, forKey: key);
        }
        
        return headersDict;
    }
    
    

    
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension URLRequest {
    func log() {
        print("\(httpMethod ?? "") \(self)")
        print("BODY \n \(httpBody?.toString())")
        print("HEADERS \n \(allHTTPHeaderFields)")
    }
}
