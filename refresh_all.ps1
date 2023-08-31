rm ./apache/log/*.log
Remove-Item ./apache/www/* -Exclude .gitkeep -Recurse -Force
rm ./php/error_log/*.log
rm ./cert/server.*