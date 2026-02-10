; A model to illustrate the fitness landscape idea of evolution.

patches-own [ fitness change ]
globals [ time ]

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set time 0
  setup-patches
  setup-turtles
  reset-ticks
end

; This creates the fitness landscape by assigning a "fitness" variable for each patch, and then
; smoothing it by diffusing the fitness variable to neighbouring
; patches a number of times specified by the smoothness slider.
; The fitness variable is then rescaled to lie between 0 and 100, with a range specified by
; the value on the range slider. The landscape is then colored a scale of green with white
; corresponding to fitness of 100 and black a fitness of 0.
to setup-patches
  ask patches [ set fitness (random 100) ]
  repeat smoothness [ diffuse fitness 1 ]
  rescale
  color-landscape
end

; The initial turtle population, with random ages and colors is spatially distributed
; at a distance between 0 and the mutation rate from the origin. This distribution represents
; a variation in the phenotypes of the initial population.
; colors.
to setup-turtles
    crt number [
        if (shade-of? green color) [ set color red ]
        jump (random-float 10 * mutation)  ]
end


; Turtles are selected to die with a probability determined by their age and their fitness (see death
; procedure). Surviving turtles are allowed to reproduce to replace lost turtles. There are two
; additional options. If the landscape is selected to change then the fitness of the patches is allowed
; to change in a way that preserves the degree of smoothness, but allowing peaks and valleys to
; gradually shift. This is achieved by introducing a patch-own "change" variable that is smoothed
; the appropriate amount before being added to the fitness variable in the update-landscape procedure.
; the other option is to add new turtles at the location of your mouse in order to "speed up" the
; evolutionary process if the turtles are not evolving to highest fitness over time.
to go
  death
  birth
  do-plots
  if changing-landscape? [
      diffuse change 1  ; this will diffuse "smoothness" number of times before the fitness is changed.
      if time > smoothness [update-landscape set time 0 ]
      set time time + 1 ]
  if mouse-down? [
      ask one-of turtles [die]
      crt 1 [
                               set color red
                               setxy mouse-xcor mouse-ycor ]
      wait 0.1 ]
end


; This is the procedure where the fitness of a turtle as determined by its location on the landscape
; comes into play. If a turtle is older than a random number between 0 and the fitness of its location
; it dies. In this way fitter turtles tend to live longer and hence have more opportunities to reproduce.
to death
    ask turtles [
        if count turtles > number  [
            die] ]
end


; Turtles are selected at random to reproduce until the maximum number supported by the environment is
; reached. Probability of reproduction is not directly related to fitness. Fitness of real organisms is
; related to probability of surviving to reproductive age and number of offspring produced. However in this
; model we assume that all living turtles have the same probability of reproduction, and fitness only relates to probability
; survival.
to birth

            ask  turtles [
              let competition 0
              if speciation? [set competition count turtles in-radius  mutation ]
              if fitness - competition > random 100 [
                hatch 1 [
                    jump (random-float mutation)
                    rt random 360  ]  ] ]
end


; This a simple linear rescaling that is centered on a fitness of 50 with a total range determined
; by the slider. The maximum allowed range is 100 because we want the maximum allowed fitness to be
; 100 and the mininum allowed fitness to be 0. If the range is allowed to be larger than 100 then
; the coloring of the landscape will look strange.
to rescale
   let highest max [ fitness ] of patches
   let lowest min [ fitness ] of patches
   ifelse (highest - lowest) = 0
      [ask patches [set fitness 50] ]
      [ask patches [ set fitness landscape-range * (fitness - lowest) / (highest - lowest) + (99 - landscape-range) / 2] ]
end

; Color the patches a scale of green according to their fitness value, with 0 being black and 100 being
; white.
to color-landscape
     ask patches [ set pcolor scale-color green fitness 0 100]
end

; Keep track of average fitness over time
to do-plots
  set-current-plot "Average Fitness"
  plot mean [ fitness ] of turtles
end

; when the landscape is allowed to change over time add the appropriately smoothed change variable
; to the fitness variable, and then recalculate the change for the next time step.
to update-landscape
  ask patches [set fitness fitness + change
               set change (random landscape-change-rate) ]
  rescale
  color-landscape
end
@#$#@#$#@
GRAPHICS-WINDOW
227
10
721
505
-1
-1
6.0
1
10
1
1
1
0
1
1
1
-40
40
-40
40
0
0
1
ticks
30.0

BUTTON
11
10
111
57
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
110
10
208
57
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

SLIDER
13
60
209
93
smoothness
smoothness
0
50
28.0
1
1
NIL
HORIZONTAL

SLIDER
11
133
210
166
number
number
0
10000
2446.0
1
1
NIL
HORIZONTAL

SLIDER
11
169
211
202
mutation
mutation
0
10
2.5
0.1
1
NIL
HORIZONTAL

PLOT
9
219
209
369
Average Fitness
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
9
411
210
444
landscape-change-rate
landscape-change-rate
0
200
0.0
10
1
NIL
HORIZONTAL

SWITCH
9
375
210
408
changing-landscape?
changing-landscape?
0
1
-1000

SLIDER
12
96
210
129
landscape-range
landscape-range
1
100
100.0
1
1
NIL
HORIZONTAL

SWITCH
13
451
131
484
Speciation?
Speciation?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

Fitness Landscape is a NetLogo model that illustrates the principle of evolution as movement of a species through a fitness landscape over time. One imagines that the phenotype of a species is specified by two quantitative variables, and that the fitness of this species depends on the values of these variables (for example, the fitness of a species of bird might depend on beak size and body mass). For some values of these variables the fitness is high, for others it is low. As individuals from a group die and others reproduce the species drifts across the landscape towards fitness peaks.

