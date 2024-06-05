# Supersonic Update Script for macOS and Windows
A bash script to update/install [Supersonic](https://github.com/dweymouth/supersonic) on macOS or Windows.

**macOS Usage:** ``curl -sL https://www.gavinliddell.us/sus | bash``

**Windows Usage:** ``irm https://www.gavinliddell.us/sus-win | iex``

## Known Issues
- The application will get flagged as corrupted if an old version is installed using the traditional method but never opened to verify with Apple before using the update script.
  - Solution: Open or remove old version before running the script.

## Credit
[@lukechilds](https://github.com/lukechilds) for their [bash function](https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c) to fetch the latest release using the GitHub API.

[Google](https://google.com) for free knowledge online.
