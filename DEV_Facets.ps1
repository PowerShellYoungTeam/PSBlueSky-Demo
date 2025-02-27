<#
$postText = @"
just Ignore this, just playing with #PSBlueSky, multi-line strings and Markdown style links
[Home of the PowerShell Young Team](https://powershellyoungteam.github.io/)

#messingabout
"@#>


<#
#New-BskyPost $postText   -Verbose
$headers = (Get-BskySession).CreateHeader()

$postData = @{
    "$type" = "app.bsky.feed.post"
    "text" = "PowerShell Young Team Rulez!"
    "facets" = @(
        @{
            "index" = @{
                "byteEnd" = 0
                "byteStart" = 28
            }
            "features" = @(
                @{
                    "did" = "did:plc:k54achhksfhvlp5jd3rzv32h"
                    "$type" = "app.bsky.richtext.facet#mention"
                }
            )
        }
    )
    "createdAt" = "2023-08-07T05:31:12.156888Z"
}

$postDataJson = $postData | ConvertTo-Json -DEPTH 7



# Post to Bluesky using the API
Invoke-RestMethod -Uri "https://bsky.social/xrpc/com.atproto.repo.createRecord" -Method Post -Body $postDataJson  -Headers $headers#>
<#
# Define the post text
$postText = "PowerShell Young Team Rulez!"

# Define the facet for the username mention
$facet = @{
    index = @{
        byteStart = 28
        byteEnd = 48
    }
    features = @(
        @{
            type = "app.bsky.richtext.facet#mention"
            did = "did:plc:k54achhksfhvlp5jd3rzv32h"
        }
    )
}

# Create the post data with facets
$postData = @{
    "$type" = "app.bsky.feed.post"
    "repo" = "did:plc:k54achhksfhvlp5jd3rzv32h"  # Replace with your actual DID
    "collection" = "app.bsky.feed.post"  # Specify the collection
    "text" = $postText
    "facets" = @($facet)
    "createdAt" = "2023-08-07T05:31:12.156888Z"
}

# Convert the post data to JSON with increased depth
$postDataJson = $postData | ConvertTo-Json -Depth 10

# Get the headers for the API request
$headers = (Get-BskySession).CreateHeader()

# Post to Bluesky using the API
Invoke-RestMethod -Uri "https://bsky.social/xrpc/com.atproto.repo.createRecord" -Method Post -Body $postDataJson -Headers $headers

# Define the post text
$postText = "PowerShell Young Team Rulez!"

# Define the facet for the username mention
$facet = @{
    index = @{
        byteStart = 28
        byteEnd = 48
    }
    features = @(
        @{
            type = "app.bsky.richtext.facet#mention"
            did = "did:plc:k54achhksfhvlp5jd3rzv32h"
        }
    )
}

# Create the post data with facets
$record = @{
    "$type" = "app.bsky.feed.post"
    "text" = $postText
    "facets" = @($facet)
    "createdAt" = "2023-08-07T05:31:12.156888Z"
}

# Create the full data object including the repo and collection
$postData = @{
    "repo" = "did:plc:k54achhksfhvlp5jd3rzv32h"  # Replace with your actual DID
    "collection" = "app.bsky.feed.post"  # Specify the collection
    "record" = $record
}

# Convert the post data to JSON with increased depth
$postDataJson = $postData | ConvertTo-Json -Depth 10

# Get the headers for the API request
$headers = (Get-BskySession).CreateHeader()

# Post to Bluesky using the API
Invoke-RestMethod -Uri "https://bsky.social/xrpc/com.atproto.repo.createRecord" -Method Post -Body $postDataJson -Headers $headers



# Define the post text
$postText = "PowerShell Young Team Rulez!"

# Define the facet for the username mention
$facet = @{
    index = @{
        byteStart = 28
        byteEnd = 48
    }
    features = @(
        @{
            type = "app.bsky.richtext.facet#mention"
            did = "did:plc:k54achhksfhvlp5jd3rzv32h"
        }
    )
}

# Create the record data with facets
$record = @{
    "$type" = "app.bsky.feed.post"
    "text" = $postText
    "facets" = @($facet)
    "createdAt" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
}

# Create the full data object including the repo and collection
$postData = @{
    "repo" = "did:plc:k54achhksfhvlp5jd3rzv32h"  # Replace with your actual DID
    "collection" = "app.bsky.feed.post"  # Specify the collection
    "record" = $record
}

# Convert the post data to JSON with increased depth
$postDataJson = $postData | ConvertTo-Json -Depth 10

# Get the headers for the API request
$headers = (Get-BskySession).CreateHeader()

# Post to Bluesky using the API
Invoke-RestMethod -Uri "https://bsky.social/xrpc/com.atproto.repo.createRecord" -Method Post -Body $postDataJson -Headers $headers

#>
######### THIS WORKS!!!!
# https://bsky.app/profile/poshyoungteam.bsky.social/post/3lj4rdci6mv2r

# Define the post text
$postText = "Hello World! direct from Invoke-RestMethod"

# Create the record data
$record = @{
    "$type"     = "app.bsky.feed.post"
    "text"      = $postText
    "createdAt" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
}

# Create the full data object including the repo and collection
$postData = @{
    "repo"       = "did:plc:k54achhksfhvlp5jd3rzv32h"  # Replace with your actual DID
    "collection" = "app.bsky.feed.post"  # Specify the collection
    "record"     = $record
}

# Convert the post data to JSON with increased depth
$postDataJson = $postData | ConvertTo-Json -Depth 10

# Get the headers for the API request
$headers = (Get-BskySession).CreateHeader()

# Post to Bluesky using the API
Invoke-RestMethod -Uri "https://bsky.social/xrpc/com.atproto.repo.createRecord" -Method Post -Body $postDataJson -Headers $headers