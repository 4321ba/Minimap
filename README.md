# Minimap
Minimap is a level-based combat game.  
Watch the trailer: https://youtu.be/3rkWcyBnD1Q .  
Get it from Google Play Store: https://play.google.com/store/apps/details?id=org.ab.minimap .  
Play it in your browser, or download it for PC on itch.io: https://1234ab.itch.io/minimap .  
It features unique enemies, bosses, skill points, and simplistic, Don't Starve-style combat, that is hard to master. You have a single type of attack, how well can you use it against the different enemies? You can adjust the difficulty of the game, if it's too easy for you.
Minimap is a game I made during the last 3/2 years, and it's my first game that's actually playable.
For the in-game music, check out the Minimap OST playlist: https://www.youtube.com/playlist?list=PLDa4Vj43E2e_ywvmSjU-26Bs_MsiRnfIn . LMMS project files are also included here (you'll need to add the soundfonts to your lmms/samples folder).
# Code quality
This is a beautiful example of inheritance over composition, just kidding. Being one of my first projects, I wanted the code to work, and not to look nice. So even though there are systems I like (the options, setting options saving them e.g.), the main system: the player and the enemies fighting are pretty bad. Nevertheless I'm happy that it can be considered stable and mostly bug-free.
The next major task would be to integrate Lawnjelly's smoothing addon and migrate the movement code from `_process` to `_physics_process`.  
Feel free to open an issue, if you have any questions :D !
