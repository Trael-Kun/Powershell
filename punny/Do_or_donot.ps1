DO {
    if ($xwing -in $swamp) {
        DO {Move-Item $xwing -Destination $land -Force}
        UNTIL ($swamp -notcontains $xwing)
    }
}
#try{}
