################################################
##               SETTINGS                     ##
################################################

<# Setting: Telegram BOT token #>
#https://www.siteguarding.com/en/how-to-get-telegram-bot-api-token
$bot_token = "xxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

<# Setting: Telegram CHAT ID  #>
# 1) Add the Telegram BOT to your group or send message to it.
# 2) Get the list of updates for your BOT:
#    In webbrowser go to https://api.telegram.org/bot<YourBOTToken>/getUpdates  #Example https://api.telegram.org/bot123456789:jbd78sadvbdy63d37gda37bd8/getUpdates
# 3) Look for the "chat" object. Use the "id" of the "chat" object to send your messages. #Example {"update_id":8393,"message":{"message_id":3,"from":{"id":7474,"first_name":"AAA"},"chat":{"id":,"title":""},"date":25497,"new_chat_participant":{"id":71,"first_name":"NAME","username":"YOUR_BOT_NAME"}}} 
$id = "xxxxxxx"

<# Optional setting: What to report #>
$plotsummary = $true
$warninglogs = $false
$errorlogs = $true

<# Optional setting: Frequency to report in seconds 3600 = one hour 10800 = three hours #>
$frequency = 10800

<# Optional setting: Store processed files and location#>
$archive = $true
$archivedirectory = "$env:USERPROFILE\.chia\mainnet\log\old\"

<# Optional setting:date format. Set to false for europe style #>
$dateUSformat = $false;

################################################
##           END OF SETTINGS                  ##
################################################


################################################
##                Defaults                    ##
################################################

<# Dates #>
$date = Get-Date -format "yyyyMMddHHmm"

if ($dateUSformat) {
    # US
    $plotInfoDate = Get-Date -Format "MM/dd/yyyy HH:mm"
} else{
    # Europe
    $plotInfoDate = Get-Date -Format "dd/MM/yyyy HH:mm"
}

<# Filesnames and directorys #>
$logfilepath = "$env:USERPROFILE\.chia\mainnet\log\debug.log"
$logfiletemp = "$env:USERPROFILE\.chia\mainnet\log\debug$date.log.temp"
$logfilearchive = "parsedDebug$date.log"

<# Telegram URL #>
$uri = "https://api.telegram.org/bot$bot_token/sendMessage"





<# TELEGRAM SEND MESSAGE FUNCTION
.Synopsis
    Sends Telegram text message via Bot API
.DESCRIPTION
    Uses Telegram Bot API to send text message to specified Telegram chat. Several options can be specified to adjust message parameters.
.EXAMPLE
    $bot = "#########:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $chat = "-#########"
    Send-TelegramTextMessage -BotToken $bot -ChatID $chat -Message "Hello"
