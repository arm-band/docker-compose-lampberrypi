rm ./apache/log/*.log
find ./apache/www/ -type f | grep -v -E "\.gitkeep" | xargs rm -rf
rm ./php/error_log/*.log
rm ./cert/server.*