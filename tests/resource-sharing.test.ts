import { describe, it, beforeEach, expect } from "vitest"

describe("Resource Sharing Contract", () => {
  let mockStorage: Map<string, any>
  
  beforeEach(() => {
    mockStorage = new Map()
  })
  
  const mockContractCall = (method: string, args: any[], sender: string) => {
    switch (method) {
      case "update-resources":
        const [robotId, energy, data] = args
        const currentResources = mockStorage.get(`resources-${robotId}`) || { energy: 0, data: [] }
        mockStorage.set(`resources-${robotId}`, {
          energy,
          data: [...currentResources.data, data].slice(-10),
        })
        return { success: true }
      
      case "share-energy":
        const [fromRobot, toRobot, amount] = args
        const fromResources = mockStorage.get(`resources-${fromRobot}`)
        const toResources = mockStorage.get(`resources-${toRobot}`)
        if (!fromResources || !toResources) return { success: false, error: 404 }
        if (fromResources.energy < amount) return { success: false, error: 401 }
        fromResources.energy -= amount
        toResources.energy += amount
        return { success: true }
      
      case "share-data":
        const [dataFromRobot, dataToRobot, sharedData] = args
        const dataToResources = mockStorage.get(`resources-${dataToRobot}`)
        if (!dataToResources) return { success: false, error: 404 }
        if (dataToResources.data.length >= 10) return { success: false, error: 401 }
        dataToResources.data.push(sharedData)
        return { success: true }
      
      case "get-resources":
        return { success: true, value: mockStorage.get(`resources-${args[0]}`) }
      
      default:
        return { success: false, error: "Unknown method" }
    }
  }
  
  it("should update resources", () => {
    const result = mockContractCall("update-resources", [1, 100, "New data"], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should share energy", () => {
    mockContractCall("update-resources", [1, 100, "Data 1"], "user1")
    mockContractCall("update-resources", [2, 50, "Data 2"], "user2")
    const result = mockContractCall("share-energy", [1, 2, 30], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should share data", () => {
    mockContractCall("update-resources", [1, 100, "Data 1"], "user1")
    mockContractCall("update-resources", [2, 50, "Data 2"], "user2")
    const result = mockContractCall("share-data", [1, 2, "Shared data"], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should get resources", () => {
    mockContractCall("update-resources", [1, 100, "Data 1"], "user1")
    const result = mockContractCall("get-resources", [1], "anyone")
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      energy: 100,
      data: ["Data 1"],
    })
  })
})

