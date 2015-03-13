# Epic Vegas IV
Epic Vegas IV is social networking app for iOS.  It was created for attendees of a fourth annual birthday celebration in Las Vegas.  I did it for fun and also to learn iOS development.

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
I chose to release the app through TestFlight using ad-hoc distribution.  With the short project timeline and approaching deadline, I likely would not have been able to get the app approved by Apple and released in the App store in time.  Also, by using TestFlight I was able to 'pre-authenticate' users.  Only users who gave me their device UDID and were approved could install the app.

### iPhone 4, 4s, 5, 5s Resolution
I chose to target iPhone 4, 4s, 5, and 5s screen resolutions.  The 6 and 6 Plus were not yet released, and none of my friends had older models.

## UI Overview
The main view of the application is a Tab Bar View.  The four main tabs are for the Public Feed, Attendees List, Map, and Profile.  The center tab is used for a "+" button to initiate sharing of a photo, message, or location checkin to the public feed.

### Login View

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Login.png" alt="alt text" width="250">

The Login View appears when a user launches the app for the first time.  They use Facebook to login to the app.

### Public Feed View

<img style="float:left" src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Feed.png" alt="alt text" width="250">

The public feed contains a scrollable list of photos and text posts by users.  Most recent posts are positioned at the top and earlier posts can be viewed by scrolling down.  You can pull up to refresh at the top of the list view.

### Attendees View

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Attendees.png" alt="alt text" width="250">

The Attendees View shows a scrollable list of all users of the app.  Includes a picture for each user, as well as their current distance and location from you.  Pressing on a row brings you to the attendee's profile view.

### Map View

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Map.png" alt="alt text" width="250">

The Map View shows the most recent location of each attendee.  Each location pin shows the attendee's photo, and pressing it will display the name of the location and when they were last seen there.

### Profile View

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Profile.png" alt="alt text" width="250">

The Profile View shows the user's profile page.  It has their user photo, a link to their location on a map view, a link to their facebook profile page, and a scrollable list of their checkins, photos, and message posts

### Share View

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Post.png" alt="alt text" width="250">

Pressing the "+" button in the center will trigger an animation that displays three popup buttons where the user can either perform a checkin, post a photo, or post a message

### Check In View

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/CheckIn.png" alt="alt text" width="250">

Selecting the Check In icon in the Share View will display the Check In View.  This is where a user can choose a location to check in to and name it.

### Photo View

Selecting the Camera icon in the Share View will display the Photo View.  This is where a user can either select an existing photo or take a new photo.  The stock camera app is used for this.  After selecting/taking a photo the user is brought to the Post View where they can add text to their photo post.

### Post View

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Post.png" alt="alt text" width="250">

Selecting the Post icon in the Share View will display the Post View.  This is where a user can write text to post to the public feed.  Pressing the Photo icon brings up the Photo View.

### Home Screen Icon

<img src="https://github.com/zkohl/Epic-Vegas-IV/blob/master/Documentation/Images/Icon.png" alt="alt text" width="250">

This is what the home screen icon looks like for the app.
