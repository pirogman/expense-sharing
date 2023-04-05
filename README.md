# Expense Sharing

🥈 **Second place** in iOS Development Challenge from Readdle on 22.03.2023

![dev_challenge](https://user-images.githubusercontent.com/11997085/230068824-7e0ef9ac-816d-42b0-92c5-c945c09dd824.png)

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

<img src="https://user-images.githubusercontent.com/11997085/230068943-1c13915f-ca08-453f-abac-1c9054e4ffe3.PNG" width=200> <img src="https://user-images.githubusercontent.com/11997085/230068947-644a415b-e7e5-4999-9cc0-cd4c81476ae2.PNG" width=200> <img src="https://user-images.githubusercontent.com/11997085/230068935-dd9a62a3-0411-4943-a2e7-2198b74905a1.PNG" width=200> <img src="https://user-images.githubusercontent.com/11997085/230068952-751b82b0-9946-4731-8044-bbe7ff44841a.PNG" width=200>

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
