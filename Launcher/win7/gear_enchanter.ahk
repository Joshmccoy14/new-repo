#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#include findtext2.ahk
CoordMode, ToolTip, Screen
CoordMode, Mouse, Screen

;==========Global_Variables=====================================================================================
global startEnchantingProcessFromBeginning := False 
global EnchantWeapon := False
global EnchantArmor := False
global IHaveERep := True  ; Enable searching for level 1-19 in inventory (checked by default)
global IHaveEProtect := True  ; Enable switching to eprotect method at level 17 (checked by default)

; Statistics variables
global statsStartTime := 0
global eRepairUsed := 0
global eProtectUsed := 0
global r7DefenseCubeUsed := 0
global r7StrikeCubeUsed := 0
global r7FortuneDefenseCubeUsed := 0
global r7FortuneStrikeCubeUsed := 0
global level20Found := 0
global enchantingActive := false
global statsExpanded := true  ; Track if statistics section is expanded

global erepair:="|<erepair>*147$29.zzjzzzzTzzyzzzzzzyTzzDbxzARnzy71szwM1MCnU1syC01tss018FU07cC00Nsm00lvU01mT000Hu000nk001/s006Ts00Wys003sz05zkTzzy01zy000001"
global r7defensecube:="|<r7defensecube>5A8DA9-0.83$26.09ww0/kyk9wDD4DS7kwTVsT7bUXC3w/7kS2stk0YEy0967021U00g9U08"
r7defensecube.="|<r7defensecube>619AB8-0.90$29.00L0002Sk000sc0083U01s720UVUw0sD1k3kA800A1s00y3U0EFk0007k006200000004000080008"
global r7strikecube:="|<r7strikecube>AD585B-0.85$26.2T3nl3LVtD7sS7lts8nUz2lw70aCQ09YDU2FVk0UM00/2M02k7004Ek08"
r7strikecube.="|<r7strikecube>BD5E62-0.90$23.00000DU01TM00wI041k4w3VEEkSQ7Uts64060w4T1k88s0F3s0310020020E08"
global r7fortunedefensecube:="|<r7fortunedefensecube>8EE3E5-0.85$29.0000000000000000000003U000Ts003kQ00TUS01zw807y000zkDU0zVzU0Tzy00Pzs007z00U3w00U0U00000030001"
r7fortunedefensecube.="|<r7fortunedefensecube>9BF9FB-0.67$29.200CA4008MQ3s0lwTw3bvyT73zkDz3zyDyDzUzwTsDzsTtzzkDzzbcDzw6M7zkBE1y0Pk0E0Lk000c"
r7fortunedefensecube.="|<>71EFFE-0.70$29.000440004401w000Dz021zTU07t7k0Tz707zkM0DwDw0Dwzw0Dzzk47zy0A3zs0c0z00M0808s0001y0001z0003s000Dl003DA006DM00ADM00Q7s00w3s01"
global r7fortunestrikecube:="|<r7fortunestrikecube>F89AB2-0.74$26.300A1EDV5qDy1MzvwFTvDsDzYw7zkM3zV7kDxzy1wTwI6Tw10Dy0uky0D3001s800Tt008"
r7fortunestrikecube.="|<>E6BAB6-0.75$25.s7U1yDy1zzrkzzYzxzzbzzw7zzkzzjxzvlzzssTzkA1zk60DU3V000s000C0007g003s001t000U"

global eprotect:="|<eprotect>8DD5B2-0.79$26.00U0008002000000M01U04As003lw20kz1OMzwCQDz0+Dzt3bzy0Xzz01zzl0TzwNDzzm8"
eprotect.="|<eprotect>95E1BD-0.79$29.00000001000100002000400000060030083+0005Xs40ADkK4ltsQ73zk0ETzm0dyTU77zy0QTzwE8"

global Level1:="|<Level1>797774-0.90$8.0GAVyG4VU"
global Level2:="|<Level2>666564-0.84$9.0tB8Tr9VDU"
Level2.="|<Level2>818181-0.74$9.0tB8Dq9VDU"
global Level3:="|<Level3>81807D-0.86$10.0sUW2yMUWCU"
global Level4:="|<Level4>797979-0.82$9.0938jp9t1U"
Level4.="|<Level4>818181-0.78$9.0N38jp9t1U"
global Level5:="|<Level5>797979-0.75$9.0tA9zx89DU"
Level5.="|<Level5>818181-0.81$9.0t08zl897U"
Level5.="|<Level5>787979-0.90$9.0t08vV897U"
global Level6:="|<Level6>7A7778-0.81$10.0sW2Qz8YWCU"
Level6.="|<Level6>818181-0.82$10.0sW2Qz8YWCU"
global Level7:="|<Level7>787878-0.82$8.1m0VyG8WU"
global Level8:="|<Level8>7A7B7B-0.73$9.0tB9jr9dDU"
global Level9:="|<Level9>787878-0.74$9.0tB9jr89DU"
global Level10:="|<Level10>AEAEAE-0.75$14.0HWAgV9yGG4YVCU"
Level10.="|<Level10>BCBCBC-0.74$14.0FWAYV9yGG4YV6U"
Level10.="|<Level10>AEAEAE-0.52$14.0HWAgVNyKG4gVCU"
global Level11:="|<Level11>AEAEAE-0.75$12.0F8n8FyF8F8FU"
Level11.="|<Level11>BCBCBC-0.68$12.0F8n8FyF8F8FU"
Level11.="|<Level11>ADAEAE-0.75$12.0F8n8FyF8F8FU"
Level11.="|<Level11>BCBCBC-0.74$12.0F8n8FyF8F8FU"
global Level12:="|<Level12>A5A19E-0.85$14.0HWAYV2yFW4UVDU"
Level12.="|<Level12>ABABAB-0.86$14.0FWAYV2yFW4UVDU"
global Level13:="|<>B4B4B4-0.90$17.00k0m0EU1l612G24M001"
global Level14:="|<Level14>9B9A9A-0.78$15.0EV6A8FbmI8Hl24U"
global Level15:="|<Level15>AFB0B5-0.78$14.0HmAUVCyGG44VCU"
Level15.="|<Level15>A29A9A-0.90$14.0HWAUVCyGG44VCU"
global Level16:="|<Level16>A2A3AA-0.90$14.01UAUVCQGG4YV6U"
Level16.="|<Level16>ABABAB-0.90$14.0FWAUVCQGG4YV6U"
global Level17:="|<Level17>9A9A9A-0.88$12.0H8k8EyF8F8FU"
Level17.="|<Level17>ABABAB-0.78$13.0HYMG4Dm8V4EWU"
global Level18:="|<>BCBCBC-0.90$14.000000A1Y493WAEYY9k00008"
global Level19:="|<Level19>AFB0B0-0.82$14.0HWAUV9yHm40VCU"
Level19.="|<Level19>ABAAB-0.90$14.0FWAUV9QHm40VCU"
global Level20:="|<Level20>**50$14.T6JhPTK1BhrNMNU"
Level20.="|<Level20>**50$14.T6JxTTK1BhrTQNU"
Level20.="|<Level20>CFC612-0.75$14.0tWGgUdymG8YbiU"
Level20.="|<>CFC608-0.90$12.1X0IEEsUE4FnU"
global Level20enchantwindow:="|<>CFC608-0.90$12.1X0IEEsUE4FnU"

