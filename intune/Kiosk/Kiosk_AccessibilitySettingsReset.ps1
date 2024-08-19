#NAA Kiosk User Settings reset

$RegCtrlPanel		= 'registry::HKEY_CURRENT_USER\Control Panel'
$RegAccessibility	= "$RegCtrlPanel\Accessibility"
$RegCursors			= "$RegCtrlPanel\Cursors"
$RegMouse			= "$RegCtrlPanel\Mouse"
$RegClocks			= "$RegCtrlPanel\TimeDate\AdditionalClocks"
$CursorsDir			= "$env:WINDIR\cursors"

#from .reg
$SmoothMouseXCurve	= '0
0
0
0
0
0
0
0
21
110
0
0
0
0
0
0
0
64
1
0
0
0
0
0
41
220
3
0
0
0
0
0
0
0
40
0
0
0
0
0
'
$SmoothMouseYCurve	= '0
0
0
0
0
0
0
0
253
17
1
0
0
0
0
0
0
36
4
0
0
0
0
0
0
252
18
0
0
0
0
0
0
192
187
1
0
0
0
0
'
<#from ([System.BitConverter]::ToString([byte[]](Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name $Name).$Name))
$MouseXcurve = 00-00-00-00-00-00-00-00-15-6E-00-00-00-00-00-00-00-40-01-00-00-00-00-00-29-DC-03-00-00-00-00-00-00-00-28-00-00-00-00-00
$MouseYcurve = 00-00-00-00-00-00-00-00-FD-11-01-00-00-00-00-00-00-24-04-00-00-00-00-00-00-FC-12-00-00-00-00-00-00-C0-BB-01-00-00-00-00
#>

