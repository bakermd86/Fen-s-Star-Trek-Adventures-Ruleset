rm -f Fen_StarTrekAdventuresDev.pak ;
zip Fen_StarTrekAdventuresDev.pak -x build.sh -r ./*;
mv Fen_StarTrekAdventuresDev.pak /mnt/c/Users/Michael/AppData/Roaming/SmiteWorks/Fantasy\ Grounds/rulesets/
rm -f /mnt/c/Users/Michael/AppData/Roaming/SmiteWorks/Fantasy\ Grounds/cache/STADev/rulesets/*

rm -f Fen_StarTrekAdventures.pak ;
zip Fen_StarTrekAdventures.pak -x build.sh -r ./*;
mv Fen_StarTrekAdventures.pak /mnt/c/Users/Michael/AppData/Roaming/SmiteWorks/Fantasy\ Grounds/rulesets/
rm -f /mnt/c/Users/Michael/AppData/Roaming/SmiteWorks/Fantasy\ Grounds/cache/test7/rulesets/*