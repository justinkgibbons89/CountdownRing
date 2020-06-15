import Foundation
import Combine

/// Manages and moves through a sequence of timed state transformations.
@available(macOS 10.15, iOS 13, watchOS 6, *)
public class Sequencer {
	
	//MARK: Properties
	private var sequence: [() -> Void] = []
	private var cancellables = [AnyCancellable]()
	private var timer: Timer.TimerPublisher!
	
	//MARK: Initialization
	public init() {}
	
	//MARK: Controls
	/// Adds a transformation to the sequence.
	public func add(_ transformation: @escaping () -> Void) {
		sequence.append(transformation)
	}
	
	/// Moves through the sequence of transformations and stops when there
	/// are none remaining.
	/// - Parameters:
	///   - interval: The time to wait between transformations in the sequence, measured in seconds.
	///   - runLoop: The run loop the underlying timer should be attached to.
	public func move(_ interval: TimeInterval = 0.3, runLoop: RunLoop = .current) {
		
		/// Stop if the sequence is empty
		if self.sequence.isEmpty { self.stop(); return }
		
		/// Execute first transfomation immediately
		self.performNext()
		
		/// Create timer
		timer = Timer.publish(every: interval, on: .current, in: .common)
		
		/// Subscribe to updates, fire transformations
		timer.sink { _ in
			/// Stop if empty
			if self.sequence.isEmpty { self.stop(); return }
			
			/// Execute transformation
			self.performNext()
		}
		.store(in: &cancellables)
		
		/// Connect
		timer.connect().store(in: &cancellables)
	}
	
	/// Perform the next transformation in the sequence.
	///
	/// Performing a transformation consumes it. Successive calls to this method will iterate through the sequence until it's empty. Check
	/// to make sure the `sequence` collection is not empty before calling this.
	private func performNext() {
		let perform = sequence.removeFirst()
		perform()
	}
	
	/// Stops the transformations and cancels all the subscribers.
	private func stop() {
		cancellables.forEach { $0.cancel() }
		sequence.removeAll()
	}
}