Global ArmorFood:="|<voidwarparmor>**20$29.0QU0Q0HAgw1YkDjTDUzuixVqDTn5aOzSDxpty9X8m4vrzjyvc3CZFULwvt3zBss4Tikx/rbkmOpb0oUZUAVr+8B35LEC7xYU45/w1cCTX7EPv7+k"
ArmorFood.="|<voidwarparmor>**20$23.3/USyT1xRv3izi/5ywTjnwHFY9rzTxo6T+UjtrryvnczRVLjDcpfC9V/0PiIEK+iUDv90+Lu2Qz6ArqCEzBmXPy4k"
ArmorFood.="|<miragehelm>**50$20.Mk1qQ9DD7DrXV9tfuwyfi9gvqKCtR6iyRvg6TsS4azVndqsP3i6xvVf8sOHz6zk3hXsfvn+tk0tU2"
ArmorFood.="|<miragehelm>**50$23.6DrkMk1knV9XD7DayQ9PtfvrbpPj9grSmletR6Jrnjfg6RT3kWazVwxCrMP3ikrjRVf8t3KTs6zkQRgTcfvnVLC0E"
ArmorFood.="|<aureliangarb>**30$26.qERdRpyO/Cw62ks1UDowqMSNx24zyGNIM5KBD7kWOr0BqT0XBD09lQY00o3005700Zs00/AF02+8U022405dy01CLA2U"
ArmorFood.="|<aureliangarb>**30$29.//UWKGT7rZqERd9ijnE3Cs60C70A0DowoM3nD824zy2J+X0WeBC3kIHKs0haR0VNds1+EQY006UM0057004j000/AE00F140122402hDE05CLA2E"
ArmorFood.="|<glacialarmor>**30$29.067iSx79k6AYla0P62GdwM4YbVUNoTH0kzxq1U0+83sCwEizsQnJ0ETxX00GwAm1UEDw31k2E6K04U7vU90Co0E0ss0M1EE00BtU00GAE00acU2E"
ArmorFood.="|<glacialarmor>**30$29.067iSx79k6AYla0H62GdwM4Y7VUNkPH0kzxq1U0+83sCwEizsQnJ00TxX00GwAm0UEDw31k2E6K04U7tU90Co0E0cs0M1EE00BtU00GAE00a8U2E"
ArmorFood.="|<amberscalerobe>**30$29.3n8U8QSLhxl/9q64Qlw8Nb2k1qP5U7NXvkP/1mzxq1k0C93sCwEjzcQnJ9sTxnG0LSAk1Y0jt31o2E6K04U7tU90yq0E/tvkMH0MU0Ut702H+M1k"
ArmorFood.="|<amberscalerobe>**30$32.BVUtTzrM700741w0vl2zzoCNeYbVzrBB0/j6Nk6E2zwVUu190NM0HE3wk4o3vM135wRsAlA1W04EQXU19AdU7mHLE1Y0pKEFFgow7oXcV1wBQXk1+cTE7kXd01G"
ArmorFood.="|<coronabelt>4F5130-0.90$26.07zU07zu03zy33zzWjzzwPzzx4zzxXDzslXzyQAzzlGzwE0MSk0E0204DV0000E080000UA000TU0ETs01Q34AE0804x21VDyU2G"
ArmorFood.="|<coronabelt>62632A-0.90$29.07zWU0zyX03zx08DzwM0zvlE7zrlUzzvGQDi030Qk0EA000UDV008U20130000c1U00ELU04XlU0+C564G0100U021VEDoIm00NbYE0E0WE0oK40001M0000d"
ArmorFood.="|<sandspikeaegis>**25$29.1i4d03MlL0Cz7j0psCG19X162OA7rCyTv0PKM6UpyNz4bSQPu8S8pwTjDdgojANBVPc+3bKEE/+dUmwn210e7w33Qz86DLUS4Fz3a8DGA41giMAE"
ArmorFood.="|<sandspikeaegis>**25$29.3Q9G06lWi0RyDS9fkQY2H62A4oEDjRwzq2qckB1fwny1CwsrYEwFfMzSTHNdCMkP2rEE7CgUUKJH1Zta40VIDs66syEASj0w83y7AECYM8HNQkME"
ArmorFood.="|<ivoryrobe>**25$29.3f77+8IRSshvW9lNy4GmHsSYin1hvRozPMtzUoFks1gVobXn5yTR2EbzmGdKP5RFhsy+Xur65ins4/DD096DoU00qH004ds00Zy001NW802ONk0E"
ArmorFood.="|<ivoryrobe>**25$29.zzzzcELC10Xg3iFikxyVpXXZY+CbRGxl4sgj29N9wDGTNUqxquThgwzkO8sQ0qEuHltYzDiV8Hzt94fBWi8qwD4FxPU0rNw21bbU4X7uE00P9U0E"
ArmorFood.="|<ashenslatecoat>**25$26.bviKFpoxtAA37y7Ak0sUzny87zlnBEAzyplZ/tn3k8DqQ7k8L/120Ti0VzPU8ffe3+d8U2zbk0hau0/OgE7qvE3Ray0zT70BzYE2"
ArmorFood.="|<ashenslatecoat>**25$26.sdkRqSw6mQtbQavma3xr/8uuSwa61Xz3WM0QETtz43zstac2TzOtmZwtVs03zC3s5/ZU10Dr0Ezhk4Jll1pIYE5Tns0KnN05hK86"
ArmorFood.="|<nemisisarmor>**25$26.fhSAoyzaAxzviDxnrnSrxxzzBdSxzPziRvurmvTDzSlzozyoRDgj7Lv7kziVqPzMRamq7FhtUsPDwAzzv3ezyEsytwDRxz1hxzkS"
ArmorFood.="|<nemisisarmor>**25$29.ZyzaQ7zzRkDxvrsPqzjlzzBd3rjzTTiRvvqyLPuDzSlzybzqURDgjUuzMz0zilqHTv3hamq7OBjg7MPTwArzzMRuzykujrDVvRxz1Xjzy3mqyy7k"
ArmorFood.="|<crystalline>**50$26.Kzpi7wNvxivSzDhaoV+NwgqCxxPsRhbb78imPOPAbqqn/x54LmEFBlg4l8O18m4UEA3A4PsQ0ZTN08LQy2iyyUWiy89PTL2IipEq"
ArmorFood.="|<crystalline>**50$26.BrPrlxwqZNHDZqlrjXT3hgwst7qHPnFYyqoNTcc6yG21iBUY93E96Fo31gPUnT7UA/v81WvbkJrro4LrlV3PusEZqe6BneVZtesG"
ArmorFood.="|<sterlingguardianarmor>**25$26.6MAwkyCd8Pa+sCz7j7jXmF9XVaHNUzryTvEOXUpJiNz0vnXS8SMZXxttArjA8B/R03zKEE9I44Kr201MzUFQz04uw3k1z1W0uFUW"
ArmorFood.="|<sterlingguardianarmor>**25$26.Cz7j7jXmF9XVaHNUzryTvEOX0oJiNz0vnXS8SMZXxtt4rjA8B/R03zKEE9I44Kr201Mz0FQz04mw3k1z1W0uFUViiOAviyVDrjYG"
ArmorFood.="|<obsidian>**30$29.0G00I2g00YVFUFeGa0hIZk1/9D12H/A64aKHk84WC0E53U0U0GA181tYE02IQ40YEU416Z1821d804P80M8os0Y0jE001N0102bU007U0004800E"
ArmorFood.="|<obsidian>**30$23.bkV9a32Hds417081k0E960Ywy81CC22Ak23GUY0pY8BY0AOQ0GTc00gU0VHk03k002400EF09Ua03HM035W00/A0E"
ArmorFood.="|<ivorymagewall>**50$23.3oPa5rjI/vMUKqyUsiz3Rgx4axI/9dsKlnMf/a1CfC3Lhw6pbc6uRk6hvkzqilITQWxjw1iuK2pn54ysq+tsU5VHE"
ArmorFood.="|<ivorymagewall>**50$17.IfxsrDzSjqlBhxFRyzNvBueHHpXaqLARKQjPtfDNovZPrjhTcytvTtRohva9xlZnlk"
ArmorFood.="|<obsidianmagewall>**50$17.7n9dFSpCrjzpf6+aLxAqqZjCLCQjKridcxHPutPTvJzPzSujy9upewDRuDLa7wJLVE"
ArmorFood.="|<obsidianmagewall>**50$26.7Z5s1ObP0zzzk+rf66fNSVSaP8PPKp5rPa1xmxwfPrM0bXq19hxUDpxs1xey0RjxbrRTvLsrfgOpSnYxraf7flPsTlw+foe3jLzW"
ArmorFood.="|<wallofbluediamondscales>**50$23.0Pxm0hjc3LRGzvzUobQV9iv2zjw3PBsAaPS9zzzFiy0nBw0yvi1TzR/iveJRpE7zvcTJrEgv4ntq+"
ArmorFood.="|<wallofbluediamondscales>**50$20.6ivjyztditOvipzTsqnSNAqqzzyXRwArTHxrSLzrLRrJLRITzr7rRlNq8yxWDzvVqPOBbYXjj8fcm"
ArmorFood.="|<dragonspikedshield>**50$23.0Nss1hjUHH9axeH0wbQ1d8UUSVE3PAU66N6NBq7Faw8nAs9qNWDBrADiu8IAYE+n1UT5X04v4K9K8q7glhNlVimWE"
ArmorFood.="|<dragonspikedshield>**50$26.0BwQEaqy49davTrfAoSHiA6YfXFTIskBgmA33AXNYrMXsnS8XAnW5zAlUwrQs7rR41EqF05Ngk1wKA02RW1MbQUT3qM6pba0zNF2"
ArmorFood.="|<crystallinegloves>**50$26.107U0zjk0Tl40BEV07wUk1DkzkI0NY41OM1Fgo0zy73dy1beq3F0hc4Eeu1DtiUE+P802pm0YZBU49FE1VJ000E8100200008006"
ArmorFood.="|<crystallinegloves>**50$20.7zy3y8lf48zo6By7yU3AU/H+RafzksDkAqkS9h4aLE9xo23N00yE4dg1ef0Bc0EF082E009002I02"
ArmorFood.="|<obsidiangloves>**30$26.03zU0Spx0Sv6kDSMY3jD80TrmEbjzY4rju19P00EPlc6WM72zq3sRi0mCPbqXijhsumv+BizmXnvwcczzC+BunXVSgMkSj685fk2"
ArmorFood.="|<obsidiangloves>**50$26.3b780Hnm0bjpUEFBs10F00EPU042M04zk1N9i0GKPXYfijhcmmv+NYzmVFuwcUyj++5uE61CY9UGf2M5/k00SI00+Z002dE00eI2"
ArmorFood.="|<nemesisshoes>**30$26.142NkNYaw3sBQ0z5L0Bkpk3ghA0zuP0/sjU7cD2PC2kjt0TPtkBMjn2O+bUinXUSgbU6/Dk1jnU0RS00CHU03Bs01bS00ArU03Dm"
ArmorFood.="|<nemesisshoes>**30$23.+UHCNYawz3fczZL1i6j3ihA7zHM/sjkx3tLi2sj83vNmRMyMPEbUylw3rbU6/C0Dy00RS01mQ03Bs0Cvk0QrU0NyE"
ArmorFood.="|<stasisrobe>**50$23.dTMkKz3I3rhzwNvQnPrgjqpBLCYrCwzT3hjbDCa3vHAbqqATcYBqEsSBVcsP13Eo2+XA6LDs3zwEDD7kJEQUznlVk"
ArmorFood.="|<stasisrobe>**50$23.zXDPaPSxpyqdetoatrbvsRhwtvokTSNYyqlXx6Vym73lgB73M8O6UFIPUmtz0TzW1tsy2eXo7ySADPsMLjMEankVk"
ArmorFood.="|<voidwarpgauntlets>**30$29.UDDk10uiA232RA4C8tM8s3XwHbCSwa6thhSvaSyzjClzLwxaAjVToPzyogxjFdhvsXl/hnB3LTQOGiqMoYRgVc8jT1V3DW32CC424oQM0DcDU0AE"
ArmorFood.="|<voidwarpgauntlets>**30$26.1tz00viA0MHdUC9tM70wTXbCSwkrBhivaSzxtqjzwxq5w/yXzyphhuBDfxbt9yNcOTQOGan6aVgVsczwA+TW32DkUkaQM0DXw01W"
ArmorFood.="|<glacialgloves>**50$26.0Q3806Ey03+N00r4w0tH9U+Mb83UNm1jwqUHsyC40xyl0RTBMSS3byTkxzAjuv6/y+X3mZhkYfLs9srw2U3P024rk2tBs011u00G"
ArmorFood.="|<glacialgloves>**50$29.0C1Y00t3s01ZAU03QHk0QdYk0dWQU1kAx06znO09wTb0E3rv0UCjq5VtwAPzDwMrwmzXRb5zAuAD++qsHIBTUbUPy1kURg08EPs1QkzU051x00AE"
ArmorFood.="|<aurelianboots>**50$26.0cDMU+3G80ziW0Dqdk6suM1lSa0Cz9U1ybg3rDj0bGCLwgjtMs6gHy1BgP0Lv2U7CHU3Rbk0ivU0Ci003NU01aM00Ga004tU01iu"
ArmorFood.="|<aurelianboots>**50$26.0E3T0I1x051v41EuFE7xoI1yxD0r7H0C/ok1ztA0DoxUStxs6yHqzZZz/b0pWTk9gXQ2zAQ0vmQ0Pgy05rA01pk00PA00AnU02Qu"
ArmorFood.="|<aureliangloves>**50$26.06zxUDcDM7C0S3301VUUUMks8aQT77hTF7uKKTUY6zm93rVwDgXzHPXipqxzczftyAiiSrNfgYwCz9c7iGOVOYksEd004/k01Gw2"
ArmorFood.="|<aureliangloves>**50$26.3301VUUUMksAaQT77hTFDuLKTUZ6zm93rVwDjXzHPXypyxzgzftyAiiSrPfybwSz9e7iGOVSYwsId004Dk01Gw00LxU04vM00eK2"
ArmorFood.="|<sandspikegauntlets>**50$26.0sN00Q1Q0C0d0709E3U6OVk3XYM33kg2VcCY0m0f2AU/n7c0jlrUKTogp4NdjT6jtZH9HTvWKymE4pgY55/T01xoU0E6c200e00W"
ArmorFood.="|<sandspikegauntlets>**50$26.Q0bUC0Re30SCEUBD61+6UmE386g8m0zASU+z7y/tzGnYNiatwPzZJgZDDi9Pn/1HKmEIohw27vG01CSU802c020i00U10000E002"
ArmorFood.="|<goldenmagewall>**50$26.0RnU0ArC0D2/k6rCq1xzjkpHGA9omx2x0atqohbnC7CTn4nzQlguLD7CWnPn0TNPk3vJwEvPvDjubzjrjLMpew71tD3I/K4rEv1O"
ArmorFood.="|<goldenmagewall>**50$29.0w8j03PbP07ryz0Odd60bH/o1SUHQ7PGqQNb3a8zAHDkiMaR1QwQu1NhtU1xZj01xeyA3hfgtrRHzGzQxRYOpS2A7Yw485f2MR1g1U+1kC0SE1sE"
ArmorFood.="|<glacialgloves>**50$26.1ZAU0PWS0QdYk5AHY1kAt0ryPE9wT720SzMUCjagDD1XzDsOzaLwRX5z5FVtGqsGIfw4w/y1E1hU12Ps1Qaw00Ux0086E081g02W"
ArmorFood.="|<glacialgloves>**50$29.0QVw00maE01i9s0CImM0IlCE0s6SU3Tth04yDnU81vxUE7Lv2kwy6BzbyAPyNTlinWzaR67Z5PQ9e6jkHkBz0sECq048Bw0iMTk02UyU060N00cE"
ArmorFood.="|<amberscaleshoes>**30$29.05rzy0Dyyg0Ij/s1jzLk1zvt07UxS0xbyS3r9T8DQ7ffweHraDk6i8w0BQL20Ocw80xs001PE003XU006b0009m000zw001Dc006dM00CzE00Lzk"
ArmorFood.="|<amberscaleshoes>**30$26.0/jzk3zjc1tSL0Pzpk3zrk1wDL1vjwkxqLkSsTLz+YxyTUBSD03Lj40pT30DQ102q000sk00BA007Q001zk00Hs00BG003jk00jy"
ArmorFood.="|<voidwarpgauntlets>*34$29.z30/zwC4LzssAjzvktzzTlzzzzrzzzyzzzzwzzzjwzzqvRzbzazzjrxTDTiwiSwvsRxtzyzvrzhnrizTbzDK7DoQYCzUk+Ts006xk00JvU00vr001ri003zw1"
ArmorFood.="|<voidwarpgauntlets>*30$32.zzwzzzzy1zzznUDzzkE2zzsQ8jzyC3/z7rVnzXrwTztxzjzyTzjzzbztzTlvzDzwRqtzDDNjzvnjuySwvj/bjBrkvvnTzjywjzPbjDfrtznSgCTU713jM1UEzk001jM000fq08"
ArmorFood.="|<nemisisarmor>**50$31.0IQ3KUO21WkQ31XkDblXM6zxXCDsmnz6tj/eVxAqZFKa1TcvbQmkPsQ5cDyA1Q1dh09UoyUYEOTEP8DtcBY5lY6m2Eo3N19G0YUgz0HILS09cbx06MLQk1b"
ArmorFood.="|<bdmagewall>**40$23.0ZE01CbU4Nv0Una310Q4U0k801wJg50fE0FqE10C0C0w8U3l10j6mBmTY2Psm4hW08SQ0EA00UE017k01J000000E"


 
global weaponfood:="|<bd2hsword>**50$29.003y600C0000E3k01fwk06Dy008s000n1E0362U0AABU0kEN037Za0AS680FUP0363Y0AMC01lUE0261U04A6009kM00H3U03Lc0003U002XU005m000+Y000U40000E007U00000E00E"
weaponfood.="|<bd1hsword>**50$23.R82sT8/WTESCT1NqO5XASSA4tskg3m1Q7A0iwk03n00L810Cs2VNc57Vd8S3cEwHl1k32V4a16EYFA1BU222c403E"
weaponfood.="|<bd2hstaff>**40$29.0080001M0000M0004E05LAU0+ddUUC1hs0I3ao0/bic3L//M2AJCcL82zE8E048SW0M1h000HMUUE3w00E1k80EM0000k000X60015000024000AU0008k000EU000kU0001U2001040E"
weaponfood.="|<bdlongbow>**50$29.mTw003000003U07kP008wP001wHw0SDU0007zU009s000A000Tjk020600009U0006000030002Q800500004D000Bq0003c0006I000AU00090000a0003M0000k000Pc000X000268E"
weaponfood.="|<bd1hmaxe>**40$23.HU40l0N1a123sSA040E01UU07vE03M000x047s3e5E5IfUC9b06U+0QkkPj0M1Plc3ya005k019000G6004U0002E"
weaponfood.="|<bd2hmace>**40$23.DzI0HU80l0k3iD01kLtk00K03Ys3PZU2Ye8Z0q0/1U3O1E4I2U0dAMUk0F401U8xWJ414c0ITEVc2UI030o06000E"
weaponfood.="|<bddaggers>**30$23.DaQyDbrEBqvUAm40/rE0DyU01U000600200000031002000000004UA01Uk03V203s003EE03k00CU0040008000E"
weaponfood.="|<bd2haxe>**30$28.000000A0001r000Bd4U1rKE0ArBs1bkE00r3U09yeE0Y8PU+vU20azUI8mS/o3T+h0hbvM/IThsUGIgi0FnYk5Bom0LaE028I001zk010O0003Q010RU001401UAM0A1n02"
weaponfood.="|<dimensionalcleaver>*113$25.WPzzYvnzk9UTs8zrw8zpy4MzT4TrjW6Urm02vs03xwoUyy84CT066TUH3zk3kzw8RDz46byU1nzNayzadTzl4zzwlzzz2zzzkzzrySznk"
weaponfood.="|<fiendishedge>*80$25.lxzzmTszlgn7s7Tvx6TyybQDj3Dvrr7SvxoDxyJnyySQTSS+7D073jsjlzgxsTaxyrlWbnklFtsBrTM7Ijw9aTv6MrwVXTn8MTkX63MNE"
;weaponfood.="|<malice>*102$25.y9zzyPjzyDjzyHzDzBaNz0XzT8nzrYvXxkNzSusvrR+0ziUaTrHm3vUkEtk0sNv5ADx5j3ynVozAEMTa8DDtiPfwOZzz4Hyyn6zrA/zzk"
weaponfood.="|<hymnlbow>*99$25.zzzzzzzzrzzzwzzzz9zzzkzzzQDzzv7zzyVzzvtzzyQTzznDzzxzzzxXzxyozzTODzrjnzwrwMzPz83bTk0k7nk80zD40z1m0JvM0/yqE"
weaponfood.="|<holybow>*67$25.zzzzzvzzzyzzxzjzzVvzzsyzyyzi0Tzv0Dxyk3zkU3xM81qc20Tw007n003wk11y40Eyly0C4Mk603m20TuU076U0IzE0Jcs00/Q037zE"
weaponfood.="|<blessedlbow>*107$25.zzzzrzzzo7zzsXzzwNzzz7zzzuLzziDzzt5zzy3zzzXzzzrjzzvHzzwszzSTDzrTljxjwpCTzzj0z02UDUQE34V810A40jn208Ql003cE"
weaponfood.="|<demonicspear>*81$25.zzzkTzzwTzzQTzyAzz0yzzbwrzzynztaNzPaTzVyLz3yGy3zTT3zPjjyTrzz/vsyDhlqDblZDrk33bk11kk61sk20sU10wE1UGE0U980E"
weaponfood.="|<barbarousspear>*91$25.zzyMzzwNTy0djyDdjzz9bzl8nzn0Pz3gfy3AZw7y7wDgrSzwTjzyHrzwKPrgzDz0zjy4b7t0bVsYXrsIVxk+Vtk30wk10SE07vM07t80E"
weaponfood.="|<mercilessspear>*73$25.zzzzzzztzzyszzwtzy9xzzzxjzzxbjngnqrwzvHxjy7yjyLyzy7yrSSwzi0yLq0yzP1izD1CTi0C7T033V0B2xU71J031+U10YU0UGE0E"
weaponfood.="|<eternal1hmace>*68$25.zzvzzzxzzzzdzTz4TjxbBvt1dyks3zrAXTzrX6xtgbvwu1wDA8zTrjtbto8VwNo0nCPb5ljDUstyLPDQ3jXzXn1vthtkRavUCzTk3zi0E"
weaponfood.="|<unquenchable1hmace>*85$25.yz4RjxbBzt1dyss3zrAXPzbX0xtgZvwu0wDAATTnjxbt42VwNk0X6P77lbzUsxyLPTU3jbyXn1zthtzxazzizTn3zjk1zjo1yzvkjvUsE"
weaponfood.="|<anguish>*115$25.zzWbzzM0zzsETxw8/yQ49zw21zt00Swk13b820Hr008tY01Qm0E78007m002s000iE00X6820lV40MwM0PTk0Dbw1H1w11tz06zTsUTnk"
weaponfood.="|<edgeofcataclysm>*120$25.U3zbk7znk7zMMBzi46Tr03zrkDzjs3zXi4Tkb3DyFV7zskTxsMBysM3yyw1zzw4Tzw3Dzt1rzk1zzt1zrxVrzU0tzU0wnw3yTzzzTzzzk"
weaponfood.="|<cruelremorse>*110$25.y00Ty2sTw3zwy3zyS3zv31zxk5zyu3zyy3zzzVzyTkjzDsRzqyDzzS7zzT1zzzUTrzWDzzlXzzstzzsSzzo7zzw9yzyATs067w076TUTk"
weaponfood.="|<powerbreaker>*114$25.k03zU2zbk7zns2TMQ0Tg66Db12DrkX7Ds1j340HUX0DsFU7ykk5wkM1wM83ywA1zyQ0Tzw1Dzk1rzk1zjk1zbs1vr00wzU0ynw3zTzzzk"
weaponfood.="|<unyieldingonslaught>**50$23.000k007000M001U006V00O101hC06Ek0N/01gI03GM0APU0ki03Kk0Bv00rg03Sk0Rv00cA00sk01V006K00+s00E"
weaponfood.="|<relentless1hsword>**50$23.003200QY01Y806VE0PDU1ga06qy0PP01gg02nE0B/U0Vi03Kk0BP00rg03Sk0Bv00Lg00Ek01b003I003s00C000E"
weaponfood.="|<cataclysm1hsword>**50$23.000m003000Q001U006000M501c606ow0P/01gg02lE0A/U0ki032k0BP00rg03Sk0Bv00rg01Uk02X007400/s00E"
weaponfood.="|<2hsword>**50$23.00000A000E0E0U0E002U1U5020C0QAs1k7004s0CH00lg036k0SP03kg026k06P00Cw007E01Ck03yU04r00Bc00E"
weaponfood.="|<2hsword>**50$23.011002i007000Q000U003E004U00/0004080c1k7UC081k0o703UM3a9U0wq0DVM0Q5U0cK01tM01iU06RU0Ax00E"
weaponfood.="|<2hsword>**50$23.01L002c00A000E001c0020201U402040QAs1l7046s0OPU1lg1n6k0SP07kg0C6k0K/00Cw007E01Ck03yU04z00E"
weaponfood.="|<xbow>**50$23.E0000000000800Tk3z8UDkX0oQC9zko0wTcLj7kzqd3aJu6MgwNkyNbUPaR0H9a0o+M0s3U80S00300EM00V0000k"
weaponfood.="|<xbow>**50$23.000Q000U0012000k00zU7yF0IV63U8wFzVc1szEjLDVzhG7AfoAlFsnVwnD0rAuUaHA3cQk5l70E1w00700UE010E"
weaponfood.="|<xbow>**50$23.000000000008001k008c0Eb8E5G8zloM4TcHfLUzGf1q5y3M8oBUC8b0P2SQG1zAoDM4cnU8Uw0Nu00EM00z0003k"
weaponfood.="|<dagger>**50$23.g0008000E000k008U005000l000X001200270U41A0TU00dVk1xkE1AUk0RUE1BYU0Pr00OV00o100g2U1M302U5E"
weaponfood.="|<dagger>**50$23.s0018000E004U000000B0008001U003000200045108000T001L002vUU0P3U0P0U0TB00qC00w201g201M102k7E"
weaponfood.="|<dagger>**50$23.I000M003U00300060008000E000g001s003EU02Uk85000/s00+s00LQ403MS03MY03Fc06lk07UE09UE0/000K0k"
weaponfood.="|<2hstaff>**50$23.3fW+4qkI+yAcTrOUhuxUrL30Xww07jE0CFs0+Sk0rp02yP04UC0C0M3w3U6E5UDU3Ui001U002U00+000s002000E"
weaponfood.="|<2hstaff>**50$23.AkXUqTzVpnZWPQ/ZR4TDvYHKpSmEfVwFyTU3LfE78z05DS0Pua1z7c2E7EL0Bly1lX82y7k1cL000k001E005000E"
weaponfood.="|<2hstaff>**50$23.6nzwCi0gLP1MfcmlzRe2rfq1RSO2Dno0Ow80Nbk0dvU3TI0/tg0G0s0s1cDkC0N0GUy0D2s006000+000c003U00E"
weaponfood.="|<2hmace>**50$23.229U2Ba00AO1FxZ19SO5+0G/0Mon0W9D14Gq1EePWmBYwoi0Etk/F3sOM032+C87I0E0Y0zlY001Y00180010001E"
weaponfood.="|<2hmace>**50$23.Btzo4zWcYy7EFFC0Fgk0BXE0Bgc99lEft2FPFqaNwl9F8WKm+4v86lgZ6Zk0761O8T3NE0MNFlEuU20YU7yAU00Ak"
weaponfood.="|<2hmace>**50$23.5As+dD0pIIH44NAX3Mp23P+2mwq+yEgKoRdaT6O6G8pgWVoz1hP9FfQ01pkKW7kqo06CQykDg0VN81zX8003E003E"
weaponfood.="|<1hstaff>**50$23.0Ew40kcA1Wkk33106gC0MzS0Unc1K3ETtHUURaFx2AUV0LTxEwbs1tsNmbMQb+QNQJhs8vvvllTb08cX6PF+AHbwE"
weaponfood.="|<1hstaff>**50$23.0QE40fk81UEM140U24205MA0/yU0NZI082UPaX10F4Uc0N020eQW1l7r20UvZ6EtA4sGsVPwE0IrU3yi00FIAGWsE"
weaponfood.="|<1hstaff>**50$23.0710044008M80J0k0ju01aJ00U+1jOA41002s1U082Vm074OQ8+2iEF3gUFVDW0fV003Sk3vs055E1O/U2Qj0BK0E"