$RegEdits = @(
	@{Action='Add';		Path="$RegAccessibility";						Property='MessageDuration';							Type='DWord';	Value=5									}
	@{Action='Add';		Path="$RegAccessibility";						Property='MinimumHitRadius';						Type='DWord';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\AudioDescription";		Property='On';										Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\Blind Access";			Property='On';										Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\HighContrast";			Property='Flags';									Type='String';	Value=126								}
	@{Action='Add';		Path="$RegAccessibility\HighContrast";			Property='High Contrast Scheme';					Type='String';	Value=''								}
	@{Action='Add';		Path="$RegAccessibility\HighContrast";			Property='Previous High Contrast Scheme MUI Value';	Type='String';	Value=''								}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Preference";	Property='On';										Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='AutoRepeatDelay';							Type='String';	Value=1000								}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='AutoRepeatRate';							Type='String';	Value=500								}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='BounceTime';								Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='DelayBeforeAcceptance';					Type='String';	Value=1000								}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='Flags';									Type='String';	Value=126								}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='Last BounceKey Setting';					Type='DWord';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='Last Valid Delay';						Type='DWord';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='Last Valid Repeat';						Type='DWord';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\Keyboard Response";		Property='Last Valid Wait';							Type='DWord';	Value=1000								}
	@{Action='Add';		Path="$RegAccessibility\MouseKeys";				Property='Flags';									Type='String';	Value=62								}
	@{Action='Add';		Path="$RegAccessibility\MouseKeys";				Property='MaximumSpeed';							Type='String';	Value=80								}
	@{Action='Add';		Path="$RegAccessibility\MouseKeys";				Property='TimeToMaximumSpeed';						Type='String';	Value=3000								}
	@{Action='Add';		Path="$RegAccessibility\On";					Property='Locale';									Type='DWord';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\On";					Property='On';										Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\ShowSounds";			Property='On';										Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\SlateLaunch";			Property='ATapp';									Type='String';	Value='narrator'						}
	@{Action='Add';		Path="$RegAccessibility\SlateLaunch";			Property='String';									Type='DWord';	Value=1									}
	@{Action='Add';		Path="$RegAccessibility\SoundSentry";			Property='Flags';									Type='String';	Value=2									}
	@{Action='Add';		Path="$RegAccessibility\SoundSentry";			Property='FSTextEffect';							Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\SoundSentry";			Property='TextEffect';								Type='String';	Value=0									}
	@{Action='Add';		Path="$RegAccessibility\SoundSentry";			Property='WindowsEffect';							Type='String';	Value=1									}
	@{Action='Add';		Path="$RegAccessibility\StickyKeys";			Property='Flags';									Type='String';	Value=510								}
	@{Action='Add';		Path="$RegAccessibility\TimeOut";				Property='Flags';									Type='String';	Value=2									}
	@{Action='Add';		Path="$RegAccessibility\TimeOut";				Property='TimeToWait';								Type='String';	Value=300000							}
	@{Action='Add';		Path="$RegAccessibility\ToggleKeys";			Property='Flags';									Type='String';	Value=63								}
	@{Action='Add';		Path="$RegCursors";								Property=$null;										Type='String';	Value="Windows Default"					}		
	@{Action='Add';		Path="$RegCursors";								Property='AppStarting';								Type='String';	Value="$CursorsDir\aero_working.ani"	}	
	@{Action='Add';		Path="$RegCursors";								Property='Arrow';									Type='String';	Value="$CursorsDir\aero_arrow.cur"		}	
	@{Action='Add';		Path="$RegCursors";								Property='ContactVisualization';					Type='DWord';	Value=1									}	
	@{Action='Add';		Path="$RegCursors";								Property='Crosshair';								Type='String';	Value=''								}	
	@{Action='Add';		Path="$RegCursors";								Property='CursorBaseSize';							Type='DWord';	Value=32								}	
	@{Action='Add';		Path="$RegCursors";								Property='GestureVisualization';					Type='DWord';	Value=31								}	
	@{Action='Add';		Path="$RegCursors";								Property='Hand';									Type='String';	Value="$CursorsDir\aero_link.cur"		}	
	@{Action='Add';		Path="$RegCursors";								Property='Help';									Type='String';	Value="$CursorsDir\aero_helpsel.cur"	}	
	@{Action='Add';		Path="$RegCursors";								Property='IBeam';									Type='String';	Value=""								}	
	@{Action='Add';		Path="$RegCursors";								Property='No';										Type='String';	Value="$CursorsDir\aero_unavail.cur"	}	
	@{Action='Add';		Path="$RegCursors";								Property='NWPen';									Type='String';	Value="$CursorsDir\aero_pen.cur"		}	
	@{Action='Add';		Path="$RegCursors";								Property='Scheme Source';							Type='DWord';	Value=2									}	
	@{Action='Add';		Path="$RegCursors";								Property='SizeAll';									Type='String';	Value="$CursorsDir\aero_move.cur"		}	
	@{Action='Add';		Path="$RegCursors";								Property='SizeNESW';								Type='String';	Value="$CursorsDir\aero_nesw.cur"		}	
	@{Action='Add';		Path="$RegCursors";								Property='SizeNS';									Type='String';	Value="$CursorsDir\aero_ns.cur"			}	
	@{Action='Add';		Path="$RegCursors";								Property='SizeNWSE';								Type='String';	Value="$CursorsDir\aero_nwse.cur"		}	
	@{Action='Add';		Path="$RegCursors";								Property='SizeWE';									Type='String';	Value="$CursorsDir\aero_ew.cur"			}	
	@{Action='Add';		Path="$RegCursors";								Property='UpArrow';									Type='String';	Value="$CursorsDir\aero_up.cur"			}	
	@{Action='Add';		Path="$RegCursors";								Property='Wait';									Type='String';	Value="$CursorsDir\aero_busy.ani"		}	
	@{Action='Add';		Path="$RegMouse";								Property='ActiveWindowTracking';					Type='DWord';	Value=0									}	
	@{Action='Add';		Path="$RegMouse";								Property='Beep';									Type='String';	Value='No'								}	
	@{Action='Add';		Path="$RegMouse";								Property='DoubleClickHeight';						Type='String';	Value=4									}	
	@{Action='Add';		Path="$RegMouse";								Property='DoubleClickSpeed';						Type='String';	Value=500								}	
	@{Action='Add';		Path="$RegMouse";								Property='DoubleClickWidth';						Type='String';	Value=4									}	
	@{Action='Add';		Path="$RegMouse";								Property='ExtendedSounds';							Type='String';	Value='No'								}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseHoverHeight';						Type='String';	Value=4									}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseHoverTime';							Type='String';	Value=400								}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseHoverWidth';							Type='String';	Value=4									}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseSensitivity';						Type='String';	Value=10								}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseSpeed';								Type='String';	Value=1									}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseThreshold1';							Type='String';	Value=6									}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseThreshold2';							Type='String';	Value=10								}	
	@{Action='Add';		Path="$RegMouse";								Property='MouseTrails';								Type='String';	Value=0									}	
	@{Action='Add';		Path="$RegMouse";								Property='SnapToDefaultButton';						Type='String';	Value=0									}	
	@{Action='Add';		Path="$RegMouse";								Property='SwapMouseButtons';						Type='String';	Value=0 								}
	@{Action='Add';		Path="$RegMouse";								Property='SmoothMouseXCurve';						Type='Binary';	Value=$SmoothMouseXCurve 				}
	@{Action='Add';		Path="$RegMouse";								Property='SmoothMouseYCurve';						Type='Binary';	Value=$SmoothMouseYCurve 				}
	@{Action='Remove';	Path="$RegClocks";								Property=$null;										Type=$null;		Value=$null 							}
)

foreach ($RegEdit in $RegEdits) {
	if ($($RegEdit.Action) -eq 'Remove' ) {											#does it need to be removed?
		if ($null -eq $RegEdit.Property) {											#is it a key?
			Remove-Item -Path $RegEdit.Path -Recurse -Force								#remove the whole key
		} else {																	#is it a property?
			Remove-ItemProperty -Path $RegEdit.Path -Name $RegEdit.Property -Force	#remove the property
		}
	}
	$Setting	= Get-ItemProperty -Path $RegEdit.Path  -Name $RegEdit.Property -ErrorAction SilentlyContinue
	if ($null -eq $Setting) {																														#if path not exist
		$Parent	= Split-Path -Path $RegEdit.Path -Parent																							#get 1st part of path
		$Leaf	= Split-Path -Path $RegEdit.Path -Leaf																								#get last part of path
		New-Item -Path $Parent -Name $Leaf -Force -ErrorAction Continue																				#create the path
		New-ItemProperty -Path $RegEdit.Path -Name $RegEdit.Property -PropertyType $RegEdit.Type -Value $RegEdit.Value -Force -ErrorAction Continue	#create the item
	} elseif ($($Setting.$($RegEdit.Property)) -ne $RegEdit.Value)  {																				#if exists, but has wrong value
		Set-ItemProperty -Path $RegEdit.Path -Name $RegEdit.Property -Value $RegEdit.Value -Force -ErrorAction Continue								#set correct value
	}
}
