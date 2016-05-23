;; See the Info tab for more information on the code.

patches-own [ height retreatVal correctPath fightNoise distToGoal f g h parent troopFightingList patchColor ]
turtles-own [ currentGoal myPath troops troopRetreatNum astarPath capturePoint engaged retreating retreatPoint retreatPatches isDead ]
breed [ ANZAC anzacSoldier ]
ANZAC-own [ landingArea landed unsuccessfulLandingPatches ]
breed [ British britishSoldier ]
British-own [ landingArea landed unsuccessfulLandingPatches ]
breed [ Turkish turkishSoldier ]
Turkish-own [ turkRetreatPoint advanceTo ]
breed [ Objectives objective ]
Objectives-own [ hill971 krithia ]
globals [
  troopNum
  coastList
  anzacList
  britishList
  turkishList
  knownTurkishLocations
  knownAlliesLocations
  britishBeachLocations
  anzacBeachLocation
  turkCount
  briCount
  anzCount

  runBriOnce
  runAnzOnce
]

;; Sets up the model by creating all of the units and initializing variables
to setup
  clear-all

  set runBriOnce 0
  set runAnzOnce 0

  let RetreatPercentage 30
  set-patch-size 8
  resize-world -33 33 -33 33
  import-pcolors "GallipoliTopo.png"
  if not Terrain [
    import-drawing "GallipoliMap.png"
  ]
  initializeTerrain
  ask patches [
    set distToGoal 99
    set troopFightingList (list )
    set retreatVal 0
  ]
  set coastList (list )
  let j -33
  let k -33
  while [ j <= 33 ] [
    while [ k <= 33 ] [
      ask patch j k [
        if height = 1 [
          set coastList lput patch j k coastList
        ]
      ]
      set k (k + 1)
    ]
    set k -33
    set j (j + 1)
  ]

  set-default-shape Objectives "triangle"
  create-Objectives 1 [
    set color 0
    set size 1.5
    setxy 14 28
    set hill971 true;
    set krithia false;
  ]
  create-Objectives 1 [
    set color 0
    set size 1.5
    setxy -6 -15
    set hill971 false;
    set krithia true;
  ]

  reset-ticks
  set troopNum 300
  set-default-shape turtles "circle"
  let numANZAC 5
  let numBritish 5
  let numTurkish 13
  create-ANZAC numANZAC
  create-British numBritish
  create-Turkish numTurkish
  ask ANZAC [
    set color red
    set landed false
    set capturePoint objective 0
    set retreatPoint patch 5 22
    set unsuccessfulLandingPatches (list patch 5 22)
  ]
  set anzacBeachLocation (list patch 5 22)
  ask Turkish [
    set color green
  ]
  ask British [
    set color blue
    set landed false
    set capturePoint objective 1
    set retreatPoint patch -13 -25
    set unsuccessfulLandingPatches (list patch -17 -27 patch -12 -28 patch -6 -26 patch -14 -20 patch -17 -25)
  ]
  set britishBeachLocations (list patch -17 -27 patch -12 -28 patch -6 -26 patch -14 -20 patch -17 -25)
  ask turtles [
    set troops troopNum
    ;this is where the RetreatPercentage slider is used
    set troopRetreatNum (troops * (RetreatPercentage * .01))
    set retreatPatches []
    set retreating false
    set isDead false
  ]
    ask ANZAC [
      if anzacSoldier 2 = self [
        setxy 0 22
      ]
      if anzacSoldier 3 = self [
        setxy 0 23
      ]
      if anzacSoldier 4 = self [
        setxy -1 22
      ]
      if anzacSoldier 5 = self [
        setxy 0 21
      ]
      if anzacSoldier 6 = self [
        setxy -1 21
      ]
    ]
    ask British [
      if britishSoldier 7 = self [
        setxy -3 -31
      ]
      if britishSoldier 8 = self [
        setxy -12 -32
      ]
      if britishSoldier 9 = self [
        setxy -24 -24
      ]
      if britishSoldier 10 = self [
        setxy -20 -30
      ]
      if britishSoldier 11 = self [
        setxy -20 -17
      ]
    ]
    ask Turkish [
      if turkishSoldier 12 = self [
        setxy 6 22
      ]
      if turkishSoldier 13 = self [
        setxy 21 6;16 7
      ]
      if turkishSoldier 14 = self [
        setxy -16 -27
      ]
      if turkishSoldier 15 = self [
        setxy -6 -19
      ]
      if turkishSoldier 16 = self [
        setxy -3 -9
      ]
      if turkishSoldier 17 = self [
        setxy 5 -11
      ]
      if turkishSoldier 18 = self [
        setxy 16 3
      ]
      if turkishSoldier 19 = self [
        setxy 18 1
      ]
      if turkishSoldier 20 = self [
        setxy 18 17
      ]
      if turkishSoldier 21 = self [
        setxy 19 19
      ]
      if turkishSoldier 22 = self [
        setxy 21 22
      ]
      if turkishSoldier 23 = self [
        setxy 19 21
      ]
      if turkishSoldier 24 = self [
        setxy -12 -27
      ]
    ]
    ask Turkish [
      set retreatPoint patch-at 0 0
    ]

  set anzacList (list anzacSoldier 2 anzacSoldier 3 anzacSoldier 4 anzacSoldier 5 anzacSoldier 6)
  set britishList (list britishSoldier 7 britishSoldier 8 britishSoldier 9 britishSoldier 10 britishSoldier 11)
  set turkishList (list turkishSoldier 12 turkishSoldier 13 turkishSoldier 14 turkishSoldier 15 turkishSoldier 16
    turkishSoldier 17 turkishSoldier 18 turkishSoldier 19 turkishSoldier 20 turkishSoldier 21 turkishSoldier 22
    turkishSoldier 23 turkishSoldier 24)
