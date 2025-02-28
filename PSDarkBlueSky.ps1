Function FunkyFacetLink {
    # this was taken from PSBlueSky (https://github.com/jdhitsolutions/PSBluesky/blob/main/functions/New-PSBlueSkyPost.ps1)
    # Documentation: https://docs.bsky.app/docs/advanced-guides/post-richtext
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'The Bluesky message with the links')]
        [string]$Message,
        [Parameter(Mandatory, HelpMessage = 'The text of the link')]
        [string]$Text,
        [Parameter(HelpMessage = 'The URI of the link')]
        [string]$Uri,
        [Parameter(HelpMessage = 'The DID of the mention')]
        [string]$DiD,
        [Parameter(HelpMessage = 'The Tag text')]
        [string]$Tag,
        [ValidateSet('link', 'mention', 'tag')]
        [string]$FacetType = 'link'
    )


    $PSDefaultParameterValues['_verbose:block'] = 'PRIVATE'
    $feature = Switch ($FacetType) {
        'link' {
            [PSCustomObject]@{
                '$type' = 'app.bsky.richtext.facet#link'
                uri     = $Uri
            }
        }
        'mention' {
            [PSCustomObject]@{
                '$type' = 'app.bsky.richtext.facet#mention'
                did     = $DiD
            }
        }
        'tag' {
            [PSCustomObject]@{
                '$type' = 'app.bsky.richtext.facet#tag'
                tag     = $Tag
            }
        }
    }

    if ($text -match '\[|\]|\(\)') {
        $text = [regex]::Escape($text)
    }
    #the comparison test is case-sensitive
    if (([regex]$Text).IsMatch($Message)) {
        #properties of the facet object are also case-sensitive
        $m = ([regex]$Text).match($Message)
        [PSCustomObject]@{
            index    = [ordered]@{
                byteStart = $m.index
                byteEnd   = ($m.length) + ($m.index)
            }
            features = @(
                $feature
            )
        }
    }
    else {
        Write-Warning ($strings.TextNotFound -f $Text, $Message)
    }
}

######## MAIN BIT ########
# Load required assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PSDarkBlueSky"
$form.Size = New-Object System.Drawing.Size(700, 400)

# API URL
$labelApiUrl = New-Object System.Windows.Forms.Label
$labelApiUrl.Text = "API URL:"
$labelApiUrl.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelApiUrl)

$textBoxApiUrl = New-Object System.Windows.Forms.TextBox
$textBoxApiUrl.Text = "https://bsky.social/xrpc/com.atproto.repo.createRecord"
$textBoxApiUrl.Location = New-Object System.Drawing.Point(100, 20)
$textBoxApiUrl.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($textBoxApiUrl)

# DID
$labelDid = New-Object System.Windows.Forms.Label
$labelDid.Text = "DID:"
$labelDid.Location = New-Object System.Drawing.Point(10, 50)
$form.Controls.Add($labelDid)

$textBoxDid = New-Object System.Windows.Forms.TextBox
$textBoxDid.Location = New-Object System.Drawing.Point(100, 50)
$textBoxDid.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($textBoxDid)

$buttonGetDid = New-Object System.Windows.Forms.Button
$buttonGetDid.Text = "Get DID"
$buttonGetDid.Location = New-Object System.Drawing.Point(410, 50)
$buttonGetDid.Add_Click({
        $username = $textBoxDid.Text
        $did = Get-BskyAccountDid -Username $username
        $textBoxDid.Text = $did
    })
$form.Controls.Add($buttonGetDid)

# Post Text
$labelPostText = New-Object System.Windows.Forms.Label
$labelPostText.Text = "Post Text:"
$labelPostText.Location = New-Object System.Drawing.Point(10, 80)
$form.Controls.Add($labelPostText)

$textBoxPostText = New-Object System.Windows.Forms.TextBox
$textBoxPostText.Location = New-Object System.Drawing.Point(100, 80)
$textBoxPostText.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($textBoxPostText)

# Mentions
$labelMentionDid = New-Object System.Windows.Forms.Label
$labelMentionDid.Text = "Mention DID:"
$labelMentionDid.Location = New-Object System.Drawing.Point(10, 110)
$form.Controls.Add($labelMentionDid)

