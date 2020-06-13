import SwiftUI

/// An animatable ring shape.
@available(macOS 10.15, iOS 13, watchOS 6, *)
public struct Ring: Shape {
	
	//MARK: Properties
	public var degrees: Double
	public var radius: CGFloat
	public var inset: CGFloat
	
	public var animatableData: Double {
		get { return degrees }
		set { degrees = newValue }
	}
	
	//MARK: Initialization
	public init(degrees: Double, radius: CGFloat, inset: CGFloat) {
		self.degrees = degrees
		self.radius = radius
		self.inset = inset
	}
	
	//MARK: Path
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		
		path.addArc(
			center: CGPoint(x: radius / 2, y: radius / 2),
			radius: (radius / 2) - inset,
			startAngle: .degrees(0),
			endAngle: .degrees(degrees),
			clockwise: false
		)
		
		return path
	}
}