global processing:="|<>C9C9C9-0.68$70.z0000000U00220000000000880000000000UZC73VksZVc22N4WF8YGN9UDl4G14UE94W0U4F87lksYG820F4UE0UGF8U814G94WF94a0U4C73VksYFd40000000000U0000000000W00000000001k2"

global EmptySlotPattern:="|<>*16$38.LzzzzyZzzzzzdTzzzwuLyTRiCZsaKH1dT4U4XOLl029yZks07UdQC01UOLk0kE6Zy0QUvdM0m0EOLk0206Zz000xdQ1X+0+LUNlU6Zz001xdS0002OL06706Zz2AVVdT0306OK1U0s6Zts0DVdTw01xuLl828yc"
;==========Gui_Creation=====================================================================================
; Create a simple GUI with three buttons: Reload, SelectWindow, TestArmor
Gui, Main:Color, 0x2B2B2B
Gui, Main:Font, s10 cWhite, Segoe UI

; Title Section
Gui, Main:Add, Text, x0 y10 w300 h40 Center 0x200 BackgroundTrans, GEAR ENCHANTER
Gui, Main:Font, s9

; What to Enchant Section
Gui, Main:Add, GroupBox, x10 y60 w280 h105 cWhite, What to Enchant
Gui, Main:Add, Checkbox, x30 y85 w100 h25 vEnchantWeapon gEnchantWeaponChanged, Weapons
Gui, Main:Add, Checkbox, x150 y85 w100 h25 vEnchantArmor gEnchantArmorChanged, Armor
Gui, Main:Add, Checkbox, x30 y110 w120 h25 vIHaveERep gIHaveERepChanged Checked, I have E-Rep
Gui, Main:Add, Checkbox, x150 y110 w120 h25 vIHaveEProtect gIHaveEProtectChanged Checked, I have E-Protect

