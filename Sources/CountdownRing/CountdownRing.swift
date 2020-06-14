import SwiftUI

/// An animated countdown ring, similar to the one used in Apple Workouts on watchOS.
@available(macOS 10.15, iOS 13, watchOS 6, *)
public struct CountdownRing: View {
	
	//MARK: Properties
	public var strokeWidthMultiplier: CGFloat = 1
	public var strokeWidthDivisorConstant: CGFloat = 10
	public var colors: [Color] 
	public var textColors: [Color]
	public var ringAnimation: Animation
	public var countdownInterval: TimeInterval
	
	/// This sequencer will manage the state transformations that will drive
	/// the countdown animations.
	private var sequencer = Sequencer()
	
	//MARK: Data Sources
	@State private var degrees: Double = 1
	@State private var count: String = "Ready"
	@State private var alpha: Double = 1
	@State private var textFactor: CGFloat = 0.5
	@State private var shrinkMultiplier: CGFloat = 1
	@Binding private var countdownFinished: Bool
	
	//MARK: Initialization
	public init(isFinished: Binding<Bool>? = nil, ringColors: [Color], widthMultiplier: CGFloat = 1, textColors: [Color] = [.white, .white], ringAnimation: Animation = .interpolatingSpring(stiffness: 20, damping: 10, initialVelocity: 6), countdownInterval: TimeInterval = 1) {
		self.strokeWidthMultiplier = widthMultiplier
		self.colors = ringColors
		self.textColors = textColors
		self.ringAnimation = ringAnimation
		self.countdownInterval = countdownInterval
		
		if let isFinished = isFinished {
			self._countdownFinished = isFinished
		} else {
			/// Create a empty placeholder binding if one wasn't passed in
			self._countdownFinished = Binding<Bool>(get: { return false }, set: { _ in })
		}
	}
	
	//MARK: Properties
	private var gradient: LinearGradient {
		LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .topLeading, endPoint: .bottomTrailing)
	}
	
	public var body: some View {
		GeometryReader { geo in
			ZStack {
				/// This is the middle countdown text.
				LinearGradient(
					gradient: Gradient(colors: self.textColors),
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
					.mask(
						Text(self.count)
							.font(Font.system(size: geo.size.width / 3 * self.textFactor))
							.minimumScaleFactor(0.5)
							.frame(width: geo.size.width / 1.5, height: nil, alignment: .center)
				)
					.opacity(self.alpha)
				
				/// This is the faded background ring.
				Ring(
					degrees: 360,
					radius: geo.size.height,
					inset: self.strokeWidth(for: geo) / 2
				)
					.stroke(
						self.gradient,
						style: self.strokeStyle(for: geo)
				)
					.opacity(0.25)
				
				/// This is the full color foreground ring.
				Ring(
					degrees: self.degrees,
					radius: geo.size.height,
					inset: self.strokeWidth(for: geo) / 2
				)
					.stroke(
						self.gradient,
						style: self.strokeStyle(for: geo)
				)
					.animation(self.ringAnimation)
			}
				
				/// Frames the stack in the center of the superview, expanding to the full height, with a 1:1 aspect ratio.
				.frame(
					width: geo.size.height,
					height: geo.size.height,
					alignment: .center
			)
		}
		.onAppear {
			/// Begin the countdown transformations.
			self.beginCountdown()
		}
		
	}
	
	/// Begins a timed transform of the state variables, to animate the countdown.
	private func beginCountdown() {
		sequencer.add {
			self.degrees = 1
		}
		
		sequencer.add {
			self.degrees = 360
		}
		
		sequencer.add {
			self.textFactor = 1
			self.degrees = 240
			self.count = "3"
		}
		
		sequencer.add {
			self.degrees = 120
			self.count = "2"
		}
		
		sequencer.add {
			self.degrees = 1
			self.count = "1"
		}
		
		sequencer.add {
			withAnimation {
				self.alpha = 0
				self.shrinkMultiplier = 0
			}
		}
		
		sequencer.add {
			self.countdownFinished = true
		}
		
		/// Actually starts the sequence
		sequencer.move(countdownInterval, runLoop: .current)
	}
	
	/// Returns a stroke width for a geometry proxy, calculated using the width constant and multiplier.
	/// - Parameter geometry: The geometry proxy of the superview.
	/// - Returns: The desired stroke width of the ring.
	private func strokeWidth(for geometry: GeometryProxy) -> CGFloat  {
		geometry.size.height / strokeWidthDivisorConstant * strokeWidthMultiplier
	}
	
	private func strokeStyle(for geometry: GeometryProxy) -> StrokeStyle {
		StrokeStyle(
			lineWidth: strokeWidth(for: geometry) * shrinkMultiplier,
			lineCap: .round,
			lineJoin: .bevel,
			miterLimit: 0,
			dash: [],
			dashPhase: 0
		)
	}
}