end

;; Runs the model's logic
to go
  tick
  if showLabels [
    ask turtles [
      set label-color black
      set label troops
    ]
  ]
  anzacAI
  britishAI
  turkishAI
  fixPatchDisplay
  set turkCount 0
  foreach turkishList [
    if ?1 != nobody [
      ask ?1 [
        set turkCount (turkCount + troops)
      ]
    ]
  ]
  set briCount 0
  foreach britishList [
    if ?1 != nobody [
      ask ?1 [
        set briCount (briCount + troops)
      ]
    ]
  ]
  set anzCount 0
  foreach anzacList [
    if ?1 != nobody [
      ask ?1 [
        set anzCount (anzCount + troops)
      ]
    ]
  ]
  if briCount = 0 and runBriOnce = 0 [
    show "Tick: "
    show ticks
    show "British count"
    show briCount
    show "Anzac count"
    show anzCount
    show "Ottoman count"
    show turkCount
    show ""

    set runBriOnce (runBriOnce + 1)
  ]
  if anzCount = 0 and runAnzOnce = 0 [
    show "Tick: "
    show ticks
    show "British count"
    show briCount
    show "Anzac count"
    show anzCount
    show "Ottoman count"
    show turkCount
    show ""

    set runAnzOnce (runAnzOnce + 1)
  ]
end

;; There are issues with the different colorations when showing the terrain.  This makes sure something
;;   is always being displayed for every patch if there should be something showing.
to fixPatchDisplay
  if Terrain [
    ask patches [
      let thisPatch self
      ifelse pcolor = patchColor [
        if retreatVal = 1 [
          set pcolor 28
        ]
        if retreatVal = 2 [
          set pcolor 26
        ]
        if retreatVal = 3 [
          set pcolor 16
        ]
        if retreatVal = 4 [
          set pcolor 14
        ]
        if retreatVal = 5 [
          set pcolor 12
        ]
      ] [
        let turnOffRetreatVal true
        ask turtles with [ not empty? retreatPatches ] [
          if member? thisPatch retreatPatches [
            set turnOffRetreatVal false
          ]
        ]
        if turnOffRetreatVal [
          set retreatVal 0
          if fightNoise = 0 [
            set pcolor patchColor
          ]
        ]
      ]
    ]
  ]
end

;; Controls the logic for Anzac forces
to anzacAI
  foreach anzacList [
    if ?1 != nobody [
      successfullLanding ?1
      engagementCloud ?1
      retreat ?1
      combineTroops
      ask ?1 [
        ifelse isDead [
          ask ?1 [
            die
          ]
        ] [
          moveWithAStar ?1
          attack ?1
        ]
      ]
      ;show "6"
      ;Resets these variables because they are set on patches for A*, but are used uniquely with each agent
      ask patches [
        set f 0
        set g 0
        set h 0
        set parent 0
      ]
    ]
  ]
end

;; Controls the logic for British forces
to britishAI
  foreach britishList [
    if ?1 != nobody [
      successfullLanding ?1
      engagementCloud ?1
      retreat ?1
      combineTroops
      ask ?1 [
        ifelse isDead [
          ask ?1 [
            die
          ]
        ] [
          moveWithAStar ?1
          attack ?1
        ]
      ]
      ask patches [
        set f 0
        set g 0
        set h 0
        set parent 0
      ]
    ]
  ]
end

;; Controls the logic for Turkish forces
to turkishAI
  foreach turkishList [
    if ?1 != nobody [
      engagementCloud ?1
      combineTroops
      ask ?1 [
        ifelse isDead [
          ask ?1 [
            die
          ]
        ] [
          if ticks > 8 [
            turkMoveWithAStar ?1
          ]
          attack ?1
        ]
      ]
    ]
    ask patches [
        set f 0
        set g 0
        set h 0
        set parent 0
      ]
  ]
end