; Status Section
Gui, Main:Add, GroupBox, x10 y175 w280 h60 cWhite, Status
Gui, Main:Add, Text, x20 y195 w260 h30 vStatusText Center, Ready to start...

; Statistics Section with toggle button
Gui, Main:Add, GroupBox, x10 y245 w280 h210 cWhite vStatsGroupBox, Statistics
Gui, Main:Add, Button, x250 y242 w35 h20 gToggleStats vToggleStatsBtn, [-]
Gui, Main:Font, s8
Gui, Main:Add, Text, x20 y265 w120 h15 vTimeLabel, Time Running:
Gui, Main:Add, Text, x140 y265 w140 h15 vTimeRunningText Right, 00:00:00
Gui, Main:Add, Text, x20 y285 w120 h15 vERepairLabel, E-Repair Used:
Gui, Main:Add, Text, x140 y285 w140 h15 vERepairText Right, 0
Gui, Main:Add, Text, x20 y305 w120 h15 vEProtectLabel, E-Protect Used:
Gui, Main:Add, Text, x140 y305 w140 h15 vEProtectText Right, 0
Gui, Main:Add, Text, x20 y325 w120 h15 vDefenseCubeLabel, Defense Cubes:
Gui, Main:Add, Text, x140 y325 w140 h15 vDefenseCubeText Right, 0
Gui, Main:Add, Text, x20 y345 w120 h15 vStrikeCubeLabel, Strike Cubes:
Gui, Main:Add, Text, x140 y345 w140 h15 vStrikeCubeText Right, 0
Gui, Main:Add, Text, x20 y365 w120 h15 vFortuneDefenseLabel, Fortune Defense:
Gui, Main:Add, Text, x140 y365 w140 h15 vFortuneDefenseCubeText Right, 0
Gui, Main:Add, Text, x20 y385 w120 h15 vFortuneStrikeLabel, Fortune Strike:
Gui, Main:Add, Text, x140 y385 w140 h15 vFortuneStrikeCubeText Right, 0
Gui, Main:Add, Text, x20 y405 w120 h15 vLevel20Label, Level 20 Found:
Gui, Main:Add, Text, x140 y405 w140 h15 vLevel20Text Right, 0
Gui, Main:Add, Text, x20 y430 w260 h15 vStatsHint Center cGray, (Click [-] to collapse)
Gui, Main:Font, s9

; Controls Section
Gui, Main:Add, GroupBox, x10 y465 w280 h90 cWhite vControlsGroupBox, Controls
Gui, Main:Add, Text, x20 y485 w260 h20 Center vReloadText, Press F2 to Reload
Gui, Main:Add, Button, x20 y510 w120 h35 gstartenchanting vStartBtn, Start
Gui, Main:Add, Button, x160 y510 w110 h35 gStopEnchanting vStopBtn, Stop

Gui, Main:Show, x100 y100 w300 h575, Gear Enchanter
return
;=============================================================================================================
f2:: reload
f4:: ShowLevel20Celebration()

