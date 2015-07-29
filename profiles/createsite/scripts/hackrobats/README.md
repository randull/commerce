<b>Preparesite:</b><br>
Creates Apache Config, DB & DB User, and empty directory within /var/www on Dev and Prod<br>
<b>Generatesite:</b><br>
Creates Apache Config, DB & DB User, and empty directory within /var/www on Dev and Prod<br>
<i>Also</i> Generates Drupal site using custom Installation Profile on Dev & Clones it to Prod<br>
<b>Updatesite:</b><br>
Clones current site from Prod to Dev, to be used before testing Drupal updates on Dev<br>
<b>Stagesite:</b><br>
Pushes changes done on Dev to Github repo, then pulls those changes to Prod<br>
<b>Migratesite:</b><br>
Migrates entire site from Dev to Prod, will overwrite everything including DB<br>
<b>Cleansite:</b><br>
Fixes Drupal file permissions, removes unnecessary placeholder files<br>
<b>Emptysite:</b><br>
Drops all tables in Database, deletes all files and directories in root directory<br>
<b>Removesite:</b><br>
Deletes DB & DB user, removes entire directory from /var/www, Apache config, All of it!