;; Moves the Turkish troops with the A* search algorithm
to turkMoveWithAStar [ currentTurk ]
  let topTurks (list turkishSoldier 12 turkishSoldier 20 turkishSoldier 21 turkishSoldier 22 turkishSoldier 23)
  let bottomTurks (list turkishSoldier 14 turkishSoldier 15 turkishSoldier 16 turkishSoldier 17 turkishSoldier 24)
  ;will need to keep them static until enemies land
  let nearestEnemyUnit nearestEnemy currentTurk britishList
  let nearestAnzac nearestEnemy currentTurk anzacList
  ask currentTurk [
    if currentTurk != nobody [
      ;attacking probably has this same issue
      if nearestAnzac != currentTurk and distance nearestEnemyUnit > distance nearestAnzac [
        set nearestEnemyUnit nearestAnzac
      ]
      let nearestBrit nearestEnemy currentTurk britishList
      if nearestBrit = currentTurk [
        set nearestEnemyUnit nearestAnzac
      ]
      let goal patch-at 0 0
      if (currentTurk != turkishSoldier 13 and currentTurk != turkishSoldier 18 and currentTurk != turkishSoldier 19)
        or ticks >= 35 [
          set goal nearestEnemyUnit
        ]
      if member? goal turkishList [
        ;show "If there are still enemies, turkMoveWithAStar has a bug"
      ]

      ;Middle turks.  These decide where to go based on which area needs the most help.
      if ticks > 10 and ticks < 35 and currentTurk != nobody and (currentTurk = turkishSoldier 13 or currentTurk = turkishSoldier 18
        or currentTurk = turkishSoldier 19) [
        let topTurkCount 0
        let anzacCount 0
        let botTurkCount 0
        let britCount 0
        foreach topTurks [
          if ?1 != nobody [
            ask ?1 [
              if engaged [
                set topTurkCount (topTurkCount + 1)
              ]
            ]
          ]
        ]
        foreach bottomTurks [
          if ?1 != nobody [
            ask ?1 [
              if engaged [
                set botTurkCount (botTurkCount + 1)
              ]
            ]
          ]
        ]
        foreach anzacList [
          if ?1 != nobody [
            ask ?1 [
              if engaged [
                set anzacCount (anzacCount + 1)
              ]
            ]
          ]
        ]
        foreach britishList [
          if ?1 != nobody [
            ask ?1 [
              if engaged [
                set britCount (britCount + 1)
              ]
            ]
          ]
        ]
        let anzacTurkRatio 0
        if topTurkCount != 0 [
          set anzacTurkRatio (anzacCount / topTurkCount)
        ]
        let britTurkRatio 0
        if botTurkCount != 0 [
          set britTurkRatio (britCount / botTurkCount)
        ]
;        show "anzac"
;        show anzacTurkRatio
;        show "brit"
;        show britTurkRatio
        let nearestAnz nearestEnemy currentTurk anzacList
        let nearestBri nearestEnemy currentTurk britishList
        ifelse anzacTurkRatio > britTurkRatio [
          set goal nearestAnz
        ] [
          set goal nearestBri
        ]
        if anzacTurkRatio > 1 and distance nearestAnz < distance nearestBri [
          set goal nearestAnz
        ]
      ]

      let path []
      ifelse currentGoal != goal [
        set currentGoal goal
        set path aStarForTurks currentTurk goal
        set myPath path
      ] [
        set path myPath
      ]
      if path = [] and goal != currentTurk [
        set path aStarForTurks currentTurk goal
        set myPath path
      ]
      if not empty? myPath [
        ;set path remove first path path
        set myPath remove first myPath myPath
        if not empty? myPath [
          if first myPath != last myPath [
            face first myPath
            move-to first myPath
          ]
        ]
      ]
      ;show path
    ]
  ]
end

;; Uses the path constructed by A* to move the agent that is passed in
to moveWithAStar [ currentGroup ]
  let goal capturePoint
  let path []
  ask currentGroup [
    if currentGroup != nobody [
    let currentNoise 0
    ask patch-at 0 0 [
      set currentNoise fightNoise
    ]
    ifelse landed [
      ;should check distances in the following aggression levels to go to closest one
      ; if there are multiple in the range
      let unitAggression Aggression
      let prevAggression Aggression
      if troops / troopNum < .75 [
        set unitAggression (unitAggression - 1)
      ]
      if troops / troopNum < .5 [
        set unitAggression (unitAggression - 1)
      ]
      if unitAggression < 2 and prevAggression > 2 [
        set unitAggression 2
      ]
      if retreating and unitAggression > 2 [
        ;temporary fix... not great, but works well enough if I don't get the time to come back
        set unitAggression 2
      ]


      ;HelpBeaches
      if Urgency != 1 and HelpBeaches and not retreating [
        let closestPatch patch-at 0 0
        let closestPatchDist 99
        foreach unsuccessfulLandingPatches [
          if ?1 != nobody and distance currentGroup < closestPatchDist [
            set closestPatchDist distance currentGroup
            set closestPatch ?1
            ;show "1"
          ]
        ]
        if closestPatch != patch-at 0 0 [
          set goal closestPatch
        ]
      ]



      ;if very aggressive, might want to follow a retreat trail
      ;if not very aggressive, might want to avoid retreat trails
      ;*Instead of doing the 2 above lines, I made it so that astar is more likely to travel along a
      ;  retreat path if the unit is aggressive and less likely if not aggressive
      if unitAggression = 5 [
        let closestTurk 0
        let closestTurkDist 99
        let foundTurk false
        ask patches with [fightNoise = 5 and distance currentGroup <= 5] [
          ;set
          if count Turkish-here = 1 [
            ;set goal self
            set foundTurk true
            if closestTurk = 0 or distance self < closestTurkDist [
              set closestTurkDist (distance self)
              set closestTurk self
            ]
          ]
        ]
        if foundTurk [
          set goal closestTurk
        ]
      ]
      if unitAggression = 4 [
        let closestTurk 0
        let closestTurkDist 99
        let foundTurk false
        ask patches with [fightNoise = 5 and distance currentGroup <= 4] [
          ;set
          if count Turkish-here = 1 [
            ;set goal self
            set foundTurk true
            if closestTurk = 0 or distance self < closestTurkDist [
              set closestTurkDist (distance self)
              set closestTurk self
            ]
          ]
        ]
        if foundTurk [
          set goal closestTurk
        ]
      ]
      if unitAggression = 3 [
        let closestTurk 0
        let closestTurkDist 99
        let foundTurk false
        ask patches with [fightNoise = 5 and distance currentGroup <= 3] [
          ;set
          if count Turkish-here = 1 [
            ;set goal self
            set foundTurk true
            if closestTurk = 0 or distance self < closestTurkDist [
              set closestTurkDist (distance self)
              set closestTurk self
            ]
          ]
        ]
        if foundTurk [
          set goal closestTurk
        ]
      ]
      if unitAggression = 2 [
        let closestTurk 0
        let closestTurkDist 99
        let foundTurk false
        ask patches with [fightNoise = 5 and distance currentGroup <= 2] [
          ;set
          if count Turkish-here > 0 [
            ;set goal self
            set foundTurk true
            if closestTurk = 0 or distance self < closestTurkDist [
              set closestTurkDist (distance self)
              set closestTurk self
            ]
          ]
        ]
        if foundTurk [
          set goal closestTurk
        ]
      ]
      if Urgency > Aggression [
        set goal capturePoint
      ]


      if Urgency = 1 [
        set goal patch-at 0 0
      ]
      if retreating [
        set goal retreatPoint
      ]
      set path astar currentGroup goal
      if not empty? path [
        set path remove first path path
        if not empty? path and first path != last path [
          face first path
          move-to first path
        ]
      ]
    ] [
      set goal findNearestCoast currentGroup
      set landingArea goal
      set path astar currentGroup goal
      if not empty? path [
        set path remove first path path
        face first path
        move-to first path
        if length path = 1 [
          set landed true
        ]
      ]
    ]
  ]
  ]
