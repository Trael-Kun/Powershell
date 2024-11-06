##adapted from https://mcpmag.com/articles/2016/06/09/display-gui-message-boxes-in-powershell.aspx?m=1
##modified by Bill, 3/8/21

##Variables
$msgBoxInput =  [System.Windows.MessageBox]::Show('Would you like to check your computer name?','Name Checker','YesNoCancel','Question')

  switch  ($msgBoxInput) {

  ## Displays computer name in a new message box
  'Yes' {
  [System.Windows.MessageBox]::Show($env:computername,'Name Checker','OK','Information')
  }

  ##Displays a farewell to the user
  'No' {
  [System.Windows.MessageBox]::Show("Goodbye $env:UserName",'Name Checker','OK','Warning')
  }
  
  ##closes script without further action
  'Cancel' {
  Exit
  }
  }
  Write-Host "Have a nice day"
