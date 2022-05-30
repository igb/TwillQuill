//
//  TwillTests.swift
//  TwillTests
//
//  Created by Ian Brown on 5/27/22.
//

import XCTest
@testable import Twill

class TwillTests: XCTestCase {
    


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /**
     Test underlying sorting implementation.
     */
    func testParamterSorting() throws {
        let twitter = TwitterClient()
        let unsorted = [("foo", "bar"),
                        ("zed", "bing"),
                        ("moof", "clarus"),
                        ("aaa", "zool")]
        
        let sorted = [("aaa", "zool"),
                      ("foo", "bar"),
                      ("moof", "clarus"),
                      ("zed", "bing")]
        
        let tsorted = twitter.sortParameters(parameters: unsorted);
        for (index, (key, _)) in tsorted.enumerated() {
            let (sortedKey, _) = sorted[index]
            XCTAssertEqual(key, sortedKey)
        }
    }
    
    /**
     Tests the conversion of a string to a URL encoded string.
     */
    func testEscapeUri () throws {
        
        
        let twitter = TwitterClient()
        XCTAssertEqual(twitter.escapeUri(uri: "Hello Ladies + Gentlemen, a signed OAuth request!"),
"Hello%20Ladies%20%2B%20Gentlemen%2C%20a%20signed%20OAuth%20request%21")
        XCTAssertEqual(twitter.escapeUri(uri: "1.0&status="),
"1.0%26status%3D")
        XCTAssertEqual(twitter.escapeUri(uri:"https://api.twitter.com/1/statuses/update.json"), "https%3A%2F%2Fapi.twitter.com%2F1%2Fstatuses%2Fupdate.json")
    }
    

    /**
     Tests the creation of a paramter string from an alist of parameters
     */
    func testCreateParameterString() throws {
        let twitter = TwitterClient()
        XCTAssertEqual(twitter.createParameterString(parameters:getTestParameters()),
    "include_entities=true&oauth_consumer_key=xvz1evFS4wEEPTGEFPHBog&oauth_nonce=kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1318622958&oauth_token=370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb&oauth_version=1.0&status=Hello%20Ladies%20%2B%20Gentlemen%2C%20a%20signed%20OAuth%20request%21")
    }

    /**
     Tests the composition of the signature base string for OAuth.
     */
    func testCreateSignatureBase () throws {
        let twitter = TwitterClient()
        XCTAssertEqual(twitter.createSignatureBaseString(parameterString:twitter.createParameterString(parameters:getTestParameters()), url: "https://api.twitter.com/1/statuses/update.json", httpMethod:"post"),"POST&https%3A%2F%2Fapi.twitter.com%2F1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521")
    }
    
    /**
     Tests the concatenation and creation of the signing key from it's constotuent parts.
     */
    func testGetSigningKey() throws {
        let twitter = TwitterClient()
        XCTAssertEqual(twitter.getSigningKey(consumerSecret: "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw", oauthTokenSecret: "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"), "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE")
    }


    /**
     Tests the construction of the OAuth HTTP Header value string syntax.
     */
    func testCreateOauthHeaderString() throws {
        let twitter = TwitterClient();
        XCTAssertEqual(twitter.createOauthHeaderString(signedOauthParameters:[("foo","bar"), ("bing","bat")]),
        "OAuth bing=\"bat\", foo=\"bar\"")
    }
    
    /**
     "Tests the construction and signing of the OAuth HTTP Header value."
  
     */
     func testCreateOauthHeader()  throws {
        let twitter = TwitterClient()
         
      let requestParameters=[("include_entities", "true"),
                     ("status", "Hello Ladies + Gentlemen, a signed OAuth request!")]
      let url="https://api.twitter.com/1/statuses/update.json"
      let consumerKey="xvz1evFS4wEEPTGEFPHBog"
      let consumerSecret="kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw"
      let oauthToken="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb"
      let oauthTokenSecret="LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
      let oauthNonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"
      let oauthTimestamp="1318622958"
      let httpMethod="Post"
         
         let oauthHeader=twitter.createOAuthHeader(params: requestParameters, url: url, apiKey: consumerKey, apiSecret: consumerSecret, accessToken: oauthToken, accessTokenSecret: oauthTokenSecret, nonce: oauthNonce, timestamp: oauthTimestamp, method: httpMethod)
         
       
      XCTAssertEqual(oauthHeader, "OAuth oauth_consumer_key=\"xvz1evFS4wEEPTGEFPHBog\", oauth_nonce=\"kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg\", oauth_signature=\"tnnArxj06cWHq44gCs1OSKk%2FjLY%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"1318622958\", oauth_token=\"370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb\", oauth_version=\"1.0\"")
     }
          

    func testMediaResponse() throws {
        let jsonResponse = """
       {
        \"media_id\": 710511363345354753,
        \"media_id_string\": \"710511363345354753\",
        \"media_key\": \"3_710511363345354753\",
        \"size\": 11065,
        \"expires_after_secs\": 86400,
        \"image\": {
          \"image_type\": \"image/jpeg\",
          \"w\": 800,
          \"h\": 320
        }
       }
"""
        
        
        let twitter = TwitterClient()
        
        
        XCTAssertEqual("710511363345354753", twitter.handleMediaResponse(json: jsonResponse))
        
    }
    
    
    
    
    func testOauthSign() throws {
        
        let params = [("include_entities", "true"), ("status", "Hello Ladies + Gentlemen, a signed OAuth request!")] // do i need to add include_entities?
        let url="https://api.twitter.com/1/statuses/update.json"
        let consumerKey="xvz1evFS4wEEPTGEFPHBog"
        let consumerSecret="kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw"
        let oauthToken="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb"
        let oauthTokenSecret="LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
        let oauthNonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"
        let oauthTimestamp="1318622958"
        let httpMethod="Post"
        
        
        
        let twitter = TwitterClient()
       
       let foo =  twitter.createOAuthHeader(params:params, url: url, apiKey: consumerKey, apiSecret: consumerSecret, accessToken: oauthToken, accessTokenSecret: oauthTokenSecret, nonce: oauthNonce, timestamp: oauthTimestamp, method:httpMethod)
        
        let oauth = "OAuth oauth_consumer_key=\"xvz1evFS4wEEPTGEFPHBog\", oauth_nonce=\"kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg\", oauth_signature=\"tnnArxj06cWHq44gCs1OSKk%2FjLY%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"1318622958\", oauth_token=\"370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb\", oauth_version=\"1.0\""
        
        
              XCTAssertEqual(foo, oauth)
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    
    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    func getTestParameters()->[(String, String)] {
        return [("include_entities","true"),
          ("status", "Hello Ladies + Gentlemen, a signed OAuth request!"),
          ("oauth_consumer_key","xvz1evFS4wEEPTGEFPHBog"),
          ("oauth_nonce","kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"),
          ("oauth_signature_method","HMAC-SHA1"),
          ("oauth_timestamp","1318622958"),
          ("oauth_token","370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb"),
          ("oauth_version","1.0")]
    }

}