end

;; If a unit is in an engagement, it will create an area around it that other units might react to
to engagementCloud [ currentGroup ]
  let currentPatch 0
  let fighting false
  let fleeing false
  ;I can't ask patches from non-observer context so I need to make local
  ; variables set to what is going on with the turtles that the patches
  ; will then make use of.
  ask currentGroup [
    set currentPatch patch-at 0 0

    if engaged = true [
      set fighting true
    ]
  ]
  ;Creates an area where other units might react to currently fighting units
  if fighting = true [
    ask patches [
      if distance currentPatch > 4 and distance currentPatch <= 5 and fightNoise <= 1 [
        set fightNoise 1
        set pcolor 68
      ]
      if distance currentPatch > 3 and distance currentPatch <= 4 and fightNoise <= 2 [
        set fightNoise 2
        set pcolor 66
      ]
      if distance currentPatch > 2 and distance currentPatch <= 3 and fightNoise <= 3 [
        set fightNoise 3
        set pcolor 56
      ]
      if distance currentPatch > 1 and distance currentPatch <= 2 and fightNoise <= 4 [
        set fightNoise 4
        set pcolor 54
      ]
      if distance currentPatch >= 0 and distance currentPatch <= 1 and fightNoise <= 5 [
        set fightNoise 5
        set pcolor 52
      ]
    ]
  ]
  ;Finds any patches that have fightNoise on them that should not and sets the noise
  ; back to 0
  let engagementList []
  ask turtles [
    if engaged = true [
      set engagementList lput self engagementList
    ]
  ]
  ask patches [
    if fightNoise > 0 [
      let enemyFightingNearby false
      foreach engagementList [
        if distance ?1 <= 5 [
          set enemyFightingNearby true
        ]
      ]
      if enemyFightingNearby = false [
        set fightNoise 0
        ;set pcolor 0
        set pcolor patchColor
      ]
    ]
  ]
end

;;Retreat goes back to original landing zone
;;  Only retreat if you make it off of the original landing zone.
;;  Other than this, will check troopRetreatNum to see whether or not to go back to retreat location
;;  Merge with any other troops at retreat location
;;  If this puts the troops back above troopRetreatNum, they will go back out trying to get the
;;    objective as usual
to retreat [ currentGroup ]
  ask currentGroup [
    if currentGroup != nobody [
      ifelse troopRetreatNum > troops [
        ;set retreating true
        if patch-at 0 0 != landingArea [
          set retreating true
        ]
      ] [
        set retreating false
      ]
    ]
  ]
  retreatingCloud
end

;; If a unit is retreating from an enemy, it will create an affinity cloud to show that it is retreating
to retreatingCloud
  ask turtles [
    ;show retreatPatches
    if self != nobody [
    ifelse retreating [
      let t self
      let temp []
      ask patches with [ distance t <= 5 ] [
        set temp fput self temp
        if distance t <= 5 and retreatVal < 1 [
          set pcolor 28
          set retreatVal 1
        ]
        if distance t <= 4 and retreatVal < 2 [
          set retreatVal 2
          set pcolor 26
        ]
        if distance t <= 3 and retreatVal < 3 [
          set retreatVal 3
          set pcolor 16
        ]
        if distance t <= 2 and retreatVal < 4[
          set retreatVal 4
          set pcolor 14
        ]
        if distance t <= 1 and retreatVal < 5 [
          set retreatVal 5
          set pcolor 12
        ]
      ]
      foreach temp [
        set retreatPatches fput ?1 retreatPatches
      ]
    ] [
      foreach retreatPatches [
        set retreatVal 0
        set pcolor patchColor
        ;show ?1
      ]
      set retreatPatches []
    ]
    ]
  ]
end

;Combines troops at rally points
;Check if a unit is retreating
;  If so and another troop is nearby, combine them, if this number
;  is greater than troopRetreatNum, set retreating false
to combineTroops
  ;let deadTurts []
  ask turtles [
    if self != nobody and not isDead [
    let turt self
    if member? turt turkishList [
      if troops < troopRetreatNum [
      let allyList turkishList
      set allyList remove turt allyList
      let nearestAlly nearestEnemy turt allyList
      if nearestAlly != turt and distance nearestAlly <= 2 [
        let turtTroops troops
        let smallerUnit false
        ask nearestAlly [
          if isDead [
            ;show "I should be dead"
          ]
          if troops > turtTroops [
            set troops (troops + turtTroops)
            set smallerUnit true
          ]
        ]
        ask self [
          if self != nobody [
            if smallerUnit [
              set isDead true
              set troops 0
            ]
          ]
        ]
      ]
      ]
    ]
    if retreating [
      ifelse member? turt turkishList [

      ] [
        let allyList britishList
        foreach anzacList [
          set allyList fput ?1 allyList
        ]
        set allyList remove turt allyList
        let nearestAlly nearestEnemy turt allyList
        ;show nearestAlly
        if nearestAlly != turt and distance nearestAlly <= 3 [
          let turtTroops troops
          let smallerUnit false
          ask nearestAlly [
            if isDead [
              ;show "I should be dead"
            ]
            if troops > turtTroops [
              set troops (troops + turtTroops)
              set smallerUnit true
            ]
          ]
          ask self [
            if self != nobody [
              ;set deadTurts fput self deadTurts
              if smallerUnit [
                set isDead true
                set troops 0
                foreach retreatPatches [
                  set retreatVal 0
                  set pcolor patchColor
                  ;show ?1
                ]
                set retreatPatches []
              ]
              ;die
            ]
          ]
        ]
      ]
    ]
    ]
  ]