ToggleStats:
    global statsExpanded
    statsExpanded := !statsExpanded
    
    if (statsExpanded) {
        ; Expand statistics - show all stats elements
        GuiControl, Main:, ToggleStatsBtn, [-]
        GuiControl, Main:Move, StatsGroupBox, h210
        GuiControl, Main:Show, TimeLabel
        GuiControl, Main:Show, TimeRunningText
        GuiControl, Main:Show, ERepairLabel
        GuiControl, Main:Show, ERepairText
        GuiControl, Main:Show, EProtectLabel
        GuiControl, Main:Show, EProtectText
        GuiControl, Main:Show, DefenseCubeLabel
        GuiControl, Main:Show, DefenseCubeText
        GuiControl, Main:Show, StrikeCubeLabel
        GuiControl, Main:Show, StrikeCubeText
        GuiControl, Main:Show, FortuneDefenseLabel
        GuiControl, Main:Show, FortuneDefenseCubeText
        GuiControl, Main:Show, FortuneStrikeLabel
        GuiControl, Main:Show, FortuneStrikeCubeText
        GuiControl, Main:Show, Level20Label
        GuiControl, Main:Show, Level20Text
        GuiControl, Main:Show, StatsHint
        
        ; Move controls section down
        GuiControl, Main:Move, ControlsGroupBox, y465
        GuiControl, Main:Move, ReloadText, y485
        GuiControl, Main:Move, StartBtn, y510
        GuiControl, Main:Move, StopBtn, y510
        
        ; Resize window
        Gui, Main:Show, w300 h575
    } else {
        ; Collapse statistics - hide all stats elements
        GuiControl, Main:, ToggleStatsBtn, [+]
        GuiControl, Main:Move, StatsGroupBox, h30
        GuiControl, Main:Hide, TimeLabel
        GuiControl, Main:Hide, TimeRunningText
        GuiControl, Main:Hide, ERepairLabel
        GuiControl, Main:Hide, ERepairText
        GuiControl, Main:Hide, EProtectLabel
        GuiControl, Main:Hide, EProtectText
        GuiControl, Main:Hide, DefenseCubeLabel
        GuiControl, Main:Hide, DefenseCubeText
        GuiControl, Main:Hide, StrikeCubeLabel
        GuiControl, Main:Hide, StrikeCubeText
        GuiControl, Main:Hide, FortuneDefenseLabel
        GuiControl, Main:Hide, FortuneDefenseCubeText
        GuiControl, Main:Hide, FortuneStrikeLabel
        GuiControl, Main:Hide, FortuneStrikeCubeText
        GuiControl, Main:Hide, Level20Label
        GuiControl, Main:Hide, Level20Text
        GuiControl, Main:Hide, StatsHint
        
        ; Move controls section up
        GuiControl, Main:Move, ControlsGroupBox, y285
        GuiControl, Main:Move, ReloadText, y305
        GuiControl, Main:Move, StartBtn, y330
        GuiControl, Main:Move, StopBtn, y330
        
        ; Resize window
        Gui, Main:Show, w300 h395
    }
return

EnchantWeaponChanged:
    Gui, Main:Submit, NoHide
    ; Explicitly convert to boolean
    EnchantWeapon := EnchantWeapon ? True : False
    if (EnchantWeapon) {
        UpdateStatus("Weapons enchanting enabled")
    } else {
        UpdateStatus("Weapons enchanting disabled")
    }
return
EnchantArmorChanged:
    Gui, Main:Submit, NoHide
    ; Explicitly convert to boolean
    EnchantArmor := EnchantArmor ? True : False
    if (EnchantArmor) {
        UpdateStatus("Armor enchanting enabled")
    } else {
        UpdateStatus("Armor enchanting disabled")
    }
return

IHaveERepChanged:
    Gui, Main:Submit, NoHide
    ; Explicitly convert to boolean
    IHaveERep := IHaveERep ? True : False
    if (IHaveERep) {
        UpdateStatus("Will search for level 1-19 items in inventory")
    } else {
        UpdateStatus("Will only search for ArmorFood/WeaponFood")
    }
return

IHaveEProtectChanged:
    Gui, Main:Submit, NoHide
    ; Explicitly convert to boolean
    IHaveEProtect := IHaveEProtect ? True : False
    if (IHaveEProtect) {
        UpdateStatus("Will switch to E-Protect method at level 17")
    } else {
        UpdateStatus("Will use E-Repair until level 20")
    }
return
;==========Initialization=====================================================================================
StartEnchanting:
    ; Initialize statistics
    statsStartTime := A_TickCount
    eRepairUsed := 0
    eProtectUsed := 0
    r7DefenseCubeUsed := 0
    r7StrikeCubeUsed := 0
    r7FortuneDefenseCubeUsed := 0
    r7FortuneStrikeCubeUsed := 0
    level20Found := 0
    
    ; Update GUI statistics
    UpdateStatisticsGUI()
    InitializeCoordinates()
    enchantingActive := true
    UpdateStatus("Enchanting started - searching for items...")
    SetTimer, MainEnchantLoop, 100
    SetTimer, UpdateStatisticsTimer, 1000
return
StopEnchanting:
    enchantingActive := false
    UpdateStatus("Enchanting stopped")
    SetTimer, MainEnchantLoop, Off
    SetTimer, UpdateStatisticsTimer, Off
return
;==========Enchanting_Blocks=================================================================================
MainEnchantLoop:
    WinActivate, rappelz
    if (!enchantingActive) {
        return
    }
    emptyenchantslot()
    emptymaterialslot()
    emptyadditionalmaterialslot(9)
    if (EnchantArmor && EnchantWeapon) {
        ; Both are enabled - handle both armor and weapons
        foundValidItem := false
        itemType := ""

        ; First try ArmorFood without Level 20
        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, ArmorFood)) {
            Loop, % ok.MaxIndex() {
                foundX := ok[A_Index].1
                foundY := ok[A_Index].2
                foundW := ok[A_Index].3
                foundH := ok[A_Index].4

                searchPadding := 10
                checkX := foundX - searchPadding
                checkY := foundY - searchPadding
                checkW := foundW + (searchPadding * 2)
                checkH := foundH + (searchPadding * 2)

                hasLevel20 := FindText(x, y, checkX, checkY, checkX+checkW, checkY+checkH, 0, 0, Level20)

                if (!hasLevel20) {
                    centerX := foundX + foundW/2
                    centerY := foundY + foundH/2
                    FindText().Click(centerX, centerY, "L")
                    Sleep, 20
                    FindText().Click(centerX, centerY, "L")
                    foundValidItem := true
                    itemType := "armor"
                    break
                }
            }
        }

        ; If no ArmorFood, try weaponFood without Level 20
        if (!foundValidItem && ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, weaponFood)) {
            Loop, % ok.MaxIndex() {
                foundX := ok[A_Index].1
                foundY := ok[A_Index].2
                foundW := ok[A_Index].3
                foundH := ok[A_Index].4

                searchPadding := 10
                checkX := foundX - searchPadding
                checkY := foundY - searchPadding
                checkW := foundW + (searchPadding * 2)
                checkH := foundH + (searchPadding * 2)

                hasLevel20 := FindText(x, y, checkX, checkY, checkX+checkW, checkY+checkH, 0, 0, Level20)

                if (!hasLevel20) {
                    centerX := foundX + foundW/2
                    centerY := foundY + foundH/2
                    FindText().Click(centerX, centerY, "L")
                    Sleep, 20
                    FindText().Click(centerX, centerY, "L")
                    foundValidItem := true
                    itemType := "weapon"
                    break
                }
            }
        }

        ; If still nothing, search for ANY item with levels 1-19
        if (!foundValidItem) {
            UpdateStatus("No specific items without Level 20, checking for any items with levels 1-19...")

            Loop, 19 {
                level := A_Index
                pattern := Level%level%

                if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, pattern)) {
                    levelX := ok[1].1
                    levelY := ok[1].2
                    levelW := ok[1].3
                    levelH := ok[1].4

                    itemOffsetX := + 10
                    itemOffsetY := + 10

                    clickX := levelX + itemOffsetX
                    clickY := levelY + (levelH / 2) + itemOffsetY

                    FindText().Click(clickX, clickY, "L")
                    Sleep, 20
                    FindText().Click(clickX, clickY, "L")
                    foundValidItem := true
                    itemType := "unknown"
                    UpdateStatus("Found item with Level " . level)
                    break
                }
            }
        }

        if (!foundValidItem) {
            UpdateStatus("No valid items found (all have Level 20 or no items exist)")
            return
        }

        result := GetEnchantmentLevel()
        currentLevel := result.level
        startFromBeginning := result.startEnchantingProcessFromBeginning

        if (startFromBeginning) {
            return
        }

        emptymaterialslot()
        emptyadditionalmaterialslot(9)

        ; Route to appropriate enchanting method
        if (itemType = "armor") {
            if (currentLevel >= 17) {
                Gosub, EnchantArmorusingdefcubeandeprotect
            } else {
                Gosub, EnchantArmorusingr7fortuneanderepair
            }
        } else if (itemType = "weapon") {
            if (currentLevel >= 17) {
                Gosub, Enchantweaponusingstrikecubeandeprotect
            } else {
                Gosub, Enchantweaponusingr7fortuneanderepair
            }
        } else {
            ; Unknown type - try armor method by default
            if (currentLevel >= 17) {
                Gosub, EnchantArmorusingdefcubeandeprotect
            } else {
                Gosub, EnchantArmorusingr7fortuneanderepair
            }
        }
    } else if (EnchantArmor) {
        foundValidArmor := false

        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, ArmorFood)) {
            Loop, % ok.MaxIndex() {
                foundX := ok[A_Index].1
                foundY := ok[A_Index].2
                foundW := ok[A_Index].3
                foundH := ok[A_Index].4

                searchPadding := 10
                checkX := foundX - searchPadding
                checkY := foundY - searchPadding
                checkW := foundW + (searchPadding * 2)
                checkH := foundH + (searchPadding * 2)

                hasLevel20 := FindText(x, y, checkX, checkY, checkX+checkW, checkY+checkH, 0, 0, Level20)

                if (!hasLevel20) {
                    centerX := foundX + foundW/2
                    centerY := foundY + foundH/2
                    FindText().Click(centerX, centerY, "L")
                    Sleep, 20
                    FindText().Click(centerX, centerY, "L")
                    foundValidArmor := true
                    break
                }
            }
        }

        if (!foundValidArmor && IHaveERep) {
            UpdateStatus("No ArmorFood without Level 20, checking for armor with levels 1-19...")

            Loop, 19 {
                level := A_Index
                pattern := Level%level%

                if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, pattern)) {
                    levelX := ok[1].1
                    levelY := ok[1].2
                    levelW := ok[1].3
                    levelH := ok[1].4

                    armorOffsetX := + 10
                    armorOffsetY := + 10

                    clickX := levelX + armorOffsetX
                    clickY := levelY + (levelH / 2) + armorOffsetY

                    FindText().Click(clickX, clickY, "L")
                    Sleep, 20
                    FindText().Click(clickX, clickY, "L")
                    foundValidArmor := true
                    UpdateStatus("Found armor with Level " . level)
                    break
                }
            }
        }

        if (!foundValidArmor) {
            UpdateStatus("No valid armor found (all have Level 20 or no armor exists)")
            return
        }

        result := GetEnchantmentLevel()
        currentLevel := result.level
        startFromBeginning := result.startEnchantingProcessFromBeginning

        if (startFromBeginning) {
            return
        }

        emptymaterialslot()
        emptyadditionalmaterialslot(9. erepair)

        if (currentLevel >= 17 && IHaveEProtect) {
            Gosub, EnchantArmorusingdefcubeandeprotect
        } else {
            Gosub, EnchantArmorusingr7fortuneanderepair
        }
    } else if (EnchantWeapon) {
        foundValidWeapon := false

        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, weaponFood)) {
            Loop, % ok.MaxIndex() {
                foundX := ok[A_Index].1
                foundY := ok[A_Index].2
                foundW := ok[A_Index].3
                foundH := ok[A_Index].4

                searchPadding := 10
                checkX := foundX - searchPadding
                checkY := foundY - searchPadding
                checkW := foundW + (searchPadding * 2)
                checkH := foundH + (searchPadding * 2)

                hasLevel20 := FindText(x, y, checkX, checkY, checkX+checkW, checkY+checkH, 0, 0, Level20)

                if (!hasLevel20) {
                    centerX := foundX + foundW/2
                    centerY := foundY + foundH/2
                    FindText().Click(centerX, centerY, "L")
                    Sleep, 20
                    FindText().Click(centerX, centerY, "L")
                    foundValidWeapon := true
                    break
                }
            }
        }

        if (!foundValidWeapon && IHaveERep) {
            UpdateStatus("No weaponFood without Level 20, checking for weapon with levels 1-19...")

            Loop, 19 {
                level := A_Index
                pattern := Level%level%

                if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, pattern)) {
                    levelX := ok[1].1
                    levelY := ok[1].2
                    levelW := ok[1].3
                    levelH := ok[1].4

                    weaponOffsetX := + 10
                    weaponOffsetY := + 10

                    clickX := levelX + weaponOffsetX
                    clickY := levelY + (levelH / 2) + weaponOffsetY

                    FindText().Click(clickX, clickY, "L")
                    Sleep, 20
                    FindText().Click(clickX, clickY, "L")
                    foundValidWeapon := true
                    UpdateStatus("Found weapon with Level " . level)
                    break
                }
            }
        }

        if (!foundValidWeapon) {
            UpdateStatus("No valid weapon found (all have Level 20 or no weapon exists)")
            return
        }

        result := GetEnchantmentLevel()
        currentLevel := result.level
        startFromBeginning := result.startEnchantingProcessFromBeginning

        if (startFromBeginning) {
            return
        }

        emptymaterialslot()
        emptyadditionalmaterialslot(9, erepair)

        if (currentLevel >= 17 && IHaveEProtect) {
            Gosub, Enchantweaponusingstrikecubeandeprotect
        } else {
            Gosub, Enchantweaponusingr7fortuneanderepair
        }
    }
