# Conway's Game of Life

https://deklanw.github.io/gameoflife-elm/


<a href="https://deklanw.github.io/gameoflife-elm/"><img src="https://i.imgur.com/blzh99x.png" alt="Screenshot of primary UI" width=520></a>


## About

Bootstrapped with create-elm-app. Uses elm-css for some type safety. UI is responsive with media queries and Flexbox.

Randomizing a grid was a good excuse to use Traversable. Elm doesn't have typeclasses, so I had to copy and paste some instances.

## Possible improvements

* A better way to handle the media queries
* Use something like WebGL(?) instead of representing cells with colored `div`s.
* Host the body font locally instead of via Google Fonts?
* Play the evolution in reverse.
* Adjust evolution rate with a slider.