end

;HelpBeaches
;Used if helping the other beaches before going for the main goal
;Check if landed and no enemies remaining nearby
to successfullLanding [ currentGroup ]
  ask currentGroup [
    if currentGroup != nobody [
    if landed and not engaged [
      ;set successfullyLanded true
      set unsuccessfulLandingPatches remove landingArea unsuccessfulLandingPatches
      ;show currentGroup
    ]
    if member? self anzacList [
      let anzacULP unsuccessfulLandingPatches
      if member? patch-at 0 0 unsuccessfulLandingPatches and not engaged [
        set unsuccessfulLandingPatches remove patch-at 0 0 unsuccessfulLandingPatches
      ]
      let tempAnzacList anzacList
      set tempAnzacList remove currentGroup tempAnzacList
      let patchesToRemove []
      foreach tempAnzacList [
        if ?1 != nobody [
        ask ?1 [
          if distance currentGroup <= 2 [
            if unsuccessfulLandingPatches != anzacULP [
              set patchesToRemove fput patch 5 22 patchesToRemove
            ]
          ]
        ]
        ]
      ]
      foreach patchesToRemove [
        set unsuccessfulLandingPatches remove ?1 unsuccessfulLandingPatches
      ]
    ]
    if member? self britishList [
      let britULP unsuccessfulLandingPatches
      if member? patch-at 0 0 unsuccessfulLandingPatches and not engaged [
        set unsuccessfulLandingPatches remove patch-at 0 0 unsuccessfulLandingPatches
      ]
      let tempULP unsuccessfulLandingPatches
      let unitEngaged engaged
      ask neighbors [
        if member? self tempULP and not unitEngaged [
          set tempULP remove patch-at 0 0 tempULP
        ]
      ]
      set unsuccessfulLandingPatches tempULP
      let tempBritList britishList
      set tempBritList remove currentGroup tempBritList
      let patchesToRemove []
      let successfulPatches []
      foreach tempBritList [
        if ?1 != nobody [
        ask ?1 [
          if distance currentGroup <= 2 [
            if unsuccessfulLandingPatches != britULP [
              let uLP unsuccessfulLandingPatches
              foreach britishBeachLocations [
                if not member? ?1 uLP [
                  set successfulPatches fput ?1 successfulPatches
                ]
              ]
            ]
          ]
        ]
        ]
      ]
      set successfulPatches remove-duplicates successfulPatches
      foreach successfulPatches [
        if member? ?1 unsuccessfulLandingPatches [
          set unsuccessfulLandingPatches remove ?1 unsuccessfulLandingPatches
        ]
      ]
    ]
    ]
  ]
end

; This finds the nearest coast patch to the current turtle.  This is useful for
; having the units land at any coast point that is closest to them.
to-report findNearestCoast [ currentGroup ]
  let coast 0
  ask currentGroup [
    if (not landed) [
      let currentPatch patch-at 0 0
      let nearestCoastPatch patch-at 0 0
      let nearestDist 999999
      let availablePatchList coastList
      let allyList britishList
      foreach anzacList [
        set allyList fput ?1 allyList
      ]
      foreach allyList [
        if currentGoal != 0 [
          set availablePatchList remove currentGoal availablePatchList
        ]
      ]
      foreach availablePatchList [
        if (distance-nowrap ?1 < nearestDist) [
          set nearestDist (distance-nowrap ?1)
          set nearestCoastPatch ?1
        ]
      ]
      if (nearestDist != 99 and nearestDist > 0) [
        ;face-nowrap nearestCoastPatch
        ;fd 1
        set coast nearestCoastPatch
      ]
      if (nearestDist < 1) [
        if (nearestDist != 0) [
          move-to nearestCoastPatch
          ;show nearestCoastPatch
        ]
        set landed true
      ]
    ]
  ]
  report coast
end

;; Finds the closest coast patch and moves to it
;; With how the model is currently setup, this does not need A* because
;;  there are no obstacles in the water other than other troops and there are
;;  currently no instances in which troops will collide
to moveToNearestCost [ currentGroup ]
  ask currentGroup [
    if (not landed) [
      let currentPatch patch-at 0 0
      let nearestCoastPatch patch-at 0 0
      let nearestDist 999999
      foreach coastList [
        if (distance-nowrap ?1 < nearestDist) [
          set nearestDist (distance-nowrap ?1)
          set nearestCoastPatch ?1
        ]
      ]
      if (nearestDist != 99 and nearestDist > 0) [
        face-nowrap nearestCoastPatch
        fd 1
      ]
      if (nearestDist < 1) [
        if (nearestDist != 0) [
          move-to nearestCoastPatch
          ;show nearestCoastPatch
        ]
        set landed true
      ]
    ]
  ]
