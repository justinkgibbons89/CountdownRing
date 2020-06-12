import SwiftUI

/// An animated countdown ring, similar to the one's used in Apple Workouts on watchOS.
@available(macOS 10.15, iOS 13, watchOS 6, *)
public struct CountdownRing: View {
    
    //MARK: Properties
    public var strokeWidthMultiplier: CGFloat = 1
    public var strokeWidthDivisorConstant: CGFloat = 10
    public var colors: [Color] = [.green, .blue]
    private var sequencer = Sequencer()

    //MARK: Data Sources
    @State private var degrees: Double = 360
    @State private var count: Int = 3
    @Binding private var countdownFinished: Bool

	//MARK: Initialization
	public init(isFinished: Binding<Bool>? = nil, colors: [Color], widthMultiplier: CGFloat = 1) {
		self.strokeWidthMultiplier = widthMultiplier
		self.colors = colors

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
                    gradient: Gradient(colors: self.colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                    .mask(
                        Text("\(self.count)")
                            .font(Font.system(size: geo.size.width / 2.25))
                            .bold()
                            .frame(width: nil, height: nil, alignment: .center))
                
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
                ).animation(.default)
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
            self.degrees = 360
            self.count = 3
        }
        
        sequencer.add {
            self.degrees = 240
            self.count = 2
        }
        
        sequencer.add {
            self.degrees = 120
            self.count = 1
        }
        
        sequencer.add {
            self.degrees = 0
            self.count = 0
        }
        
        sequencer.add {
            self.countdownFinished = true
        }
        
        sequencer.move(1, runLoop: .current)
    }
    
    /// Returns a stroke width for a geometry proxy, calculated using the width constant and multiplier.
    /// - Parameter geometry: The geometry proxy of the superview.
    /// - Returns: The desired stroke width of the ring.
    private func strokeWidth(for geometry: GeometryProxy) -> CGFloat  {
        geometry.size.height / strokeWidthDivisorConstant * strokeWidthMultiplier
    }
    
    private func strokeStyle(for geometry: GeometryProxy) -> StrokeStyle {
        StrokeStyle(
            lineWidth: strokeWidth(for: geometry),
            lineCap: .round,
            lineJoin: .bevel,
            miterLimit: 0,
            dash: [],
            dashPhase: 0
        )
    }
}
