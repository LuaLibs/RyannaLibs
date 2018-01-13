# RyannaLibs

Libs I need for [Ryanna](https://github.com/TrickyGameTools/Ryanna)

These are libraries Ryanna can automatically copy and merge into its projects. This way I can always be sure all my Ryanna projects have the latest version of my libs *and* it saves a lot of undeededly taken disk space.

![Ryanna](http://tricky1975.github.io/63/icons/ryanna.png)


Ryanna will scan all Lua files it has to include into its projects. As soon as a "-- $USE" call is made to a library from the directory "Libs/" it will scan all set up library directories and automatically import these libraries.

Notes:
- When you Ryanna libs are in /mylibs then the libs themselves must be located in /mylibs/Libs
- Linux users MUST make sure that "Libs" is spelled in the same manner I just did with upper and lower case in order, unless the libraries are located on a FAT32 or ExFAT device (as even Linux will then act case insensitive, since it's the file system that decides the case sensitivity, not the OS trying to access it).
- Most Mac formats can be used case insensitively, if you are not sure about the sensitivity of your chosen device, play safe and go for sensitive. FAT32 and ExFAT are case insensitve regardless of the system calling it.
- When building a project Ryanna will kill all case sensitivity. When you have "script.lua" and "script.Lua", they will both be included, but one of them will not be accessible. This will happen regardless of OS (yes, even in Linux. Ryanna was coded and scripted to do so).
- Yes, you can make one library refer to another. Ryanna will then just import that other one as well, even when the main project doesn't.
- A feature is planned to make Ryanna able to ignore scripts suffixed with "\_\_windows" when not in windows, and using the "\_\_darwin" and "\_\_linux" suffixes in the same manner, be careful with using "\_\_" in file names. A single underscore is fine, but two is 'risky', as more features may appear using these double underscores.
- Library rules:
  - All libaries must be folders using the extension "rel" (Ryanna Expanded Library).
  - Libary names may NOT include spaces.
  - "Libs" may be handled case sensitively in Linux, the ".rel" folders and all files they contain will even in Linux be handled case insensitively. Ryanna uses some nice magic to void the case sensitive nature of Linux once it can see the Libs folder.
  - The library names may not contain spaces, but the contents of these libraries won't matter.
  - Yes, you can include pictures, sounds and other assets in your .rel folders. If you script your libraries to load them take note of the file name. "libs/mylib.rel/mypicture.png" or something like that.
- Windows users should be aware of this. Once Ryanna used her magic to build a project, the project will no longer understand backslashes as separator for directories. Your project will then just follow the Unix standards even on Windows and use the slash as directory separator. Remember this or your project can (and very likely will) crash.
- Ryanna is a project builder for [love](http://love2d.org), but is not tied to a specific version. Ryanna is unable to see if these libraries are fully compatible with the love version being used when building. In a basic way goes, that all libraries require Love2d version 0.10.2 or later. Errors caused by libraries using functions being deprecated or removed that is something I'm willing to look at, but I am NOT going to adept these libraries to work with Love versions older than 0.10.2, sorry!