Return
EnchantArmorusingdefcubeandeprotect:
    ; Search for defense cube and e-protect in inventory and double click them both
    if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7defensecube)) {
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
    }

    if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, eprotect)) {
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
    }
    ; Search material slot for r7defensecube
    Loop {
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7defensecube)) {
            break
        }
        ; Not found in material slot, search inventory and double click
        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7defensecube)) {
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 100
        }
    }

    ; Search additional material slots for eprotect
    Loop {
        found := false
        Loop, % addMatSlots.MaxIndex() {
            slot := addMatSlots[A_Index]
            slotSearchX := slot.searchX
            slotSearchY := slot.searchY
            slotSearchW := slot.searchW
            slotSearchH := slot.searchH
            searchX2 := slotSearchX + slotSearchW
            searchY2 := slotSearchY + slotSearchH

            if (ok := FindText(x, y, slotSearchX, slotSearchY, searchX2, searchY2, 0, 0, eprotect)) {
                found := true
                break
            }
        }

        if (found) {
            break
        }

        ; Not found in additional material slots, search inventory and double click
        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, eprotect)) {
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 100
        }
    }
    ; Press spacebar and wait for processing to complete
    Loop {
        ; Increment counters for materials being used
        r7DefenseCubeUsed++
        eProtectUsed++
        
        Send, {Space}
        Sleep, 100

        ; Wait for processing to appear
        Loop, 60000 { ; Timeout after 10 seconds
            if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, processing)) {
                break
            }
            Sleep, 50
        }

        ; Wait for processing to disappear
        Loop, 30000 { ; Timeout after 30 seconds
            if (!FindText(x, y, 0, 0, 1024, 768, 0, 0, processing)) {
                sleep, 100
                ;ToolTip, Processing complete
                break
            }
            Sleep, 50
        }

        result := GetEnchantmentLevel()
        currentLevel := result.level
        startFromBeginning := result.startEnchantingProcessFromBeginning
        if (startFromBeginning) {
            level20Found += 1
            ShowLevel20Celebration()
            UpdateStatus("Level 20 enchantment achieved! Total Level 20 found: " . level20Found)
            emptymaterialslot()
            emptyadditionalmaterialslot(9)
            goto, MainEnchantLoop
        }

        if (ok := FindText(x, y, enchX, enchY, enchX+enchW, enchY+enchH, 0, 0, EmptySlotPattern)) {
            goto, MainEnchantLoop
        }

        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, EmptySlotPattern)) {
            goto, MainEnchantLoop
        }
    }
return
EnchantArmorusingr7fortuneanderepair:
    ; Search for fortune cube and e-repair in inventory and double click them both
    if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunedefensecube)) {
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
    }
    ; Search material slot for r7fortunedefensecube
    Loop {
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7fortunedefensecube)) {
            break
        }
        ; Not found in material slot, search inventory and double click
        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunedefensecube)) {
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
        }
    }
    emptyadditionalmaterialslot(9)
    Loop {
        ; Increment counter for fortune defense cube being used
        r7FortuneDefenseCubeUsed++
        
        Send, {Space}
        Sleep, 100

        ; Wait for processing to appear
        Loop, 60000 { ; Timeout after 10 seconds
            if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, processing)) {
                break
            }
            Sleep, 10
        }

        ; Wait for processing to disappear
        Loop, 30000 { ; Timeout after 30 seconds
            if (!FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, processing)) {
                Sleep, 100
                break
            }
            Sleep, 10
        }

        ; Search material slot for erepair
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, erepair)) {
            eRepairUsed++  ; Increment erepair counter when found in material slot
            continue ; Press space again
        }
        ; Check if enchantment slot is empty
        if (ok := FindText(x, y, enchX, enchY, enchX+enchW, enchY+enchH, 0, 0, EmptySlotPattern)) {
            goto MainEnchantLoop
        }
        ; Search material slot for r7fortunedefensecube
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7fortunedefensecube)) {
            ; Check enchantment slot for levels 17-20 or empty
            result := GetEnchantmentLevel()
            currentLevel := result.level
            ;ToolTip, Current Level: %currentLevel%
            if (currentLevel >= 20 || currentLevel = 0) {
                emptymaterialslot()
                goto MainEnchantLoop
            }
            if (currentLevel >= 17 && IHaveEProtect) {
                emptymaterialslot()
                goto EnchantArmorusingdefcubeandeprotect
            }
        }
        ; Check if material slot is empty
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, EmptySlotPattern)) {
            ; Material slot is empty, find r7fortunedefensecube in inventory
            if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunedefensecube)) {
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
            }
        } else if (!FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7fortunedefensecube)) {
            ; Material slot is not empty and doesn't have erepair or fortune cube
            ; Double click the material slot to empty it
            FindText().Click(matX + matW/2, matY + matH/2, "L")
            Sleep, 50
            FindText().Click(matX + matW/2, matY + matH/2, "L")
            Sleep, 20

            ; Find r7fortunedefensecube in inventory and double click
            if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunedefensecube)) {
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
            }
        }
        emptyadditionalmaterialslot(9)
    }

return
Enchantweaponusingstrikecubeandeprotect:
    ; Search for defense cube and e-protect in inventory and double click them both
    if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7strikecube)) {
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
    }

    if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, eprotect)) {
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
    }
    ; Search material slot for r7strikecube
    Loop {
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7strikecube)) {
            break
        }
        ; Not found in material slot, search inventory and double click
        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7strikecube)) {
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 100
        }
    }

    ; Search additional material slots for eprotect
    Loop {
        found := false
        Loop, % addMatSlots.MaxIndex() {
            slot := addMatSlots[A_Index]
            slotSearchX := slot.searchX
            slotSearchY := slot.searchY
            slotSearchW := slot.searchW
            slotSearchH := slot.searchH
            searchX2 := slotSearchX + slotSearchW
            searchY2 := slotSearchY + slotSearchH

            if (ok := FindText(x, y, slotSearchX, slotSearchY, searchX2, searchY2, 0, 0, eprotect)) {
                found := true
                break
            }
        }

        if (found) {
            break
        }

        ; Not found in additional material slots, search inventory and double click
        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, eprotect)) {
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 100
        }
    }
    ; Press spacebar and wait for processing to complete
    Loop {
        ; Increment counter for strike cube being used
        r7StrikeCubeUsed++
        eProtectUsed++
        
        Send, {Space}
        Sleep, 100

        ; Wait for processing to appear
        Loop, 60000 { ; Timeout after 10 seconds
            if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, processing)) {
                break
            }
            Sleep, 50
        }

        ; Wait for processing to disappear
        Loop, 30000 { ; Timeout after 30 seconds
            if (!FindText(x, y, 0, 0, 1024, 768, 0, 0, processing)) {
                sleep, 100
                ;ToolTip, Processing complete
                break
            }
            Sleep, 50
        }

        result := GetEnchantmentLevel()
        currentLevel := result.level
        startFromBeginning := result.startEnchantingProcessFromBeginning
        if (startFromBeginning) {
            level20Found += 1
            ShowLevel20Celebration()
            UpdateStatus("Level 20 enchantment achieved! Total Level 20 found: " . level20Found)
            emptymaterialslot()
            emptyadditionalmaterialslot(9)
            goto, MainEnchantLoop
        }

        if (ok := FindText(x, y, enchX, enchY, enchX+enchW, enchY+enchH, 0, 0, EmptySlotPattern)) {
            goto, MainEnchantLoop
        }

        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, EmptySlotPattern)) {
            goto, MainEnchantLoop
        }
    }
