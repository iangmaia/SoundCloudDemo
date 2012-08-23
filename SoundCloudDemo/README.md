# SoundCloud Demo app

Simple app to login / logout, fetch user's data and show the user's dashboard using the CocoaSoundCloudUI and CocoaSoundCloudAPI.

## Setup

1. Clone the SoundCloudDemo repository.

2. Add the project dependencies do the same directory level as the demo (basically the CocoaSoundCloudUI and CocoaSoundCloudAPI and their dependencies):

        git submodule add git://github.com/soundcloud/CocoaSoundCloudAPI.git
        git submodule add git://github.com/soundcloud/CocoaSoundCloudUI.git
        git submodule add git://github.com/nxtbgthng/OAuth2Client.git
        git submodule add git://github.com/nxtbgthng/JSONKit.git
        git submodule add git://github.com/nxtbgthng/OHAttributedLabel.git

That should do it!
