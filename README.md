Repository containing submission for the final project of Udacity iOS Developer Nanodegree program.

## Overview
Lards is a local multiplayer card game app which doesn’t require internet (or infrastructure) to play a game of war.

To run the app will require two devices, either physical or simulation, or both. When running in a simulator you will receive an alert asking to allow the app to accept incoming network connections. Select “Allow” to ensure the app behaves as desired.

I’ve put my OpenWeatherMap API key in an untracked file so as not to expose it publicly in my repository. The API key is stored in Keys.plist as a simple dictionary with a key called “key". The plist should be in the main source directory (i.e. at the same level as Info.plist).

One of the project rubric requirements was to display an alert view if network connection fails. My networking checks the weather to provide a tailored card back with the appropriate icon, a trivial thing to the game mechanics. Because of this I have elected **not** to implement a visible alert to the user. In my opinion, having a alert that pops up is intrusive and a bas user experience.

## User Experience

### Main Menu 
The main menu presents options for “New Game”, “Load Game”, and “Settings”.

* Navigating to “New Game” moves to the New Game Menu.

* Navigating to “Load Game” moves to a table view which displays the completed and in progress games (or “No Games” if there are none) contained in the CoreData store. Tapping on a game here transitions to a waiting view while the other player from that game is found and connected to. After successful connection, the user is put in the main game screen.

* Navigating to “Settings” allows the user to change their display name, their preferred color (for app controls, card backs, etc.), and toggle the use of haptics in the app. The settings here are stored in UserDefaults.

### New Game Menu
The new game menu presents options for “Create Game” and “Join Game”,

* Tapping “Create Game” brings up a modal for creating a game. Essentially the device is now a host, and waiting for players to join. When a player tries to join, they are displayed on screen and the host can tap to add them to the game. The host can then tap done in the upper right to start the game, or cancel the process. 
Once the game is started by the host, the game is added to CoreData and all related changes to the game (i.e. the deck, player’s hands, moves, etc.) are persisted. This is what’s loaded in the “Load Game” screen.

* Tapping “Join Game” brings up a modal for going a game and starts searching for hosts. When a host is found, it is displayed on screen, and the user can tap to send a request to join. When a host accepts, the user is moved to a waiting screen until the host starts the game, at which point they are put in the main game screen.

Location use: The app asks for location data at this point so it can pinpoint the user’s location and provide custom card back artwork based on the current weather.

### Main Game Screen
Entering this screen shows two decks of cards, the players, and the opposing players. The opposing player has a name tag, and both decks have a small stack of cards with a number which is an indicator of the number of cards in a given deck. Tapping your deck will flip over and play a card (which shows up on the other device as the opponent playing the card, and vice versa). The cards are given to the correct user based on wins, losses, ties, etc. If any player exits the main screen, or causes the app to be backgrounded, players are removed from the main game screen to a rejoining screen where they can wait for users to reconnect. (Games can be manually rejoined by loading the game from the main menu, and started and stopped whenever). Successful reconnection returns the user to the main game screen and the game continues. When the game is finished, the user is presented with an alert stating whether they won or lost, and kicked back to the main menu.
