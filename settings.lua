local settings = {}

settings.title = "Avoidant"
settings.version = "0.8.0"

settings.width = 1280
settings.height = 720

settings.speedMax = 300
settings.playerAttractionForce = 600
settings.playerRepulsionForce = 400
settings.deadRepulsionForce = 300
settings.repulsionCutOff = 200
settings.attractionCutOff = 500

settings.mookForce = 300
settings.mookForceCutOff = 200

settings.centripetalForce = 200

settings.playerSpeedMax = 30
settings.playerMaxSpeed = 800
settings.playerMinSpeed = 400
--sensitivity = 1.2

settings.pad = true

settings.stateChangeMaxTime = 7
settings.mookSpawnMaxTime = 3
settings.deadTime = 1
settings.mookMaxAmmount = 30
settings.performanceGraceTime = 10

settings.timePenalty = 0

settings.multiplierDecreaseSpeed = 0.3
settings.multiplierChangeRate = 30
settings.multiplierGrowthAdvantage = 1.1
settings.multiplierMin = 1
settings.multiplierMax = 2
settings.multiplierMinDistance = 40

settings.scoreMinDistance = 60
settings.scoreMaxDistance = 150

settings.maxHighScores = 10

settings.tutorialText = [[Use your [gamepad stick] to guide the yellow player character.

						Evade the enemies. You can use [trigger] for a burst of speed.

						The enemies that only have an outline will try to get you, while
						enemies that are full of color (and are the same shape
						as you) will try to avoid you. Every few seconds your shape will
						change and the enemies will alter their behaviour accordingly.

						You need to play for 30 seconds to win. But there's a twist...

						The timer only goes down when you are near the enemies
						of the same shape. The closer you are, the faster the clock ticks.
						You will see a lighting that tells you how fast the clock is ticking
						down, colored from yellow to purple, slow to fast.
						The circle around you fills as you advance the timer.

						If you touch any enemy, you will be disabled for a few seconds.


						Press [f] to disable the glow shader in game.
						Press [m] to mute the music.]]

settings.tutorialText = [[Use your [gamepad stick] to guide the yellow player character.

						Evade the enemies. You can use [trigger] for a burst of speed.

						The enemies that only have an outline will try to get you, while
						enemies that are full of color (and are the same shape
						as you) will try to avoid you. Every few seconds your shape will
						change and the enemies will alter their behaviour accordingly.

						To win you need to collect energy from you enemies. When you get
						close to an enemy of the same shape as you, the energy will flow
						into you in form of a lighting. The closer you are to the enemy,
						the faster the energy flows. The ring around you indicates how
						much energy you have collected. Try to be as fast as you can.

						If you hit any enemy, you will be disabled for a few seconds.


						Press [f] to disable the glow shader in game.
						Press [m] to mute the music.
						
						Song: Connor O.R.T. Linning - DN38416]]

settings.credits = [[BlackBulletIV]]


return settings