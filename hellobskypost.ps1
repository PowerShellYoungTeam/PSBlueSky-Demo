Function FunkyFacetLink {
    # this was nabbed from PSBlueSky (_newFacetLink in helpers.ps1)
    # https://docs.bsky.app/docs/advanced-guides/post-richtext
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

#API URL
$apiUrl = "https://bsky.social/xrpc/com.atproto.repo.createRecord"

# ma DID
$did = "did:plc:k54achhksfhvlp5jd3rzv32h"

# The text of the post
#$postText = "Hello Darry Borrans! direct from Invoke-RestMethod with funky facets"
$postText = "Hello interesting new Bluesky Account created today: open-pwsh! welcome to the best Community in Tech Buddy!"

# Create the record data
$record = [ordered]@{
    "$type"     = "app.bsky.feed.post"
    "text"      = $postText
    "createdAt" = (Get-Date -Format 'o')
}

#making this an array for future expansion....;)
$facets = @()

# Mentions
$usernameText = "interesting new Bluesky Account created today: open-pwsh!"
# The DID of the mention
$mentionDid = "did:plc:qmexb27iwllabcg3rwzxakl7"

$mention = FunkyFacetLink -Text $usernameText  -did $mentionDid -Message $postText -FacetType mention

$facets += $mention

# Tags
$PostTagText = "best Community in Tech"
$BckGrndTagName = 'PowerShell'

$tagFacet = FunkyFacetLink  -Text $PostTagText -Message $postText -FacetType tag -Tag $BckGrndTagName

$facets += $tagFacet

#Links

$linkText = "How PowerShell and the Right Mindset Can Transform Your IT Career The PS Podcast E161 Steven Wight"
$LinkUri = "https://www.youtube.com/watch?v=klsOxHtG3KE&list=PL1mL90yFExsjUS8DRkzfLUcHds7vlxqgM&index=1&t=83s"

$linkFacet = FunkyFacetLink -Text $linkText -Uri $LinkUri -Message $postText -FacetType link

#$facets += $linkFacet

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