.EXAMPLE
    $bot = "#########:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $chat = "-#########"

    Send-TelegramTextMessage `
        -BotToken $bot `
        -ChatID $chat `
        -Message "Hello *chat* _channel_, check out this link: [TechThoughts](http://techthoughts.info/)" `
        -ParseMode Markdown `
        -Preview $false `
        -Notification $false `
        -Verbose
.PARAMETER BotToken
    Use this token to access the HTTP API
.PARAMETER ChatID
    Unique identifier for the target chat
.PARAMETER Message
    Text of the message to be sent
.PARAMETER ParseMode
    Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message. Default is Markdown.
.PARAMETER Preview
    Disables link previews for links in this message. Default is $false
.PARAMETER Notification
    Sends the message silently. Users will receive a notification with no sound. Default is $false
.OUTPUTS
    System.Boolean
.NOTES
    Author: Jake Morrison - @jakemorrison - http://techthoughts.info/
    This works with PowerShell Versions 5.1, 6.0, 6.1
    For a description of the Bot API, see this page: https://core.telegram.org/bots/api
    How do I get my channel ID? Use the getidsbot https://telegram.me/getidsbot
    How do I set up a bot and get a token? Use the BotFather https://t.me/BotFather
.COMPONENT
   PoshGram - https://github.com/techthoughts2/PoshGram
.FUNCTIONALITY
    https://core.telegram.org/bots/api#sendmessage
    Parameters 					Type 				Required 	Description
    chat_id 				    Integer or String 	Yes 		Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    text 						String 				Yes 		Text of the message to be sent
    parse_mode 					String 				Optional 	Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message.
    disable_web_page_preview 	Boolean 			Optional 	Disables link previews for links in this message
    disable_notification 		Boolean 			Optional 	Sends the message silently. Users will receive a notification with no sound.
    reply_to_message_id 	    Integer 			Optional 	If the message is a reply, ID of the original message
#>
function Send-TelegramTextMessage {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = '#########:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$BotToken, #you could set a token right here if you wanted
        [Parameter(Mandatory = $true,
            HelpMessage = '-#########')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ChatID, #you could set a Chat ID right here if you wanted
        [Parameter(Mandatory = $true,
            HelpMessage = 'Text of the message to be sent')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter(Mandatory = $false,
            HelpMessage = 'HTML vs Markdown for message formatting')]
        [ValidateSet("Markdown","MarkdownV2", "HTML")]
        [string]$ParseMode = "Markdown", #set to Markdown by default
        [Parameter(Mandatory = $false,
            HelpMessage = 'Disables link previews')]
        [bool]$Preview = $false, #set to false by default
        [Parameter(Mandatory = $false,
            HelpMessage = 'Sends the message silently')]
        [bool]$Notification = $false #set to false by default
    )
    #------------------------------------------------------------------------
    $results = $true #assume the best
    #------------------------------------------------------------------------
    $payload = @{
        "chat_id"                   = $ChatID;
        "text"                      = $Message
        "parse_mode"                = $ParseMode;
        "disable_web_page_preview"  = $Preview;
        "disable_notification"      = $Notification
    }#payload
    #------------------------------------------------------------------------
    try {
        Write-Verbose -Message "Sending message..."
        $eval = Invoke-RestMethod `
            -Uri ("https://api.telegram.org/bot{0}/sendMessage" -f $BotToken) `
            -Method Post `
            -ContentType "application/json" `
            -Body (ConvertTo-Json -Compress -InputObject $payload) `
            -ErrorAction Stop
        if (!($eval.ok -eq "True")) {
            Write-Warning -Message "Message did not send successfully"
            $results = $false
        }#if_StatusDescription
    }#try_messageSend
    catch {
        Write-Warning "An error was encountered sending the Telegram message:"
        Write-Error $_
        $results = $false
    }#catch_messageSend
    return $results
    #------------------------------------------------------------------------
}#function_Send-TelegramTextMessage





################################################
##        Chia Log Parser for Telegram        ##
################################################

