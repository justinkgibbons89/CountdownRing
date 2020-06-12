# CountdownRing

An animated countdown ring similar to the one used in Apple Workouts on watchOS.

## Show a different view upon completion

```swift
struct ContentView: View {
    
	/// Use a state variable to track the progress of the countdown. We'll pass this to the 
	/// countdown ring as a binding.
	@State var isFinished = false
	
	var body: some View {
		VStack {
			if self.isFinished {
				/// Show "done" when the countdown is over
				Text("Done!")
					.onAppear {
						/// Play the `start` haptic
						WKInterfaceDevice.current().play(.start)
				}
			} else {
				/// Show the countdown ring. It will animate automatically.
				CountdownRing(
					isFinished: self.$isFinished, /// pass in the binding
					gradientColors: [.pink, .orange] /// pass in the gradient colors
				)
			}
		}
	}
}
```
