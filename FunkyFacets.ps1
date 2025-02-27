Function FunkyFacetLink {
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

# The DID of the mention
#$mentionDid = "did:plc:hfgp6pj3akhqxntgqwramlbg"

# The text of the post
#$postText = "Hello Darry Borrans! direct from Invoke-RestMethod with funky facets"
$postText = "I have to admit, #Python is my new favorite language."

# Create the record data
$record = [ordered]@{
    "$type"     = "app.bsky.feed.post"
    "text"      = $postText
    "createdAt" = (Get-Date -Format 'o')
}

#making this an array for future expansion....;)
$facets = @()

# Mentions
#$usernameText = "Darry Borrans"

#$mention = FunkyFacetLink -Text $usernameText  -did $mentionDid -Message $postText -FacetType mention

$facets += $mention

# Tags
$PostTagText = "#Python"
$BckGrndTagName = 'PowerShell'


$tagFacet = _newFacetLink -Text $PostTagText -Message $postText -FacetType tag -Tag $BckGrndTagName

$facets += $tagFacet

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