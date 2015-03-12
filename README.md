# Epic Vegas IV
Epic Vegas IV is my first iOS App.  It was created for attendees of a fourth annual birthday celebration in Las Vegas.  I did it for fun and also to learn iOS development.

## Features
* Ability to post messages and photos to a public feed
* View list of event attendees
* View the location attendees on a map to aid in meetups
* Check into locations

## Design Decisions
Many of the design decisions were influenced by the deadline to get the app out the door in a matter of weeks.  It was a last minute decision to build it and the date for the event was already set in stone.

### Public Data
All data in the app is publicly accessible to all users in the app.  This alleviated the need to worry about taking care of permissions and building a friend and unfriend UI.  This was acceptable since everyone going to the event already belonged to the same core friend circle.

### Facebook For User Login
I used the Facebook API to support logging in users.  This made it simple to get a photo for each user and I didn't need to worry about authentication concerns.  All attendees already had Facebook since we planned the event on Facebook Events.

### Objective-C
I chose to develop the app using Objective-C.  Swift was still in its infancy, still changing, and had little documentation and community support compared to Objective-C.  Also, some dependencies like Parse only had an SDK in Objective-C.

### Parse
I chose to use Parse as the backend server and database for the app.  Using Parse allowed me to focus most of my attention on the iOS client app, since I didn't need to worry about building a web server and maintaining a database.  The Parse iOS SDK also had wrappers to make some database interactions simple like storing and retrieving users and their associated data.

### iOS7 SDK
I chose to only support the iOS7 SDK so I wouldn't need to worry about backwards compatibility issues.  Most of my friends were in the tech scene and already had updated iPhone models with iOS7 installed.

### TestFlight
I chose to release the app through TestFlight using ad-hoc distribution.  With the short project timeline and approaching deadline, I likely would not have been able to get the app approved by Apple and released in the App store in time.  Also, using TestFlight I was able to use that as my 'authentication' method since I required the UDID of each member's iPhone as a part of the App Build.

### iPhone 4, 4s, 5, 5s Resolution
I chose to target iPhone 4, 4s, 5, and 5s screen resolutions.  The 6 and 6 Plus were not yet released, and none of my friends had older models.