$textBoxMentionDid = New-Object System.Windows.Forms.TextBox
$textBoxMentionDid.Location = New-Object System.Drawing.Point(100, 110)
$textBoxMentionDid.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($textBoxMentionDid)

$buttonGetMentionDid = New-Object System.Windows.Forms.Button
$buttonGetMentionDid.Text = "Get Mention DID"
$buttonGetMentionDid.Location = New-Object System.Drawing.Point(410, 110)
$buttonGetMentionDid.Add_Click({
        $username = $textBoxMentionDid.Text
        $mentionDid = Get-BskyAccountDid -Username $username
        $textBoxMentionDid.Text = $mentionDid
    })
$form.Controls.Add($buttonGetMentionDid)

$labelUsernameText = New-Object System.Windows.Forms.Label
$labelUsernameText.Text = "Username Text:"
$labelUsernameText.Location = New-Object System.Drawing.Point(10, 140)
$form.Controls.Add($labelUsernameText)

$textBoxUsernameText = New-Object System.Windows.Forms.TextBox
$textBoxUsernameText.Location = New-Object System.Drawing.Point(100, 140)
$textBoxUsernameText.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($textBoxUsernameText)

$buttonAddMention = New-Object System.Windows.Forms.Button
$buttonAddMention.Text = "Add Mention"
$buttonAddMention.Location = New-Object System.Drawing.Point(10, 170)
$buttonAddMention.Add_Click({
        $mention = FunkyFacetLink -Text $textBoxUsernameText.Text -did $textBoxMentionDid.Text -Message $textBoxPostText.Text -FacetType mention
        $facets += $mention
    })
$form.Controls.Add($buttonAddMention)

# Tags
$labelPostTagText = New-Object System.Windows.Forms.Label
$labelPostTagText.Text = "Post Tag Text:"
$labelPostTagText.Location = New-Object System.Drawing.Point(10, 200)
$form.Controls.Add($labelPostTagText)

$textBoxPostTagText = New-Object System.Windows.Forms.TextBox
$textBoxPostTagText.Location = New-Object System.Drawing.Point(100, 200)
$textBoxPostTagText.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($textBoxPostTagText)

$labelBckGrndTagName = New-Object System.Windows.Forms.Label
$labelBckGrndTagName.Text = "Background Tag Name:"
$labelBckGrndTagName.Location = New-Object System.Drawing.Point(10, 230)
$form.Controls.Add($labelBckGrndTagName)

$textBoxBckGrndTagName = New-Object System.Windows.Forms.TextBox
$textBoxBckGrndTagName.Location = New-Object System.Drawing.Point(100, 230)
$textBoxBckGrndTagName.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($textBoxBckGrndTagName)

$buttonAddTag = New-Object System.Windows.Forms.Button
$buttonAddTag.Text = "Add Tag"
$buttonAddTag.Location = New-Object System.Drawing.Point(10, 260)
$buttonAddTag.Add_Click({
        $tagFacet = FunkyFacetLink -Text $textBoxPostTagText.Text -Message $textBoxPostText.Text -FacetType tag -Tag $textBoxBckGrndTagName.Text
        $facets += $tagFacet
    })
$form.Controls.Add($buttonAddTag)

# Post Button
$buttonPost = New-Object System.Windows.Forms.Button
$buttonPost.Text = "Post"
$buttonPost.Location = New-Object System.Drawing.Point(10, 290)
$buttonPost.Add_Click({
        $apiUrl = $textBoxApiUrl.Text
        $did = $textBoxDid.Text
        $postText = $textBoxPostText.Text

        # Create the record data
        $record = [ordered]@{
            "$type"     = "app.bsky.feed.post"
            "text"      = $postText
            "createdAt" = (Get-Date -Format 'o')
        }

        $record.Add('facets', $facets)
        # Create the full data object including the repo and collection name
        $body = @{
            repo       = $did
            collection = 'app.bsky.feed.post'
            record     = $record
        } | ConvertTo-Json -Depth 7

        # Get the headers for the API request
        $headers = (Get-BskySession).CreateHeader()

        # Post to Bluesky using the API
        Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -Headers $headers
    })
$form.Controls.Add($buttonPost)

# Show the form
$form.ShowDialog()
