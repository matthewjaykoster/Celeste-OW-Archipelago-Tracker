# Celeste-OW-Archipelago-Tracker

Poptracker Pack for Celeste Open World Archipelago, based on the work by [seto10987](https://github.com/seto10987), located [here](https://github.com/seto10987/Celeste-AP-Tracker).

Archipelago Celeste pack for [PopTracker](https://github.com/black-sliver/PopTracker/) with Autotracking, built on PopTracker v0.33.0. This version or higher is recommended. 

# Features

- Usable with Celeste Open World, with individual level tracking for A-Side levels (Strawberries, Hearts, Level Completions, and Cassettes).
- Configurable Goal settings including Goal Level and Required Collectables, read directly from the Server.
- Supports Hints Tracking (hints made through the AP Server will show blue squares under the corresponding location in your game.)
- The inital release does not contain ability-based logic or tracking.

# Installation

1. Ensure you have [PopTracker](https://poptracker.github.io/) installed. Make sure you know the folder where you installed PopTracker!
2. Download the repository. You can do this either by mousing over the "Code" button (above) and clicking "Download ZIP" or by opening the "Releases" page (right) and clicking on the ZIP file under the most recent release.

![Download Latest ZIP](images/how_to_download.png)

3. Move the file you just downloaded into the "packs" folder withing your PopTracker install folder. No need to unzip the download - PopTracker handles that for you.
4. Open PopTracker and select the newly installed package (it should be called something like "Celeste Open World Archipelago X.Y.Z"). It should open a map which looks similar to the image below.

![Screenshot of the pack](images/preview.png)

# Use

## Manual

If you are not playing using an [Archipelago](https://archipelago.gg/) server, you'll have to track everything manually. You'll have to know a few things about to use the tracker in order to do this:

- First, setup your goals under the "Settings" heading - click on the image next to your selected goal to set it. For example, to set the goal at "50 strawberries", click the strawberry next to the "Berry Req" label 50 times. Yes, 50 times. Maybe I'll make this easier in the future.
- To navigate to your current map, click on any of the tabs at the top of the tracker. Note that most maps have "sub-maps" inside, so you may have to click multiple times to get to your current map (e.g. Clicking on "City" leads to three options: "Start", "Crossing", and "Chasm").
- Location checks are represented by squares on the map. Mouse over the square to see what checks are available at that location. Left click a location to mark it as "checked". Right click a location to unmark it as "checked" (in case you made a mistake or something).
- Location checks are color-coded based on the items you currently have. Green squares are currently "checkable". Red squares are not.
- Items obtained are tracked under the "Items" header near the bottom of the screen. Whenever you find an item, such as a Casette or Heart, make sure to mark if here. If you do not mark these items, your local "checkability" will not update correctly. Note that some things which you might not normally think of as items in the traditional sense, such as "Level Clears", are treated as items in the tracker, so make sure to mark those as well!

And that's about it! There are a few other details, but you'll have to figure them out on your own. Best of luck!

## Autotracking

If you are playing using an [Archipelago](https://archipelago.gg/) server, you can utilize the pack's autotracking functionality. Once connected, the pack will automatically track your location checks, items found, and levels cleared.

To connect to the Archipelago server, load up the package and then click the "AP" icon in the upper left corner. The package will ask you to enter some basic inforamtion - your achipelago URL + port (e.g. "archipelago.gg:56884"), your player/slot name on the server (e.g. "john_archipelago" - this should match the name in your Archipelago YAML file), and your password (e.g. "hunter2" - leave this blank if you aren't using a password).

Once connected, that's it! Your settings and current checks/items should autopopulate - you can play and the tracker should handle everything for you.

# Interested in Helping Out?

Interesting in helping maintain this package, modifying it to create your own version, or creating your own pack? Some of [these links](./docs/links.md) might help!

This pacakge is licensed using the MIT license, so you can use the code for whatever (don't feel like you have to contact me for permission, but I'd appreciate if you do use it, plesae add me to your thanks/credits in your code and README).