while ($true)
{

    if (Test-Path $logfilepath)
    {

        try {
            # Rename the log file to a working file so we can allow new events to write to the log while we process any existing ones.
            # Move-Item -force $logfilepath $logfiletemp
            Rename-Item -force $logfilepath -NewName $logfiletemp
        } catch {
            echo "Could not open logfile. File might be in use."
        }


    ################################################
    ##   Step 1:  Read eligible plot messages     ##
    ##   send the output to slack info webhook    ##
    ################################################

    $eplots = Get-content $logfiletemp | Select-String -Pattern '(?<!\s0\s)plots were eligible for farming'

    if ($plotsummary)
    {
        [int]$totalPlots = 0
        [int]$totalEligible = 0
        [float]$totalTime = 0.0
        [int]$totalProofs = 0
        [int]$goodLookups = 0
        [float]$goodLookupsAvg = 0.0
        [int]$mediumLookups = 0
        [float]$mediumLookupsAvg = 0.0
        [int]$badLookups = 0
        [float]$badLookupsAvg = 0.0

        foreach ($eplot in $eplots) 
        {
            $eplot -match "(.*) harvester .*(\d) plots .* farming (.*)\.\.\. Found (\d) .*me: (.*) s\. Total (.*) plots"

            $totalEligible += $Matches.2 -as [int]
            $totalTime += $Matches.5 -as [float]
            $totalProofs += $Matches.4 -as [int]
            #setting total to last record plot count
            $totalPlots = $Matches.6 -as [int]

            $time = $Matches.5 -as [float]
            if($time -gt 5) 
            {
                $badLookups++
                $badLookupsAvg += $time
            }elseif ($time -gt 2) {
                $mediumLookups++
                $mediumLookupsAvg += $time
            }else{
                $goodLookups++
                $goodLookupsAvg += $time
            }

        }

        [float]$avgtime = $totalTime / $eplots.count
        [float]$goodLookupsAvg = $goodLookupsAvg / $goodLookups
        [float]$mediumLookupsAvg = $mediumLookupsAvg / $mediumLookups
        [float]$badLookupsAvg = $badLookupsAvg / $badLookups
 
        $Summary = "*Plots Farming:* $totalPlots 
        *Plots Passed Filter:* $totalEligible (since last summary)
        *Average Time:* $avgTime
        *Proofs Found:* $totalProofs
        *Good lookups count:* $goodLookups
        *Average Time good lookups:* $goodLookupsAvg
        *Medium lookups count:* $mediumLookups
        *Average Time medium lookups:* $mediumLookupsAvg
        *Bad lookups count:* $badLookups
        *Average Time bad lookups:* $badLookupsAvg"

        $announce = 
        "--------------------------------------------------------
        *Plot summary for*
        $plotInfoDate
        -------------------------------------------------"

            Send-TelegramTextMessage `
                -BotToken $bot_token `
                -ChatID $id `
                -Message $announce `
                -ParseMode Markdown `
                -Preview $true `
                -Notification $true

            Send-TelegramTextMessage `
                -BotToken $bot_token `
                -ChatID $id `
                -Message $Summary `
                -ParseMode Markdown `
                -Preview $true `
                -Notification $true 
    }

    ###############################################
    ##   Step 2:  Read WARNING/ERROR messages    ##
    ##   send the output to slack alert webhook  ##
    ###############################################

    if ($errorlogs)
    {
        $errlog = Get-content $logfiletemp| Select-String -Pattern ': ERROR'
        if ($errlog.Count -gt 0) {
            $message_error = "*ERRORS:* $($errlog.Count) showing last 3: "

            foreach ($err in $errlog | Select-Object -Last 3)
            {

                $err = ($err | out-string)
                $err = $err.Substring(0, $err.IndexOf("Traceback"))

                $message_error += "
                ``` " + $err + " ``` "
            }
    
            $message_error.substring(0, [System.Math]::Min(1000, $message_error.Length))

            Send-TelegramTextMessage `
                -BotToken $bot_token `
                -ChatID $id `
                -Message $message_error  `
                -ParseMode MarkdownV2  `
                -Preview $true `
                -Notification $true 
        }
    }

    if ($warninglogs)
    {
        $warnlog = Get-content $logfiletemp| Select-String -Pattern ': WARNING'
        if ($warnlog.Count -gt 0)
        {
            $message_warning = "*WARNINGS:* $($warnlog.Count) showing last 3: "

            foreach ($warn in $warnlog | Select-Object -Last 3)
            {
                $warn = ($warn | out-string)
                $warn = $warn.Substring(0, $warn.IndexOf("Traceback"))

                $message_warning += "
                ``` " + $warn + " ``` "
            }

        $message_warning.substring(0, [System.Math]::Min(1000, $message_warning.Length))

        Send-TelegramTextMessage `
            -BotToken $bot_token `
            -ChatID $id `
            -Message $message_warning  `
            -ParseMode MarkdownV2 `
            -Preview $true `
            -Notification $true 
    
        }
    }

###############################################
##   Step 3:  Move the temp log file   ##
###############################################
        if ($archive){
            if (!(Test-Path -Path $archivedirectory))
            {
                $paramNewItem = @{
                    Path      = $archivedirectory
                    ItemType  = 'Directory'
                    Force     = $true
                }
                New-Item @paramNewItem
            }
            Move-Item -Path $logfiletemp "$archivedirectory$logfilearchive"
        }
    }
    else
    {
        Write-Host $(get-date) No log file to process.
    }
    Write-Host Sleeping for $frequency seconds
    Start-Sleep -Seconds $frequency
}




