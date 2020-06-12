# CountdownRing

An animated countdown ring similar to the one used in Apple Workouts on watchOS.

## Show a different view upon completion

```swift
struct ContentView: View {
    
	//MARK: Data Sources
	/// This should be `false` to start
	@State var isFinished = false
	
	var body: some View {
		VStack {

			/// Show a the completion view
			if self.isFinished {
				Text("Done!").onAppear {

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
