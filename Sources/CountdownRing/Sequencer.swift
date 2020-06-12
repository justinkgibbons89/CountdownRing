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
    
	/// Begins to move through the sequence of transformations.
    public func move(_ interval: TimeInterval = 0.3, runLoop: RunLoop = .current) {
        
        /// Execute first transfomation immediately
        if self.sequence.isEmpty { self.stop(); return }
        self.sequence.removeFirst()()
        
        /// Create timer
        timer = Timer.publish(every: interval, on: .current, in: .common)
        
        /// Subscribe to updates, fire transformations
        timer.sink { _ in
            if self.sequence.isEmpty { self.stop(); return }
            self.sequence.removeFirst()()
        }.store(in: &cancellables)
        
        /// Connect
        timer.connect().store(in: &cancellables)
    }
    
	/// Stops the transformations and cancels all the subscribers.
    private func stop() {
        cancellables.forEach { $0.cancel() }
        sequence.removeAll()
    }
}

