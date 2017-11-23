//
//  GetPatchesResponse.swift
//  Glancer
//
//  Created by Dylan Hanson on 11/3/17.
//  Copyright © 2017 BB&N. All rights reserved.
//

import Foundation
import Unbox

struct GetPatchResponse: WebCallResult
{
	var blocks: [GetPatchResponseBlock]
	
	init(unboxer: Unboxer) throws
	{
		self.blocks = try unboxer.unbox(keyPath: "schedule.blocks", allowInvalidElements: false)
	}
}

struct GetPatchResponseBlock: WebCallResult
{
	var blockId: String
	var startTime: String
	var endTime: String
	
	var variation: Int?
	
	init(unboxer: Unboxer) throws
	{
		self.blockId = try unboxer.unbox(key: "blockId")
		self.startTime = try unboxer.unbox(key: "startTime")
		self.endTime = try unboxer.unbox(key: "endTime")
		
		self.variation = unboxer.unbox(key: "variation")
	}
}
