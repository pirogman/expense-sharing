# Expense Sharing

🥈 **Second place** in iOS Development Challenge from Readdle.

![dev challange](https://raw.githubusercontent.com/pirogman/expense-sharing/images/dev_challange.png)

## Task Description

The task is to create a user-friendly application that facilitates expense sharing among a group of users. The application should allow users to enter their expenses and sync with other users in the group. The application will then calculate the total expenses incurred by each user and generate a report to show how much money each person owes or is owed. To achieve this, the application will need to have a user-friendly interface that allows users to easily enter their expenses. The application should also have a feature that allows users to add or remove members from the group, and the ability to create different groups for different trips.

Additionally, at the end of group expenses, the application should be able to generate an expense report that shows each user's total expenses and the amount of money they owe or are owed by other members of the group. It should be easy to use, and the user interface should be intuitive and simple to navigate.

## Requirements

- The project should build on Xcode 14.0+. 
- Language should be Swift.
- The target should support the iPhone as the main platform.
- The application must run correctly on the simulator.
- The minimal iOS version is 16.0.

## Screenshots

<img src="images/sc_login.png" width=200> <img src="images/sc_profile.png" width=200> <img src="images/sc_group.png" width=200> <img src="images/sc_report.png" width=200>

## Important

- In the requirements minimal iOS version is 16.0 and Xcode version 14.0+, but I'm working on old macbook and cannot update to required Xcode and, therefore, set minimal version to 16.0.
- This project was built in Xcode 13.2.1 and tested on iOS version 15.2.
- When launching: reset server with arbitrary JSON as stated in the task. Alternatively, you can always reset it back to test data *(see TestData.json)*.

## Technologies

- UI build with SwiftUI
- MVVM Architecture
- Firebase (for realtime database)

## Key Features

- Reseting remote database with imported JSON
- Automatic sync with remote database
- Visualisation of expenses with charts
- Exporting reports as app-stylised images
- Expense-sharing algorithm that prioritises the minimum number of transactions required to settle debts between group members
