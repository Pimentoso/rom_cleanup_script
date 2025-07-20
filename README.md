# ROM Cleanup Script
Ruby script to cleanup bad/unwanted ROMs, mainly from TOSEC dumps.

## How to use

Usage:

```
ruby rom_cleanup.rb [directory] [.extension]
```

This is the flow I usually use.

- Download a rom folder from myrient or other sources using `wget -m -np -c -e robots=off -R "index.html*" https://myrient.erista.me/files/TOSEC/...`
- Move all the roms to a reasonably named folder
- Run the script using `ruby rom_cleanup.rb /path/to/roms .zip`. The script will remove unwanted ROMs using this criteria
  - ROMs with bad tags 
  - ROMs for countries that are not EU or US
  - ROMs in alpha/beta/prototype state
  - ROMs with multiple alternate versions (namely [a] tags) - it will only keep the one with the highest number
  - Then, it will prompt the user for any ROM with multiple region versions (usually EU or US), and the user has to choose which one to keep. I usually keep the US version
- Manually go through the game directory to see if the script missed something and still have some duplicates
- Run Retropie or any retrgaming platform you are using, and use the scraper function to get the game metadata. Then manually go through the games and check again if there are duplicate games: some games have a different name between EU and US so scraping the titles should reveal those.
- Enjoy your curated list of ROMs!