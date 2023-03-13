# Expense Sharing

## Important

- In the requirements minimal iOS version is 16.0 and Xcode version 14.0+, but I'm working on old macbook and cannot update to required Xcode and, therefore, set minimal version to 16.0.
- This project was built in Xcode 13.2.1 for minimal iOS version 15.2.
- When launching: either import arbitrary JSON as stated in the task or sync data from server. There are some mock users and groups.

## Technologies

- UI build with SwiftUI
- MVVM Architecture
- Firebase (for realtime database)

## Key Features

- Updating database with imported JSON
- Exporting Users and Groups as JSON
- Synching database with server (optional)
- Visualisation of expenses with charts
- Exporting reports as app-stylised images

## Challenges

- I chose SwiftUI over UIKit for this project to practise it more and take a break from my full-time job with current UIKit project. SwiftUI is developing every year and there are cool features for iOS 16 like **Swift Charts**, but they are awaiting when I purchase a new macbook. However, I did manage to create a basic chart and use other workarounds.

- I initially decided to sync data on server, like a real-world app would and this purpose I chose  Firebase. However, as I started implementing it too close to the deadline - the feature can use some improvements. But the model itself should be modified to better suit server storage and access.