return
Enchantweaponusingr7fortuneanderepair:
    ; Search for fortune cube and e-repair in inventory and double click them both
    if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunestrikecube)) {
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
        FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
        Sleep, 20
    }
    ; Search material slot for r7fortunestrikecube
    Loop {
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7fortunestrikecube)) {
            break
        }
        ; Not found in material slot, search inventory and double click
        if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunestrikecube)) {
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
            FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
            Sleep, 20
        }
    }
    emptyadditionalmaterialslot(9)
    Loop {
        ; Increment counter for fortune strike cube being used
        r7FortuneStrikeCubeUsed++
        
        Send, {Space}
        Sleep, 100

        ; Wait for processing to appear
        Loop, 60000 { ; Timeout after 10 seconds
            if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, processing)) {
                break
            }
            Sleep, 10
        }

        ; Wait for processing to disappear
        Loop, 30000 { ; Timeout after 30 seconds
            if (!FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, processing)) {
                Sleep, 100
                break
            }
            Sleep, 10
        }

        ; Search material slot for erepair
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, erepair)) {
            eRepairUsed++  ; Increment erepair counter when found in material slot
            continue ; Press space again
        }
        ; Check if enchantment slot is empty
        if (ok := FindText(x, y, enchX, enchY, enchX+enchW, enchY+enchH, 0, 0, EmptySlotPattern)) {
            goto MainEnchantLoop
        }
        ; Search material slot for r7fortunestrikecube
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7fortunestrikecube)) {
            ; Check enchantment slot for levels 17-20 or empty
            result := GetEnchantmentLevel()
            currentLevel := result.level
            ;ToolTip, Current Level: %currentLevel%
            if (currentLevel >= 20 || currentLevel = 0) {
                emptymaterialslot()
                goto MainEnchantLoop
            }
            if (currentLevel >= 17 && IHaveEProtect) {
                emptymaterialslot()
                goto Enchantweaponusingstrikecubeandeprotect
            }
        }
        ; Check if material slot is empty
        if (ok := FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, EmptySlotPattern)) {
            ; Material slot is empty, find r7fortunestrikecube in inventory
            if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunestrikecube)) {
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
            }
        } else if (!FindText(x, y, matX, matY, matX+matW, matY+matH, 0, 0, r7fortunestrikecube)) {
            ; Material slot is not empty and doesn't have erepair or fortune cube
            ; Double click the material slot to empty it
            FindText().Click(matX + matW/2, matY + matH/2, "L")
            Sleep, 50
            FindText().Click(matX + matW/2, matY + matH/2, "L")
            Sleep, 20

            ; Find r7fortunestrikecube in inventory and double click
            if (ok := FindText(x, y, invX, invY, invX+invW, invY+invH, 0, 0, r7fortunestrikecube)) {
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
                FindText().Click(ok[1].1 + ok[1].3/2, ok[1].2 + ok[1].4/2, "L")
                Sleep, 20
            }
        }
        emptyadditionalmaterialslot(9)
    }

return
;==========Functions========================================================================================
emptyenchantslot(){
    global EmptySlotPattern, enchX, enchY, enchW, enchH
    ; Search only within the enchant slot bounds
    if (ok := FindText(x,y,enchX, enchY, enchX+enchW, enchY+enchH, 0, 0, EmptySlotPattern)) {
        ; Loop through found results (up to 2)
        Loop, % (ok.MaxIndex() > 2 ? 2 : ok.MaxIndex()) {
            foundX := ok[A_Index].1 ; Get X coordinate (top-left)
            foundY := ok[A_Index].2 ; Get Y coordinate (top-left)
            foundW := ok[A_Index].3 ; Get Width
            foundH := ok[A_Index].4 ; Get Height

            ; Calculate center position
            centerX := foundX + (foundW / 2)
            centerY := foundY + (foundH / 2)

            ;FindText().MouseTip(centerX, centerY) ; Show tip at center
        }
    } else {
        findtext().click(enchX + enchW/2, enchY + enchH/2) ; Click center of enchant slot
        Sleep, 50
        findtext().click(enchX + enchW/2, enchY + enchH/2) ; Click center of enchant slot again
    }
return
}
emptymaterialslot(){
    global EmptySlotPattern, matX, matY, matW, matH
    ; Search only within the material slot bounds
    if (ok := FindText(x,y,matX, matY, matX+matW, matY+matH, 0, 0, EmptySlotPattern)) {
        ; Loop through found results (up to 2)
        Loop, % (ok.MaxIndex() > 2 ? 2 : ok.MaxIndex()) {
            foundX := ok[A_Index].1 ; Get X coordinate (top-left)
            foundY := ok[A_Index].2 ; Get Y coordinate (top-left)
            foundW := ok[A_Index].3 ; Get Width
            foundH := ok[A_Index].4 ; Get Height

            ; Calculate center position
            centerX := foundX + (foundW / 2)
            centerY := foundY + (foundH / 2)

            ;FindText().MouseTip(centerX, centerY) ; Show tip at center
        }
    } else {
        findtext().click(matX + matW/2, matY + matH/2) ; Click center of material slot
        Sleep, 50
        findtext().click(matX + matW/2, matY + matH/2) ; Click center of material slot again
    }
return
}
emptyadditionalmaterialslot(requiredSlots := 2, preservePattern := "") {
    global EmptySlotPattern, addMatSlots

    foundEmptyCount := 0

    ; Keep looping until we find the required number of empty slots
    Loop {
        ; Count how many slots are empty
        foundEmptyCount := 0
        Loop, % addMatSlots.MaxIndex() {
            slot := addMatSlots[A_Index]
            slotSearchX := slot.searchX
            slotSearchY := slot.searchY
            slotSearchW := slot.searchW
            slotSearchH := slot.searchH
            searchX2 := slotSearchX + slotSearchW
            searchY2 := slotSearchY + slotSearchH

            ; Check if slot is empty
            if (ok := FindText(x, y, slotSearchX, slotSearchY, searchX2, searchY2, 0, 0, EmptySlotPattern)) {
                foundEmptyCount++
            }
        }

        ;ToolTip, Found %foundEmptyCount% empty slots (need %requiredSlots%)

        ; If we found enough empty slots, we're done
        if (foundEmptyCount >= requiredSlots) {
            Sleep, 10
            ;ToolTip
            return
        }

        ; Find a slot to click (one that's not empty and doesn't contain preserve pattern)
        slotToClick := 0
        Loop, % addMatSlots.MaxIndex() {
            slot := addMatSlots[A_Index]
            slotSearchX := slot.searchX
            slotSearchY := slot.searchY
            slotSearchW := slot.searchW
            slotSearchH := slot.searchH
            searchX2 := slotSearchX + slotSearchW
            searchY2 := slotSearchY + slotSearchH

            ; Check if slot is empty
            isEmpty := FindText(x, y, slotSearchX, slotSearchY, searchX2, searchY2, 0, 0, EmptySlotPattern)

            ; If slot is not empty, check if it contains the preserve pattern
            if (!isEmpty) {
                shouldPreserve := false

                ; If preserve pattern is specified, check if this slot contains it
                if (preservePattern != "") {
                    if (ok := FindText(x, y, slotSearchX, slotSearchY, searchX2, searchY2, 0, 0, preservePattern)) {
                        shouldPreserve := true
                    }
                }

                ; If we shouldn't preserve this slot, mark it for clicking
                if (!shouldPreserve) {
                    slotToClick := A_Index
                    break
                }
            }
        }

        ; If no valid slot found to click, we're stuck
        if (slotToClick = 0) {
            ;ToolTip, Cannot find enough empty slots - all remaining slots contain preserved material
            Sleep, 100
            ;ToolTip
            return
        }

        ; Click the found slot
        slot := addMatSlots[slotToClick]
        clickX := slot.x
        clickY := slot.y
        ;ToolTip, Clicking slot %slotToClick% at %clickX%, %clickY%
        Sleep, 10

        FindText().Click(clickX, clickY, "L")
        Sleep, 10
        FindText().Click(clickX, clickY, "L")
        Sleep, 10
    }
}
GetEnchantmentLevel() {
    global enchX, enchY, enchW, enchH, EmptySlotPattern
    global Level1, Level2, Level3, Level4, Level5, Level6, Level7, Level8, Level9, Level10
    global Level11, Level12, Level13, Level14, Level15, Level16, Level17, Level18, Level19, Level20, level20enchantwindow
    global Level20:="|<Level20>**50$14.T6JhPTK1BhrNMNU"
    Level20.="|<Level20>**50$14.T6JxTTK1BhrTQNU"
    Level20.="|<Level20>CFC612-0.75$14.0tWGgUdymG8YbiU"
    Level20.="|<>CFC608-0.90$12.1X0IEEsUE4FnU"
    global Level20enchantwindow:="|<>CFC608-0.90$12.1X0IEEsUE4FnU"
    ; Search for enchantment levels from 20 down to 1
    Loop, 20 {
        level := 20 - A_Index ; Start from 20, go down to 1
        pattern := Level%level%

        if (ok := FindText(x, y, enchX, enchY, enchX+enchW, enchY+enchH, 0, 0, pattern)) {
            return {level: level, startEnchantingProcessFromBeginning: false}
        }
    }
    if (ok := FindText(x, y, enchX-10, enchY-10, enchX+enchW+10, enchY+enchH+10, 0, 0, level20enchantwindow)) {
        level := 20
        ;ToolTip, Current Level: %level%
        return {level: 20, startEnchantingProcessFromBeginning: true}
        ; No level found, check if slot is empty
        if (ok := FindText(x, y, enchX, enchY, enchX+enchW, enchY+enchH, 0, 0, EmptySlotPattern)) {
            return {level: 20, startEnchantingProcessFromBeginning: true}
        }
        ;ToolTip, Current Level: %level%

        ; Slot is not empty but no level detected
        return {level: 0, startEnchantingProcessFromBeginning: false}
    }
}
FindInventoryAndBox(color := "Red") {
    global inventoryText, invX, invY, invW, invH

    inventoryText := "|<>E9E9EA-0.70$49.U0000000E0000U0080000E004gWQKQQJ6NFFAYFAX8Z8YG8Y+YGbm94G5G9G14W92d4F4WF4UYW8QFAQEE00000008000000040000000AE"

    ; Use FindText to search for the text pattern on screen
    if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, inventoryText)) {
        ; Get the found text coordinates
        textX := ok[1].1 ; X coordinate
        textY := ok[1].2 ; Y coordinate
        textW := ok[1].3 ; Width
        textH := ok[1].4 ; Height

        ; Calculate full inventory window coordinates relative to found text
        ; Adjust these offsets based on your actual inventory layout
        invX := textX - 150 ; X offset from text to left edge of inventory
        invY := textY - 10 ; Y offset from text to top edge of inventory
        invW := 380 ; Full width of inventory window
        invH := 495 ; Full height of inventory window

        ; Draw bounding box around the FULL inventory window
        boxHwnd := bounding_box(color, invX, invY, invW, invH)

        ; Display coordinates for reference
        ;ToolTip, Inventory Found!`nX: %invX%`nY: %invY%`nW: %invW%`nH: %invH%, invX, invY - 80
        ;SetTimer, RemoveToolTip, 3000

        return boxHwnd
    }
    MsgBox, Text not found!