end

;A* search algorithm for finding the route to the goal
to-report astar [ currentGroup goal ]
  let searchPath []
  ask currentGroup [
      let isRetreating retreating
      let currentRetreatVal retreatVal
      let start patch-at 0 0
      let startNeighbors []
      ask start [
        set currentRetreatVal retreatVal
        ask neighbors [
          set startNeighbors fput self startNeighbors
        ]
      ]
      let finished false
      set searchPath []
      let current 0
      let open []
      let closed []

      let onLand false
      if landed [
        set onLand true
      ]

      set open lput start open
      while [ finished != true ] [
        ifelse length open != 0 [
          set open sort-by [[f] of ?1 < [f] of ?2] open
          set current item 0 open
          set open remove-item 0 open
          set closed lput current closed
          ask current [
            let currentHeight height

            ifelse any? neighbors with [ (pxcor = [ pxcor ] of goal) and (pycor = [ pycor ] of goal) ] [
              set finished true
            ] [

            let lowAgglowUrgList lowAgglowUrg currentGroup start
            let lowAgglist lowAgg currentGroup

            ;Compile lists here
            let invalidPatchList []
            set invalidPatchList lowAgglowUrgList
            foreach lowAgglist [
              set invalidPatchList fput ?1 invalidPatchList
            ]
            ;agents cannot move up a height difference greater than 1
            ask neighbors [
              if height - currentHeight > 1 [
                set invalidPatchList fput self invalidPatchList
              ]
            ]
            if onLand [
              ask neighbors with [ height = 0 ] [
                set invalidPatchList fput self invalidPatchList
              ]
            ]

            ;the following line is where I can tell it what satisfies a legal position
            ask neighbors with [ not member? self invalidPatchList and count turtles-here = 0 and (not member? self closed) and (self != parent) ] [
              ;if urgency is a 3, react to aggression, if urgency is a 5, ignore aggression
              if not member? self open and self != start and self != goal [
                set open lput self open
                set parent current
                let gval 3
                if height > currentHeight [
                  set gval 4
                ]
                if height < currentHeight [
                  set gval 2
                ]
                ;The below section is for units to interact with patches with retreatVal > 0
                if member? self startNeighbors [
                  if Aggression > 3 [
                    if retreatVal > 3 [
                      set gval 1
                    ]
                    if retreatVal > 0 and retreatVal <= 3 [
                      set gval 2
                    ]


                  ]
                  if Aggression < 3 [
                    if retreatVal > 3 [
                      set gval 5
                    ]
                    if retreatVal > 0 and retreatVal <= 3 [
                      set gval 4
                    ]
                  ]
                ]
                set g [g] of parent + gVal
                set h distance goal
                set f (g + h)
              ]
            ]
            ]
          ]
        ] [
          ; A unit has no available path to its goal
          set finished true
          ;should I set searchPath to nothing or does it matter much?
          set searchPath []
        ]
      ]


      set searchPath lput current searchPath
      let temp first searchPath
      while [ temp != start ] [
        set searchPath lput [ parent ] of temp searchPath
        set temp [ parent ] of temp
      ]
      set searchPath fput goal searchPath
      set searchPath reverse searchPath


  ]
  report searchPath
end

;Turks have some different interactions from the British and ANZAC forces so
;this is necessary for making sure they do not take into account the other
;interactions.  Otherwise, this is still A* search.
to-report aStarForTurks [ currentGroup goal ]
    let searchPath []
    ask currentGroup [
      let isRetreating retreating
      let start patch-at 0 0
      let startNeighbors []
      ask start [
        ask neighbors [
          set startNeighbors fput self startNeighbors
        ]
      ]
      let finished false
      set searchPath []
      let current 0
      let open []
      let closed []

      set open lput start open
      while [ finished != true ] [
        ifelse length open != 0 [
          set open sort-by [[f] of ?1 < [f] of ?2] open
          set current item 0 open
          set open remove-item 0 open
          set closed lput current closed
          ask current [
            let currentHeight height

            ifelse any? neighbors with [ (pxcor = [ pxcor ] of goal) and (pycor = [ pycor ] of goal) ] [
              set finished true
            ] [
              ; needs to be updated so that they don't walk onto patches with other turtles
              ask neighbors with [ height - currentHeight < 2 and height != 0 and count turtles-here = 0 and (not member? self closed) and (self != parent) ] [
                if not member? self open and self != start and self != goal [
                  set open lput self open
                  set parent current
                  let gval 2
                  if height > currentHeight [
                    set gval 3
                  ]
                  if height < currentHeight [
                    set gval 1
                  ]
                  set g [g] of parent + gVal
                  set h distance goal
                  set f (g + h)
                ]
              ]
            ]
          ]
        ] [
          ; A unit has no available path to its goal
          set finished true
          ;should I set searchPath to nothing or does it matter much?
          set searchPath []
        ]
      ]
      set searchPath lput current searchPath
      let temp first searchPath
      while [ temp != start ] [
        set searchPath lput [ parent ] of temp searchPath
        set temp [ parent ] of temp
      ]
      set searchPath fput goal searchPath
      set searchPath reverse searchPath
    ]
    ;show searchPath
    report searchPath
end

