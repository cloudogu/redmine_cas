# Developing Redmine CAS plugin

## Troubleshooting
### Inetllij Error `No Ruby interpreter configured for Project` is displayed in Intellij
If you are working with Inellij and the message `No Ruby interpreter configured for Project` does not close despite correct Ruby installation and Ruby SDK configuration,
open the project settings via 'Ctrl+Alt+Shift+S' and navigate to the tab 'Modules'. There you should see a small folder with an **orange Ruby symbol**.
If instead the symbol on the folder is a small blue rectangle, Intellij tries to import the project as a Java project with JRuby content.
Reimport the module via '+' button -> 'Import Module' -> 'Create a module from existing sources' -> follow the instructions and then click on 'finish'.