Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PSBlueSky GUI"
$form.Size = New-Object System.Drawing.Size(600, 400)

# Create a textbox to display output
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.ScrollBars = 'Vertical'
$outputBox.Size = New-Object System.Drawing.Size(560, 200)
$outputBox.Location = New-Object System.Drawing.Point(10, 150)
$form.Controls.Add($outputBox)

# Function to update output
function Update-Output {
    param (
        [string]$text
    )
    $outputBox.AppendText("$text`n")
    Write-Output $text
}

# Create buttons and their click event handlers
$buttons = @(
    @{Name = "Get-bskyfeed"; Location = New-Object System.Drawing.Point(10, 10) },
    @{Name = "Get-bskprofile"; Location = New-Object System.Drawing.Point(150, 10) },
    @{Name = "Get-bskytimeline"; Location = New-Object System.Drawing.Point(290, 10) },
    @{Name = "Get-bskynotification"; Location = New-Object System.Drawing.Point(430, 10) },
    @{Name = "Get-bskyfollowers"; Location = New-Object System.Drawing.Point(10, 50) },
    @{Name = "Get-bskyfollowing"; Location = New-Object System.Drawing.Point(150, 50) }
)

foreach ($buttonInfo in $buttons) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $buttonInfo.Name
    $button.Size = New-Object System.Drawing.Size(120, 30)
    $button.Location = $buttonInfo.Location
    $button.Add_Click({
            $command = $button.Text
            $output = & $command
            Update-Output $output
        })
    $form.Controls.Add($button)
}

# Show the form
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()