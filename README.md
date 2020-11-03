# cc-installer
an installer program for directory based projects.

# How does it work?
It serializes all of the files in your folder into text, and then stores it in a simple text format (`textutils.(un)serialize`). Then it can automatically upload it to pastebin for you.
From there, the user installs a small installer script, that will then download your data from pastebin, unpack it, and tada, it's all installed!

# How to use
`java -jar Installer.jar help`