## HOW IT WORKS

The fitness is indicated on the world view by color, with white being high and dark low. The x and y axis represent the two variables that specify the phenotype of the turtles. The landscape in this model is generated by randomly assigning each patch a fitness value and then smoothing the landscape to the desired degree of smoothness by
diffusing the fitness variable between patches a number of times specified by the smoothness slider on the interface. The range variable on the interface specifies the difference between the maximum fitness and minimum fitness -- this effectively sets the steepness of the fitness slopes.

At the start of the simulation a number of turtles are generated in a small circle near the center of the landscape. The radius of the circle represents the initial variation of the phenotypic variables (For example if these variables represent beak size and body mass then each turtle has slightly different natural beak size and bodymass). The turtles age by one each time step and have a probability of dying which depends on their age and their fitness as determined by the patch they are on. Specifically, if they are older than a random number between 0 and their fitness then they die. Thus as they age they are more likely to die, but if they have high fitness they are less likely to die. If the population is reduced due to death then turtles are selected at random to reproduce until the population recovers. The new turtles are hatched a small distance from the parent in the fitness landscape -- this distance represents a slight mutation in the phenotypic variables of the parent.

There is an option to have the landscape change slowly in time. In the natural world the fitness corresponding to particular values of the phenotypic variables change over time, due to changes in the environment. For example, if changing climate destroys the main food source of birds with long beaks, then long beaked birds would have a reduced fitness. The landscape changes by adding a random number to the fitness, then smoothing and rescaling, so that the range and smoothness are retained. The effect is to have the fitness peaks gradually moving around over time.

There is also an option to include a feedback mechanism where the fitness of individuals is reduced if there are too many other individuals with the same, or similar geneome. The result of this type of feed back is speciation so the button to activiate this is called speciation.

## HOW TO USE IT

Choose values for the smoothness and range of the landscape. Select the number of turtles and the mutation, which indicates both the variation in the initial population and the distance that new turtles hatch from their parent. Click setup and go. You should see the population gradually drifting through the landscape in the general direction of the nearest peak in fitness. Individuals do not move through the landscape. Rather, turtles that are fitter are less likely to die and hence have more opportunities to reproduce. The offspring are hatched a small distance in phenotype space from their parent (the distance being a measure of the amount of mutation) and it is in this way that the population drifts up the fitness peaks.

If you want the landscape to change in time turn on "changing landscape" and choose the rate at which you want it to change.

## THINGS TO NOTICE

With a constant landscape, the first thing to notice is that the population of turtles does gradually drift up the fitness landscape to local fitness peaks, although there are frequently groups of turtles that survive for a time away from the peaks. These are less than optimally fit subgroups who survive by random chance. The graph will show average fitness increasing, but with some fluctuations.

You will notice that the initial turtle population is randomly colored, but after some time one color comes to dominate. There is no selection pressure on the color of the turtles. The fact that one color ends up dominating is a result of what is known as genetic drift. If two species are equally fit in an environment with limited resources, then over time, due to random fluctuations in population size one species will end up taking over. Sometimes you will see genetic drift acting when the population splits into two groups, one will die out, even if both groups have similar fitness. (Indeed occasionally a "fitter" but smaller group will die out for the same reason.)

## THINGS TO TRY

As the simulation runs try increasing the mutation. As a result the average fitness of the population will usually decrease, but over time it will increase again as the population settles on a higher peak. One way to get to a high peak of fitness is to have the mutation high initially and then gradually decrease it. This illustrates how mutation rates determine the rate and degree of evolution. A higher mutation rate allows more possibility to explore phenotype space over time, but in the short term a smaller mutation rate allows for a higher average fitness.

Allow the population to drift to a fitness peak and then drop the mutation rate low (around 0.2). Now allow the landscape to change. You will see that if the landscape changes rapidly the fitness of the population drops as the peak moves a way. This illustrates how phenotypic variables that are not susceptible to mutation can be detrimental to a species in the event catastrophic changes to environment.

Try reducing the range of the landscape to zero. Then all turtles are equally fit. Turtles should spread out somewhat but will still be localized in a group. The group will randomly drift around the landscape. Notice that one color ends up taking over; which is another demonstration of genetic drift.

## EXTENDING THE MODEL

One extension to the model would be to allow groups of individuals which are sufficiently far apart in phenotype space to be independent of each, in that they no longer compete for the same resources. This is one way that speciation can occur in nature.  This might be achieved by restricting the number of new turtles born in a way that depends on the number of turtles in the neighbourhood of the turtles that die. Turtles that are a long way in phenotype space may have such different features that they no longer compete (for example, long and short beaked birds might learn to eat different food sources, and hence will no longer be in direct competition for limited resources -- they will only compete with birds who eat the same food.

## RELATED MODELS

See other Evolution based models in this series

## CREDITS AND REFERENCES

   Copyright 2006 David McAvity

This model was created at the Evergreen State College, in Olympia Washington
as part of a series of applets to illustrate principles in physics and biology.

Funding was provided by the Plato Royalty Grant.

The model may be freely used, modified and redistributed provided this copyright is included and the resulting models are not used for profit.

Contact David McAvity at mcavityd@evergreen.edu if you have questions about its use.
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
Circle -7500403 true true 30 30 240

circle 2
false
0
Circle -7500403 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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
Polygon -7500403 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7500403 true true 75 120 105 210 195 210 225 120 150 75

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