;; Compiles a list of positions a low aggression unit cannot travel on for A*
to-report lowAgg [ currentGroup ]
  ;Low aggression
  let lowAggList []
  if Aggression < 3 [
    let enemyList []
    ifelse member? currentGroup turkishList [
      set enemyList anzacList
      foreach britishList [
        set enemyList fput ?1 enemyList
      ]
    ] [
      foreach turkishList [
        if ?1 != nobody [
          set enemyList fput ?1 enemyList
        ]
      ]
      ;set enemyList turkishList
    ]
    ;remove enemies not in sight
    let sight 2
    foreach enemyList [
      if not (distance currentGroup <= sight) [
        set enemyList remove ?1 enemyList
      ]
    ]
    foreach enemyList [
      ask neighbors [
        if (distance ?1 < distance currentGroup) [
          set enemyList fput self enemyList
        ]
      ]
    ]
    set lowAggList enemyList
  ]
  report lowAggList
end

;; Compiles a list of positions a low aggression/low urgency unit cannot travel on for A*
to-report lowAgglowUrg [ currentGroup start ]
  ;Make the following stuff into separate procedures
  ;Check based on aggression and urgency whether an agent should be moving into a particular
  ; position
  let lowAgglowUrgList []
  if Aggression < 3 and Urgency < 3 [
    let currentFightNoise 0
    ask start [
      set currentFightNoise fightNoise
    ]
    ;show currentFightNoise = fightNoise
    let enemyPatch 0
    ask neighbors [
      if fightNoise > currentFightNoise and fightNoise != 0 [
        set lowAgglowUrgList lput self lowAgglowUrgList
        ;show self
      ]
    ]
    ifelse member? currentGroup turkishList [
      ;will need to be updated when Turks move
      ;would Turks need this though?
    ] [
      ask Turkish [
        ask neighbors4 [
          set lowAgglowUrgList lput self lowAgglowUrgList
        ]
      ]
    ]
  ]
  report lowAgglowUrgList
end

;Tells a unit to attack the closest enemy
;This checks whether a unit is on a higher or lower patch than the one
;  it is attacking to see if attacking power should receive a gain or loss.
;This also checks whether the attacking unit is flanking the other unit.
to attack [ currentUnit ]
  let countEnemies 0
  ask currentUnit [
    ask neighbors [
      ifelse member? currentUnit turkishList [
        if count ANZAC-here != 0 [
          set countEnemies (countEnemies + 1)
        ]
        if count British-here != 0 [
          set countEnemies (countEnemies + 1)
        ]
      ] [
        if count Turkish-here != 0 [
          set countEnemies (countEnemies + 1)
        ]
      ]
    ]
    ask patch-at 0 0 [
      ifelse member? currentUnit turkishList [
        if count ANZAC-here != 0 [
          set countEnemies (countEnemies + 1)
        ]
        if count British-here != 0 [
          set countEnemies (countEnemies + 1)
        ]
      ] [
        if count Turkish-here != 0 [
          set countEnemies (countEnemies + 1)
        ]
      ]
    ]
    ifelse countEnemies > 0 [
      set engaged true
    ] [
      set engaged false
    ]
  ]
  ask currentUnit [
    if engaged = true [
      let enemy 0
      ifelse member? currentUnit turkishList [
        set enemy nearestEnemy currentUnit anzacList
        let britEnemy nearestEnemy currentUnit britishList
        if enemy = currentUnit or distance enemy > distance britEnemy [
          set enemy britEnemy
        ]
        if britEnemy = currentUnit [
          set enemy nearestEnemy currentUnit anzacList
        ]
        ;needs to be updated for britishList
      ] [
        set enemy nearestEnemy currentUnit turkishList
      ]
      ;get patch at currentUnit and enemy, check the height difference
      ;get facing direction of both units
      ask currentUnit [
        face-nowrap enemy
      ]
      let enemyHeight 0
      let enemyHeading 0
      let enemyTroops 0
      ask enemy [
        ask patch-at 0 0 [
          set enemyHeight height
        ]
        set enemyHeading heading
        set enemyTroops troops
      ]
      let myHeight 0
      let myHeading 0
      let myTroops 0
      ask currentUnit [
        ask patch-at 0 0 [
          set myHeight height
        ]
        set myHeading heading
        set myTroops troops
      ]

      ask currentUnit [
        if enemy = currentUnit [
          show "Stop attacking yourself"
        ]
        if enemy != currentUnit and distance enemy <= 2 [
          let effectiveness 5
          let heightDiff (myHeight - enemyHeight)
          let headingDiff abs (myHeading - enemyHeading)
          let flanking 0
          if headingDiff <= 90 and headingDiff > 45 [
            set flanking 1
          ]
          if headingDiff <= 45 [
            set flanking 2
          ]
          let troopAdv 0
          ;1/2, 1/4, 1/8
          if myTroops - enemyTroops > (troopNum / 2) [
            set troopAdv 3
          ]
          if myTroops - enemyTroops > (troopNum / 4) [
            set troopAdv 2
          ]
          if mytroops - enemyTroops > (troopNum / 8) [
            set troopAdv 1
          ]
          set effectiveness (effectiveness + heightDiff + flanking + troopAdv)
          ask enemy [ set troops (troops - effectiveness) ]
          ask enemy [
            if troops <= 0 [
              die
            ]
          ]
        ]
      ]
    ]
  ]
end

;Reports which enemy is closest to it
to-report nearestEnemy [ currentGroup enemyList ]
  let currentX 0.0
  let currentY 0.0
  ask currentGroup [
    set currentX xcor
    set currentY ycor
  ]
  let closestEnemyDist 99999
  let closestEnemy currentGroup
  foreach enemyList [
    if ?1 != nobody and ?1 != currentGroup [
      let enemyDist 0
      ask ?1 [ set enemyDist distancexy-nowrap currentX currentY ]
      if (enemyDist < closestEnemyDist) [
        set closestEnemy ?1
        set closestEnemyDist enemyDist
      ]
    ]
  ]
  ;show enemyList
  ;show closestEnemy
  report closestEnemy