return 0
}
FindEnchantSlotAndBox(color := "0x00FF00") { ; Green
    global enchantWindowText, enchX, enchY, enchW, enchH

    enchantWindowText := "|<>FFFFFF-0.44$69.0E002084E0002000E211000QK75b0E80sgoH94mE2108aNUF0YG0U814WA28wWE4108YFUF8YG0U894WAG9AWE80W8YFQF6YH103UsWA"

    ; Use FindText to search for the enchant window text
    if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, enchantWindowText)) {
        ; Get the found text coordinates
        textX := ok[1].1
        textY := ok[1].2
        textW := ok[1].3
        textH := ok[1].4

        ; Calculate enchant slot coordinates relative to found text
        ; Adjust these offsets based on your actual enchant slot layout
        enchX := textX - 125
        enchY := textY + 385
        enchW := 40
        enchH := 40

        ; Draw bounding box around the enchant slot area
        boxHwnd := bounding_box(color, enchX, enchY, enchW, enchH)

        ; Display coordinates for reference
        ;ToolTip, Enchant Slot Found!`nX: %enchX%`nY: %enchY%`nW: %enchW%`nH: %enchH%, enchX, enchY - 80

        return boxHwnd
    }
    MsgBox, Enchant window not found!
return 0
}
FindMaterialSlotAndBox(color := "0xFFFF00") { ; Yellow
    global enchantWindowText, matX, matY, matW, matH

    enchantWindowText := "|<>FFFFFF-0.44$69.0E002084E0002000E211000QK75b0E80sgoH94mE2108aNUF0YG0U814WA28wWE4108YFUF8YG0U894WAG9AWE80W8YFQF6YH103UsWA"

    ; Use FindText to search for the enchant window text
    if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, enchantWindowText)) {
        ; Get the found text coordinates
        textX := ok[1].1
        textY := ok[1].2
        textW := ok[1].3
        textH := ok[1].4

        ; Calculate material slot coordinates relative to found text
        ; Adjust these offsets based on your actual material slot layout
        matX := textX - 83
        matY := textY + 385
        matW := 40
        matH := 40

        ; Draw bounding box around the material slot area
        boxHwnd := bounding_box(color, matX, matY, matW, matH)

        ; Display coordinates for reference
        ;ToolTip, Material Slot Found!`nX: %matX%`nY: %matY%`nW: %matW%`nH: %matH%, matX, matY - 80

        return boxHwnd
    }
    MsgBox, Enchant window not found!
return 0
}
FindAdditionalMaterialSlotsAndBox(color := "0x87CEEB") { ; Blue
    global enchantWindowText, addMatX, addMatY, addMatW, addMatH, addMatSlots

    enchantWindowText := "|<>FFFFFF-0.44$69.0E002084E0002000E211000QK75b0E80sgoH94mE2108aNUF0YG0U814WA28wWE4108YFUF8YG0U894WAG9AWE80W8YFQF6YH103UsWA"

    ; Use FindText to search for the enchant window text
    if (ok := FindText(x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, enchantWindowText)) {
        ; Get the found text coordinates
        textX := ok[1].1
        textY := ok[1].2
        textW := ok[1].3
        textH := ok[1].4

        ; Calculate additional material slots coordinates relative to found text
        addMatX := textX - 40
        addMatY := textY + 340
        addMatW := 130
        addMatH := 130

        ; Store all 9 slot positions in a 3x3 grid
        addMatSlots := []
        slotSize := 43 ; Approximate size of each slot (130/3)
        halfSlot := Floor(slotSize / 2)

        Loop, 3 { ; Rows
            row := A_Index - 1
            Loop, 3 { ; Columns
                col := A_Index - 1
                offsetX := col * slotSize
                offsetY := row * slotSize
                slotX := addMatX + offsetX
                slotY := addMatY + offsetY
                centerX := slotX + halfSlot
                centerY := slotY + halfSlot

                addMatSlots.Push({x: centerX, y: centerY, searchX: slotX, searchY: slotY, searchW: slotSize, searchH: slotSize})
            }
        }

        ; Draw bounding box around the additional material slots area
        boxHwnd := bounding_box(color, addMatX, addMatY, addMatW, addMatH)

        return boxHwnd
    }
    MsgBox, Enchant window not found!
return 0
}
InitializeCoordinates() {
    global invX, invY, invW, invH
    global enchX, enchY, enchW, enchH
    global matX, matY, matW, matH
    global addMatX, addMatY, addMatW, addMatH

    invX := 0
    invY := 0
    invW := 0
    invH := 0

    enchX := 0
    enchY := 0
    enchW := 0
    enchH := 0

    matX := 0
    matY := 0
    matW := 0
    matH := 0

    addMatX := 0
    addMatY := 0
    addMatW := 0
    addMatH := 0

    boxHwnd := FindAdditionalMaterialSlotsAndBox()
    boxHwnd1 := FindEnchantSlotAndBox()
    boxHwnd2 := FindMaterialSlotAndBox()
    boxHwnd3 := FindInventoryAndBox()
    sleep, 5000
    Gui, %boxHwnd%:Destroy
    Gui, %boxHwnd1%:Destroy
    Gui, %boxHwnd2%:Destroy
    Gui, %boxHwnd3%:Destroy
Return
}
bounding_box(color, x, y, w, h) {
    tc := 0x1 ; Transparent color
    Gui, New, -Caption +AlwaysOnTop +LastFound hwndgoo ; Make a gui with no caption (window features) and always on top
    opt := "x0 y0 w" w " h" h " c" tc " Background" color ; Progress bar options. Set bar color to tc and background to desired color
    Gui, Add, Progress, % opt, 100 ; Add progress bar to gui
    WinSet, TransColor, % tc ; Set the transparent color of the window
    Gui, Show, % "x" x " y" y " w" w " h" h ; Show the GUI. All that should show is the progress bar's outline box
return goo ; Return gui hwnd to further extend usability. Make a show/hide hotkey for example.
}
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return
ReloadScript:
    Reload
return
SelectWindow:
    MsgBox, Now right click on the game window 
    KeyWait, RButton, D
    MouseGetPos,,, selectedWindow
    WinGetTitle, title, ahk_id %selectedWindow%
    WinGet, pid, PID, ahk_id %selectedWindow%
    MsgBox, You have selected: %title% (PID: %pid%)
    FindText().BindWindow(selectedWindow)
    global win1 := selectedWindow
return
testarmor:
    global ArmorFood, Level20
    ; Search only within the inventory window bounds
    if (ok := FindText(x,y,invX, invY, invX+invW, invY+invH, 0, 0, ArmorFood)) {
        ;if (ok := FindText(x,y,invX, invY, invX+invW, invY+invH, 0, 0, ArmorFood,, 1,["amberscalerobe"])) {
        ; Loop through found results (up to 2)
        Loop, % (ok.MaxIndex() > 2 ? 2 : ok.MaxIndex()) {
            foundX := ok[A_Index].1 ; Get X coordinate (top-left)
            foundY := ok[A_Index].2 ; Get Y coordinate (top-left)
            foundW := ok[A_Index].3 ; Get Width
            foundH := ok[A_Index].4 ; Get Height

            ; Calculate center position
            centerX := foundX + (foundW / 2)
            centerY := foundY + (foundH / 2)

            ; Expand search area around the armor icon to catch level text
            searchPadding := 10 ; Pixels to expand search area in all directions
            checkX := foundX - searchPadding
            checkY := foundY - searchPadding
            checkW := foundW + (searchPadding * 2)
            checkH := foundH + (searchPadding * 2)

            ; Check if this armor piece has Level 20 near it
            hasLevel20 := FindText(x, y, checkX, checkY, checkX+checkW, checkY+checkH, 0, 0, Level20)

            if (!hasLevel20) {
                ; This armor doesn't have Level 20, show tip
                FindText().MouseTip(centerX, centerY) ; Show tip at center
            }
        }
    } else {
        MsgBox, ArmorFood not found in inventory!
    }
return

UpdateStatus(message) {
    GuiControl, Main:, StatusText, %message%
}

ShowLevel20Celebration() {
    global WB
    ; Get the position and size of the main GUI
    WinGetPos, mainX, mainY, mainW, mainH, Gear Enchanter
    
    ; Create a celebration GUI with the animated GIF
    Gui, Celebration:Destroy  ; Destroy any existing celebration window
    Gui, Celebration:+AlwaysOnTop +Owner -Caption +Border
    Gui, Celebration:Color, Black
    
    ; Add the GIF (check both spellings in script directory)
    gifPath := A_ScriptDir . "\bingotarentino.gif"
    if (!FileExist(gifPath)) {
        gifPath := A_ScriptDir . "\bingotarantino.gif"
    }
    
    if (FileExist(gifPath)) {
        ; Use ActiveX control to display animated GIF
        Gui, Celebration:Add, ActiveX, w280 h280 vWB, Shell.Explorer
        WB.Navigate("about:blank")
        WB.document.write("<html><body style='margin:0;padding:0;background:black;overflow:hidden;'><img src='file:///" . gifPath . "' width='280' style='display:block;'></body></html>")
    } else {
        ; If GIF not found, show text message
        Gui, Celebration:Font, s16 cWhite Bold
        Gui, Celebration:Add, Text, w280 h100 Center, LEVEL 20!`n🎉🎉🎉
    }
    
    ; Calculate position to center over main GUI
    celebrationX := mainX + (mainW - 280) / 2
    celebrationY := mainY + (mainH - 280) / 2
    
    Gui, Celebration:Show, x%celebrationX% y%celebrationY% w280 h280, Level 20!
    
    ; Set timer to close the celebration window after 3 seconds
    SetTimer, CloseCelebration, -5000
}

CloseCelebration:
    Gui, Celebration:Destroy
return

UpdateStatisticsGUI() {
    global statsStartTime, eRepairUsed, eProtectUsed, r7DefenseCubeUsed, r7StrikeCubeUsed
    global r7FortuneDefenseCubeUsed, r7FortuneStrikeCubeUsed, level20Found
    
    ; Calculate running time
    if (statsStartTime > 0) {
        elapsedMs := A_TickCount - statsStartTime
        hours := Floor(elapsedMs / 3600000)
        minutes := Floor(Mod(elapsedMs, 3600000) / 60000)
        seconds := Floor(Mod(elapsedMs, 60000) / 1000)
        timeStr := Format("{:02d}:{:02d}:{:02d}", hours, minutes, seconds)
    } else {
        timeStr := "00:00:00"
    }
    
    ; Update all statistics on GUI
    GuiControl, Main:, TimeRunningText, %timeStr%
    GuiControl, Main:, ERepairText, %eRepairUsed%
    GuiControl, Main:, EProtectText, %eProtectUsed%
    GuiControl, Main:, DefenseCubeText, %r7DefenseCubeUsed%
    GuiControl, Main:, StrikeCubeText, %r7StrikeCubeUsed%
    GuiControl, Main:, FortuneDefenseCubeText, %r7FortuneDefenseCubeUsed%
    GuiControl, Main:, FortuneStrikeCubeText, %r7FortuneStrikeCubeUsed%
    GuiControl, Main:, Level20Text, %level20Found%
}

UpdateStatisticsTimer:
    UpdateStatisticsGUI()
return