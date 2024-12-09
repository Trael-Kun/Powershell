#Variables
$A = ' '
$B = '-'
$C = '`'
$D = '_'
$E = "'"
$F = '|'
$G = '|  |'
$H = ';'
$I = ','
$K = '.'
$L = '|__|'
$M = '8'
$N = '"'
$O = '('
$P = ')'
$Q = '\'
$R = '/'
$S = 'o'
$T = ':'
$U = '='


$AA = $A*2
$AB = $A*3
$AC = $A*4
$AD = $A*5
$AE = $A*6
$AF = $A*7
$AG = $A*8
$AH = $A*9
$AI = $A*10
$AJ = $A*11
$AK = $A*12
$AL = $A*14
$AM = $A*15
$AN = $A*16
$AO = $A*17
$AP = $A*19
$AQ = $A*20
$AR = $A*22
$AS = $A*25
$AT = $A*28
$AU = $A*30
$BA = $B*2
$BB = $B*3
$BC = $B*4
$CA = $C*2
$CB = $A+$C
$CC = $C+$A
$CD = $C+$B
$CE = $AA+$CD
$DA = $D*2
$DB = $D*3
$DC = $D*5
$DD = $D*6
$DE = $D*7
$DF = $D*11
$DG = $D+$A
$DH = $D+$AA
$EA = $E*2
$EB = $E+$A
$EC = $E+$AA
$ED = $B+$E+$AB
$FA = $A*57+$F
$FB = $F*2
$FC = $AF+$FB
$FD = $F*3
$FE = $A+$D+$F
$FF = $A+$F
$FG = $AA+$F
$FH = $F+$A
$FI = $F+$E
$FJ = $F+$AA
$FK = $F+$AB
$FL = $F+$AC
$FM = $F+$AE
$FN = $F+$AF
$FO = $F+$AJ
$FP = $FB+$AJ
$FQ = $AF+$F
$GA = $G+$A
$GB = $GA+$FO
$HA = $A+$H
$HB = $H+$AD
$HC = $H+$AT
$HD = $AM+$H
$IA = $AR+$I
$IB = $I*2
$IC = $I+$E
$ID = $C+$IC
$IE = $HA+$ID
$IF = $I+$ED
$IG = $IF+$H
$IH = $I+$B
$II = $IH+$E
$IJ = $I+$H
$JA = $AC+$G
$JB = $JA+$AD
$JC = $K+$E
$KA = $K*2
$KB = $K*3
$KC = $K+$A
$KD = $K+$AB
$KE = $K+$AC
$KF = $C+$K
$KG = $D+$K
$KH = $D+$KA
$KI = $KA+$DA
$KJ = $KH+$B+$E
$KK = $KD+$BA+$KI+$KA
$KL = $ED+$JC
$KM = $B+$K
$KN = $K+$KM
$KO = $K+$BA
$KP = $A+$KF
$KQ = $KG+$KM
$KR = $K+$DA
$KS = $K+$D
$KT = $AA+$K+$DF
$KU = $AC+$JC
$KV = $C+$KC
$LA = $L+$AD
$MA = $M*2
$NA = $C+$N
$PA = $G+$D+$P+$FG
$PB = $P+$AB
$QA = $D+$Q
$QB = $A+$Q
$QC = $AA+$Q
$QD = $Q+$DA
$QZ = $R+$AA
$RA = $R+$AF
$RB = $A+$R
$RC = $QZ+$DC+$QC
$RD = $AA+$R
$RE = $R+$RD+$QA+$QC
$RF = $R+$AB
$RG = $RF+$Q
$RH = $R+$DA+$R+$AD+$QD+$Q
$SA = $MA+$S+$Q
$TA = $A+$T
$UA = $U*2
$V = $AD+$T+$AC+$T+'!'+$A
$W = '^'+$QC
$WA = $AA+$G
$WB = $AB+$DH+$GH+$Q



