# GeoWiki

GeoWiki is an demo project designed to incorporate geo-location coordinate sharing into the official Wikipedia iOS app.

The objective of this demonstration project was to enhance the existing Wikipedia app so that it can process coordinates in a `places` deeplink. When the Wikipedia app receives this deeplink, it should default to the _'Places'_ tab instead of the initial one, and display a specific location rather than the user's location. In my implementation, it also retrieves Wikipedia articles within the visible map area.

The second component of this project is a small testing application. This application fetches a list of locations from the backend and presents them to the user. Tapping on a location initiates a new `places` deeplink to Wikipedia, complete with coordinates, illustrating how these Wikipedia updates function. Additionally, an extra map screen has been added to allow users to select a location on the map and continue with its coordinates to the Wikipedia app using the new deeplink.

This project was built using `Combine` along with modern concurrency APIs such as `actors` and `async/await`.

### Demo video

https://youtu.be/z3VzBfqU4TY
