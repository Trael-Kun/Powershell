#try{
    if ($xwing -in $swamp) {
        DO {Move-Item $xwing -Force}
        UNTIL ($swamp -notcontains $xwing)
    }
}