end

;; Checks the unit's combat effectiveness in comparison to an enemy unit
;; Right now this just checks percentage of remaining troops.  If I want, I could use this
;;   to check patches around an enemy to see which is the best to an enemy on or whether
;;   to even engage an enemy in a current position.
;; This would be used when deciding whether to engage an enemy or not (ties in to Aggressiveness)
to-report combatEffectiveness [ currentGroup enemy ]
  let effectiveness 0
  ask currentGroup [
    set effectiveness (troops / troopNum)
  ]
  report effectiveness
end

;Sets the height of the terrain
; 0 - Sea, 1 - Coast, 2 - Low, 3 - Medium, 4 - High
;Terrain is used with the A* search method to determine the most efficient
; route that is possible.
to initializeTerrain
  ask patches [;setting initial height
    set height 0
  ]
  ask patches [;setting colors to be distinct and setting heights
    ;making 5 different colors
    if pcolor = 41.5 or pcolor = 33.4 or pcolor = 41.4 or pcolor = 41.2 or pcolor = 32.3 or pcolor = 32.7
    or pcolor = 22.1 or pcolor = 51.9  [
      set pcolor brown;
    ]
    if shade-of? pcolor yellow or pcolor = 51.2 [
      set pcolor yellow;
    ]
    if shade-of? pcolor red or pcolor = 23.5 or pcolor = 31.4 or pcolor = 31.7 or pcolor = 21.9 or pcolor = 51.1 [
      set pcolor red;
    ]
    if shade-of? pcolor blue or shade-of? pcolor sky or pcolor = 4.1 [
      set pcolor sky;
    ]
    if shade-of? pcolor green [
      set pcolor 53;
    ]
    ask patch 7 22 [
      set pcolor 53;
    ]
    ask patch 6 22 [
      set pcolor brown;
    ]
    ask patch 8 19 [
      set pcolor 53;
    ]
    ask patch -8 -13 [
      set pcolor 53;
    ]
    ask patch -10 -18 [
      set pcolor 53;
    ]
    let i 33
    while [ i > 17 ] [
      ask patch 33 i [
        set pcolor brown
      ]
      set i (i - 1)
    ]
    while [ i > 11 ] [
      ask patch 33 i [
        set pcolor sky
      ]
      set i (i - 1)
    ]
    while [ i > -34 ] [
      ask patch 33 i [
        set pcolor yellow
      ]
      set i (i - 1)
    ]

    ;setting the heights
    if pcolor = yellow [
      set height 1
    ]
    if pcolor = brown [
      set height 2
    ]
    if pcolor = 53 [
      set height 3
    ]
    if pcolor = red [
      set height 4
    ]
    if pcolor = 0 [
      set height 4;
    ]
  ]
  ask patches [;the colored edges of the topo show up under the main image, this makes the edges white
    ;set pcolor 9.9999
    set patchColor pcolor
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
756
577
33
33
8.0
1
10
1
1
1
0
1
1
1
-33
33
-33
33
1
1
1
ticks
30.0

BUTTON
4
10
67
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
81
10
144
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
8
55
135
88
showLabels
showLabels
0
1
-1000

SWITCH
8
97
136
130
Terrain
Terrain
1
1
-1000

SLIDER
12
206
184
239
Aggression
Aggression
1
5
3
1
1
NIL
HORIZONTAL

SLIDER
12
244
184
277
Urgency
Urgency
1
5
1
1
1
NIL
HORIZONTAL

SWITCH
12
282
138
315
HelpBeaches
HelpBeaches
1
1
-1000

PLOT
773
11
973
161
Ottomans Remaining
Time
Ottoman Troops
0.0
200.0
0.0
5000.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot turkCount"

PLOT
772
169
972
319
British Remaining
Time
British Troops
0.0
200.0
0.0
5000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot briCount"

PLOT
773
327
973
477
ANZAC Remaining
Time
ANZAC Troops
0.0
200.0
0.0
5000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot anzCount"

@#$#@#$#@
## WHAT IS IT?

This is Green Team's model for Gallipoli.  The model is intended to help illustrate the benefits and negatives of giving troops autonomy in a battle.

## HOW IT WORKS

The ANZAC and British land at the beaches they historically landed at and then will try to secure their objectives of Hill 971 and Krithia respectively.  To do so, they use A* to search for the best route on the peninsula that the troops would know of.  This takes into account the terrain of the land.  It costs more to go up terrain than stay on level terrain and troops are unable to go up 2 levels of terrain in one move.

Along the way, they can fight or try to avoid Turkish troops based on the amount of Urgency and Aggressiveness.  Urgency is the agent's desire to go straight for the goal and Aggressiveness is the agent's desire to engage an enemy it currently knows of.

The Ottoman troops at the top and bottom of the peninsula move to and engage in combat with the troops nearest to them.  The Ottomans in the middle move to whichever area needs help the most.

## HOW TO USE IT

Press setup then go and the simulation will run.

If you want to see how many troops each agent on the screen carries, toggle on the showLabels switch.

If you want to see the terrain and the affinities, toggle on the Terrain switch.

Adjusting Aggression and Urgency will change the behavior of the agents.

Turning on HelpBeaches causes the British and ANZAC troops to help any beaches around their landing zone before trying to advance to the main objectives.

## CREDITS AND REFERENCES

Made by the Green Team in Modeling, Simulation, and Military Gaming.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="showLabels">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Terrain">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Autonomous">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