$Ackbar = @(
$AT+$DA+$KB+$B*12+$KS
$AS+$II+$AP+$CD+$K
$IA+$B+$E+$AS+$KF
$AQ+$IC+$AT+$IH+$KF
$AP+$H+$AU+$CD+$EB+$KF
$A*18+$H+$A*33+$KN+$QB
$AO+$H+$A*27+$KN+$AC+$CD+$EC+$Q
$AN+$HC+$CD+$E+$AI+$Q
$HD+$A*42+$KF
$HD+$A*43+$T
$AL+$H+$A*44+$F
$A*13+$H+$A*45+$H
$AK+$HC+$DB+$AL+$H
$AJ+$H+$A*24+$IH+$H+$B+$E+$IC+$K+$KF+$DA+$AI+$F
$AF+$D+$KA+$H+$AR+$II+$IE+$K+$ID+$KO+$KV+$KV
$AE+$R*3+$H+$AJ+$IF+$KV+$IG+$C+$IE+$IC+$D+$KO+$U+$T+$AE+$R
$AD+$F+$EA+$T+$AI+$IC+$AG+$T+$AD+$H+$CC+$H+$IJ+$IB+$B+$E+$KQ+$D+$KF+$AB+$IC
$AD+$EC+$T+$AH+$H+$KQ+$AE+$KF+$AC+$T+$EB+$H*3+$E+$K+'ee'+$KE+$Q+$FJ+$R
$AE+$Q+$JC+$AC+$KJ+$R+$M+$S+$KC+$KF+$V+$EB+$E+$T+$M*4+$PB+$FB+$RB
$FC+$CD+$EA+$AC+$Q*2+$SA+$TA+$V+$T+$AA+$T+$C+$N*2+$E+$AC+$H*2+$R
$FC+$AH+$Q+$N+$SA+$HB+$KF+$AC+$Q+$KP+$KP+$AE+$H+$IC
$AF+$R+$PB+$DB+$AC+$KF+$N+$E+$R+$O+$BA+$KA+$DG+$KF+$AC+$KF+$KF+$CE+$KA+$B+$EB+$H+$BA+$K
$AF+$Q+$O+$K+$U+$N*5+$UA+$KA+$CB+$E+$B+$E+$AD+$KF+$FM+$CD+$CD+$KI+$K+$B+$EB+$KF+$KP
$AG+$F+$AI+$NA+$UA+$KR+$AE+$P+$AQ+$P+$AA+$H
$AG+$FK+$FP+$NA+$U*3+$A+$E+$AP+$K+$EC+$JC
$AG+$R+$Q+$IB+$FD+$GB+$Q+$AN+$K+$KL
$AG+$FH+$FD+$E+$F+$EB+$FI+$FI+$AJ+$Q+$F+$AK+$A+$K+$ED+$KG+$EB+$Q
$AG+$F+$FF+$Q+$EB+$G+$AJ+$FB+$A+$FP+$JC+$KU+$AC+$Q
$AG+$EB+$F+$QB+$A+$EB+$F+$EC+$KD+$CA+$BA+$CB+$FH+$FB+$AH+$JC+$KU+$AF+$Q
$AI+$E+$FG+$AA+$EB+$FJ+$KE+$CA+$B+$KA+$DG+$FJ+$H+$KU+$KU+$AI+$KF
$AF+$KG+$BA+$IJ+$KF+$AF+$K+$AA+$BA+$AA+$KB+$KS+$I+$KL+$KU+$AL+$KF+$DA
$AD+$I+$EC+$IC+$H+$AB+$KF+$AD+$KK+$BA+$E+$JC+$KU+$AN+$DA+$R+$QA
$AB+$IG+$HA+$AD+$FL+$KK+$KG+$E+$AD+$JC+$AN+$IC+$AD+$KF
$RD+$AC+$H+$TA+$AD+$HB+$KE+$B+$KA+$A+$KG+$E+$AD+$KG+$E+$AO+$R+$AH+$C
$RB+$AD+$T+$CE+$K+$DG+$FL+$KE+$KG+$BA+$E+$AD+$KG+$E+$AP+$F
$RA+$KF+$AC+$C+$BA+$KB+$KO+$EA+$AF+$KG+$E+$AR+$F
$AI+$KF+$D+$AL+$KJ+$AS+$F
$AK+$CB+$B+$KA+$D*4+$KB+$B+$EA+$AU+$F
$FA
$FA
$AD+$DA+$KT+$KR+$AD+$DE+$K+$AG+$DB
$AC+$GB+$O+$DG+$PB+$RA+$FN+$RG
$JA+$CB+$BB+$G+$BC+$C+$F+$RF+$FK+$O+$BC+$C+$AE+$QZ+$W
$JB+$G+$AJ+$Q+$AB+$Q+$AH+$RE
$JB+$G+$AF+$K+$BC+$PB+$FN+$RC
$AC+$LA+$L+$KV+$DE+$RA+$RH

$KT+$KA+$DD+$AI+$DB+$AE+$K+$DD+$AC+$DA
$FG+$AJ+$FB+$WB+$AG+$RG+$AD+$F+$WB+$WA
$AA+$C+$BB+$G+$BC+$C+$PA+$AE+$QZ+$W+$AC+$PA+$A+$G
$AE+$G+$AD+$FM+$R+$AE+$RE+$AB+$FK+$DB+$QZ+$G
$AE+$G+$AD+$G+$Q+$QC+$BC+$K+$RC+$WA+$AE+$L
$AE+$LA+$F+$FE+$KP+$DC+$RH+$FF+$FE+$AE+$O+$DA+$P
)
