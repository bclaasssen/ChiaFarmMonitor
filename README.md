# ChiaFarmMonitor
Powerbrowser Telegram script to monitor farming CHIA

# How to

* Get bottoken and chatid from telegram:
https://www.siteguarding.com/en/how-to-get-telegram-bot-api-token
1) Add the Telegram BOT to your group or send message to it.
2) Get the list of updates for your BOT:
   In webbrowser go to https://api.telegram.org/bot<YourBOTToken>/getUpdates  #Example https://api.telegram.org/bot123456789:jbd78sadvbdy63d37gda37bd8/getUpdates
3) Look for the "chat" object. Use the "id" of the "chat" object to send your messages. #Example {"update_id":8393,"message":{"message_id":3,"from":{"id":7474,"first_name":"AAA"},"chat":{"id":,"title":""},"date":25497,"new_chat_participant":{"id":71,"first_name":"NAME","username":"YOUR_BOT_NAME"}}} 

* Enter settings in the beginning of the script

* Run this script in / as Powershell (rightclick run as powershell)

