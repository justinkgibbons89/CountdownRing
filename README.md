# CountdownRing

An animated countdown ring similar to the one used in Apple Workouts on watchOS.

## A simple countdown ring

```swift
struct ContentView: View {
    
	var body: some View {
		/// The ring will expand to fill the width of its parent.
		/// Its height will equal its width.
		/// All we have to do is pass in the colors for the gradient.
		CountdownRing(gradientColors: [.green, .blue])
    }

}
```

## Show a different view upon completion

```swift
struct ContentView: View {
    
	/// Use a state variable to track the progress of the countdown. We'll pass this 
	/// to the countdown ring as a binding.
	@State var countdownIsFinished = false
	
	var body: some View {
		VStack {
			if countdownIsFinished {
				/// Show "done" when the countdown is over
				Text("The countdown is done!")
					.onAppear {
						/// We could also play a haptic at the end of the countdown.
						/// In this case we're using `start` to signify the start of the workout.
						WKInterfaceDevice.current().play(.start)
				}
			} else {
				/// Show the countdown ring. It will animate automatically when it appears.
				CountdownRing(
					isFinished: $countdownIsFinished, /// pass in the `isFinished` binding
					gradientColors: [.pink, .orange] /// set the colors for the gradient
				)
			}
		}
	}
}
```
