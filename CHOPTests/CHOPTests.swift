import XCTest
@testable import CHOP

final class CHOPTests: XCTestCase {

    func testWoodTypeBasePoints() {
        XCTAssertEqual(WoodType.soft.basePoints, 10)
        XCTAssertEqual(WoodType.medium.basePoints, 15)
        XCTAssertEqual(WoodType.hard.basePoints, 25)
    }

    func testWoodTypeSellPrice() {
        XCTAssertEqual(WoodType.soft.sellPrice, 2)
        XCTAssertEqual(WoodType.medium.sellPrice, 4)
        XCTAssertEqual(WoodType.hard.sellPrice, 8)
    }

    func testAxeTierPricing() {
        XCTAssertEqual(AxeTier.basic.price, 150)
        XCTAssertEqual(AxeTier.mid.price, 400)
        XCTAssertEqual(AxeTier.premium.price, 800)
        XCTAssertEqual(AxeTier.master.price, 1500)
    }

    func testOwnedAxeCreation() {
        let axe = OwnedAxe.create(type: .balanced, tier: .basic)
        XCTAssertEqual(axe.type, .balanced)
        XCTAssertEqual(axe.tier, .basic)
        XCTAssertFalse(axe.isBroken)
        XCTAssertFalse(axe.isDiamond)
    }

    func testDiamondAxeNeverBreaks() {
        let axe = OwnedAxe.create(type: .diamond, tier: .diamond)
        XCTAssertTrue(axe.isDiamond)
        XCTAssertEqual(axe.maxDurability, Int.max)
    }

    func testInventoryAddWood() {
        var inventory = Inventory.initial
        inventory.addWood(.soft, count: 10)
        XCTAssertEqual(inventory.wood[.soft], 10)
    }

    func testFurnaceTierSlots() {
        XCTAssertEqual(FurnaceTier.stoneHearth.maxSlots, 1)
        XCTAssertEqual(FurnaceTier.brickFurnace.maxSlots, 2)
        XCTAssertEqual(FurnaceTier.ironClad.maxSlots, 2)
        XCTAssertEqual(FurnaceTier.greatForge.maxSlots, 3)
    }
}
