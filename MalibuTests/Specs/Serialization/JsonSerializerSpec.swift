@testable import Malibu
import Quick
import Nimble

class JsonSerializerSpec: QuickSpec {

  override func spec() {
    describe("JsonSerializer") {
      var serializer: JsonSerializer!
      let url = URL(string: "http://api.loc")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!

      beforeEach {
        serializer = JsonSerializer()
      }

      describe("#init") {
        it("sets default options") {
          expect(serializer.options).to(equal(JSONSerialization.ReadingOptions.allowFragments))
        }

        it("sets parameter options to the instance var") {
          serializer = JsonSerializer(options: .mutableContainers)
          expect(serializer.options).to(equal(JSONSerialization.ReadingOptions.mutableContainers))
        }
      }

      describe("#serialize:data") {
        context("when there is no data in response") {
          it("throws an error") {
            let data = Data()
            expect{ try serializer.serialize(data: data, response: response) }.to(throwError(NetworkError.noDataInResponse))
          }
        }

        context("when the data will not produce valid JSON") {
          it("throws an error") {
            let data = "ff^%^$".data(using: String.Encoding.utf8)!
            expect{ try serializer.serialize(data: data, response: response) }.to(throwError())
          }
        }

        context("when response status code is 204 No Content") {
          it("does not throw an error and returns NSNull") {
            let response = HTTPURLResponse(url: url, statusCode: 204,
              httpVersion: "HTTP/2.0", headerFields: nil)!
            let data = Data()
            var result: Any?

            expect{ result = try serializer.serialize(data: data, response: response) }.toNot(throwError())
            expect(result is NSNull).to(beTrue())
          }
        }

        context("when serialization succeeded") {
          it("does not throw an error and returns result") {
            let dictionary = ["name": "Taylor"]
            let data = try! JSONSerialization.data(withJSONObject: dictionary,
              options: JSONSerialization.WritingOptions())
            var result: Any?

            expect{ result = try serializer.serialize(data: data, response: response) }.toNot(throwError())
            expect(result as? [String: String]).to(equal(dictionary))
          }
        }
      }
    }
  }
}
