# Fabled - Destiny 2 Glory Tracker

This is the source code for the "Fabled - Destiny Glory Tracker" (the 2 wouldn't fit) app in the App Store (awaiting review).

I am releasing this app and its source code much earlier than I wanted due to upcoming changes in the game discussed [below](#early-release). The UI is admittedly not where I wanted it. And the code isn't either (especially my Bindable Views). I discuss this at length in the later sections.

## Feedback / Support

If you've come to report a bug or otherwise provide feedback, you can do that [here](https://github.com/nathanhosselton/Fabled/issues) (requires a GitHub account).

## Privacy Policy

[Here you go](https://github.com/nathanhosselton/Fabled/blob/master/Privacy-Policy) (Spoiler: we don't do anything with your Destiny data but show it to you).

# About

Fabled provides insights into a Destiny 2 player's Competitive PvP Glory Rank progress not available through the game itself. Specifically, the app focuses on tracking a player's progress to Fabled rank, which has been historically tied to seasonal pinnacle rewards within the game.

Fabled fetches the Glory history for an entered player from the [Bungie.net API](https://bungie-net.github.io) and displays values such as current Glory progress Rank. It also performs calculations on the data to output contextual information such as the number of games played during the current weekly reset period, the player's current win streak, the number of wins required to rank up, and the number of wins remaining to reach Fabled rank.

The motivation for the app was not simply to display information, however. I also hope that the insights inspire confidence to continue to pursue a milestone that, for many Destiny players, can often feel hopelessly distant. The "Glory at next reset" and "Wins to Fabled" insights can show a player that they're never too far away, and that small steps can help.

## Early Release

Due to upcoming changes detailed in the [next section](#shadowkeep), my work on this app hereto was in danger of being lost. I had completed all of the data retrieval, modeling, calculation, and testing work, leaving only UI to implement. But because of the game changes coming October 1, that was all going to go out the window.

So, rather than let that effort go to waste, I decided to release early in the hopes that Destiny players may get some value out of it before the work becomes obsolete. This required that I compromise on the UI _and_ my UI code. Which I'm not happy about. But I think it was the right trade-off to make.

## Re: Shadowkeep

Bungie [recently announced](https://www.bungie.net/en/Explore/Detail/News/48072) that changes will be made to Glory Ranks and the way that players earn and lose Glory. We do not yet know all of the details, but the information shared thus far indicates that this app will not provide accurate information after the changes go live with the release of Shadowkeep on October 1.

As soon as the community has the specifics on the changes, I will update the app to reflect, assuming the app's purpose is still relevant. I have no idea when this will be, however, and it may take until after October 1. You can check back here for progress updates.

## Future Updates

While we wait to hear about the Shadowkeep changes, I am going to continue releasing updates to the app. Mostly to its visuals, which I'm less than enthused with. I'm a programmer, and very distinctly _not_ a designer. I can tell when things look and work poorly or well, but not much more.

But I _do_ have friends who can. And one of them has just sent me some mockups as I'm typing this. I hope to have those changes implemented next.

## Open Source

It was my intention from the beginning to post the source for the app, but I thought it wouldn't be until I was totally happy with it. Still, I'm not totally _unhappy_ with it. Could be worse.

My motivation for making in public was a mix of having some real, recent code on my GitHub, since I can't open source any of my paid work, and also just because I like the spirit of open source. I think there should be more cases where people can download apps and then also go and find the code for it, even if only as a curiosity.

So I don't expect nor am I necessarily seeking anyone to contribute to Fabled. But maybe someone will find the code helpful or interesting.

### Bindable Views

This project didn't start as the app. It started as me working on my Bindable Views code, just for fun. Then the app idea became an excuse to continue to build out Bindable Views in the context of a "real app". Then the app became the thing to release and Bindable Views had to take a back seat.

I never actually intended to release Bindable Views as a library for others to depend on. Similar to [State](https://github.com/nathanhosselton/State/), it was and still is a toy project. I would never use either in a client project. I was simply inspired by SwiftUI and started playing around with a UIKit implementation and whoops here we are.

Because of my desire to get Fabled out the door as quickly as possible, Bindable Views took some hits on coherence and responsibility -- it's due for some nerfing and rebalancing. But it has been really fun to work on and to use. And once I clean it up a bit more, I'll post it to its own repo proper.
