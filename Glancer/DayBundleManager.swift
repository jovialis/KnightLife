//
//  DayBundleManager.swift
//  Glancer
//
//  Created by Dylan Hanson on 7/28/18.
//  Copyright © 2018 Dylan Hanson. All rights reserved.
//

import Foundation
import AddictiveLib

class DayBundleManager: Manager {
	
	static let instance = DayBundleManager()
	
	private var bundleWatcher: [String: ResourceWatcher<DayBundle>] = [:]
	
	init() {
		super.init("Bundle")
	}
	
	private func registerListeners(date: Date) {
//		These just listen for new data from each of the three points, then reloads that date's respective bundle.
		
		ScheduleManager.instance.getPatchWatcher(date: date).onSuccess(self) {
			schedule in
			
//			Have Schedule, fetch lunch and events.
//			Perform a chain to get the menu for each of the other ones, then update the corresponding watcher so that everything gets sent to everything else.
			ProcessChain().link() {
				chain in
				
				LunchManager.instance.fetchLunchMenu(date: date) {
					result in
					
					switch result {
					case .success(let result):
						chain.setData("menu", data: result)
						chain.next()
					case .failure(let error):
						chain.setData("error", data: error)
						chain.next(false)
					}
				}
			}.link() {
				chain in
				
				EventManager.instance.getEvents(date: date) {
					result in
					
					switch result {
					case .success(let result):
						chain.setData("events", data: result)
						chain.next()
					case .failure(let error):
						chain.setData("error", data: error)
						chain.next(false)
					}
				}
			}.success() {
				chain in
				
				let bundle = DayBundle(date: date, schedule: schedule, events: chain.getData("events")!, menu: chain.getData("menu")!)
				self.getBundleWatcher(date: date).handle(nil, bundle)
			}.failure() {
				chain in
				
				self.getBundleWatcher(date: date).handle(chain.getData("error"), nil)
			}.start()
		}
		
		ScheduleManager.instance.getPatchWatcher(date: date).onFailure(self) {
			error in
			
//			Flame out bundle on failure
			self.getBundleWatcher(date: date).handle(error, nil)
		}
		
		LunchManager.instance.getLunchWatcher(date: date).onSuccess(self) {
			menu in
			
//			Have Menu, fetch schedule and events.
//			Perform a chain to get the menu for each of the other ones, then update the corresponding watcher so that everything gets sent to everything else.
			ProcessChain().link() {
				chain in
				
				ScheduleManager.instance.loadSchedule(date: date) {
					result in
					
					switch result {
					case .success(let result):
						chain.setData("schedule", data: result)
						chain.next()
					case .failure(let error):
						chain.setData("error", data: error)
						chain.next(false)
					}
				}
			}.link() {
				chain in
				
				EventManager.instance.getEvents(date: date) {
					result in
					
					switch result {
					case .success(let result):
						chain.setData("events", data: result)
						chain.next()
					case .failure(let error):
						chain.setData("error", data: error)
						chain.next(false)
					}
				}
			}.success() {
				chain in
				
				let bundle = DayBundle(date: date, schedule: chain.getData("schedule")!, events: chain.getData("events")!, menu: menu)
				self.getBundleWatcher(date: date).handle(nil, bundle)
			}.failure() {
				chain in
				
				self.getBundleWatcher(date: date).handle(chain.getData("error"), nil)
			}.start()
		}
		
		LunchManager.instance.getLunchWatcher(date: date).onFailure(self) {
			error in
			
			self.getBundleWatcher(date: date).handle(error, nil)
		}
		
		EventManager.instance.getEventWatcher(date: date).onSuccess(self) {
			events in
			
			//			Have Schedule, fetch lunch and events.
			//			Perform a chain to get the menu for each of the other ones, then update the corresponding watcher so that everything gets sent to everything else.
			ProcessChain().link() {
				chain in
				
				LunchManager.instance.fetchLunchMenu(date: date) {
					result in
					
					switch result {
					case .success(let result):
						chain.setData("menu", data: result)
						chain.next()
					case .failure(let error):
						chain.setData("error", data: error)
						chain.next(false)
					}
				}
			}.link() {
				chain in
				
				ScheduleManager.instance.loadSchedule(date: date) {
					result in
					
					switch result {
					case .success(let result):
						chain.setData("schedule", data: result)
						chain.next()
					case .failure(let error):
						chain.setData("error", data: error)
						chain.next(false)
					}
				}
			}.success() {
				chain in
				
				let bundle = DayBundle(date: date, schedule: chain.getData("schedule")!, events: events, menu: chain.getData("menu")!)
				self.getBundleWatcher(date: date).handle(nil, bundle)
			}.failure() {
				chain in
				
				self.getBundleWatcher(date: date).handle(chain.getData("error"), nil)
			}.start()
		}
		
		EventManager.instance.getEventWatcher(date: date).onFailure(self) {
			error in
			
			self.getBundleWatcher(date: date).handle(error, nil)
		}
	}
	
	func getBundleWatcher(date: Date) -> ResourceWatcher<DayBundle> {
		if self.bundleWatcher[date.webSafeDate] == nil {
			self.bundleWatcher[date.webSafeDate] = ResourceWatcher<DayBundle>()
		}
		return self.bundleWatcher[date.webSafeDate]!
	}
	
	func getDayBundle(date: Date, then: @escaping (Bool) -> Void = {_ in}) {
		ProcessChain().link() {
			chain in
			
			ScheduleManager.instance.loadSchedule(date: date) {
				result in
				
				switch result {
				case .success(let schedule):
					chain.setData("schedule", data: schedule)
					chain.next()
				case .failure(let error):
					chain.setData("error", data: error)
					chain.next(false)
				}
			}
		}.link() {
			chain in
			
			EventManager.instance.getEvents(date: date) {
				result in
				
				switch result {
				case .success(let events):
					chain.setData("events", data: events)
					chain.next()
				case .failure(let error):
					chain.setData("error", data: error)
					chain.next(false)
				}
			}
		}.link() {
			chain in
			
			LunchManager.instance.fetchLunchMenu(date: date) {
				result in
				
				switch result {
				case .success(let lunch):
					chain.setData("lunch", data: lunch)
					chain.next()
				case .failure(let error):
					chain.setData("error", data: error)
					chain.next(false)
				}
			}
		}.success() {
			chain in
			
			let bundle = DayBundle(date: date, schedule: chain.getData("schedule")!, events: chain.getData("events")!, menu: chain.getData("lunch")!)
			self.getBundleWatcher(date: date).handle(nil, bundle)
			
			self.registerListeners(date: date)
			
			then(true)
		}.failure() {
			chain in
			self.getBundleWatcher(date: date).handle(chain.getData("error"), nil)
			
			self.registerListeners(date: date)
			
			then(false)
		}.start()
	}
	
}