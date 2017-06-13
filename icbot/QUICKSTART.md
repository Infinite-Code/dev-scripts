Quick Start
-----------

1.  Install NPM packages
    ```
    npm install
    ```

2.  Run Redis
    ```
    redis-server
    ```

3.  Add Hubot integration into Slack and use the API Token for configs later.
    Also add a Personal Access Token (which is like a password) in Github to be used later.

3.  Update configs
    ```
    cp run-icbot.EXAMPLE run-icbot
    cp scripts/settings.coffee.EXAMPLE scripts/settings.coffee
    # edit the 2 config files and update the necessary credentials
    ```

4.  Run hubot
    ```
    ./run-icbot
    ```

5.  You should see that icbot has joined your Slack, invite it to your channel.
    Currently icbot it hardcoded to moby-finance project.