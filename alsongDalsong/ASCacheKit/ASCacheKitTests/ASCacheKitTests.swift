@testable import ASCacheKit
import ASCacheKitProtocol
import Testing
import UIKit

struct ASCacheKitTests {
    private var cacheManager = ASCacheManager(memoryCache: MockMemoryCacheManager(), diskCache: MockDiskCacheManager(), session: MockURLSession())
    let testData = UIImage(systemName: "star")!.pngData()!
    let testImageURL = URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUcmUojj8oZ0EzJU027Pul8SpM6ZMxr8HXAgsuunxkFZKSW7K27kLqcsoRaWaEX03kmQg&usqp=CAU")!

    @Test func 디스크에_없는_캐시_로딩() async throws {
        MockURLSession.testData = testData

        let cachedData = await cacheManager.loadCache(from: testImageURL, cacheOption: .onlyDisk)
        let diskData = cacheManager.diskCache.getData(forKey: testImageURL.absoluteString)
        let memoryData = cacheManager.memoryCache.getObject(forKey: testImageURL.absoluteString)

        #expect(cachedData == nil)
        #expect(diskData == nil)
        #expect(memoryData == nil)
    }

    @Test func 디스크에_있는_캐시_로딩() async throws {
        MockURLSession.testData = testData

        _ = await cacheManager.loadCache(from: testImageURL, cacheOption: .both)
        let cachedData = await cacheManager.loadCache(from: testImageURL, cacheOption: .onlyDisk)
        let diskData = cacheManager.diskCache.getData(forKey: testImageURL.absoluteString)

        #expect(cachedData != nil)
        #expect(diskData != nil)
    }

    @Test func 메모리에_없는_캐시_로딩() async throws {
        MockURLSession.testData = testData

        _ = await cacheManager.loadCache(from: testImageURL, cacheOption: .onlyMemory)
        let memoryData = cacheManager.memoryCache.getObject(forKey: testImageURL.absoluteString)

        #expect(memoryData == nil)
    }

    @Test func 메모리에_있는_캐시_로딩() async throws {
        MockURLSession.testData = testData

        _ = await cacheManager.loadCache(from: testImageURL, cacheOption: .both)
        let cachedData = await cacheManager.loadCache(from: testImageURL, cacheOption: .onlyMemory)
        let memoryData = cacheManager.memoryCache.getObject(forKey: testImageURL.absoluteString)

        #expect(cachedData != nil)
        #expect(memoryData != nil)
    }
}
