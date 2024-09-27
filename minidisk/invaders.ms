import "mathUtil"
clear
textColorBeforeStart = display(3).color

SCALE = 4
BOTTOM_OFFSET = 16
LEFT_BORDER = 6* SCALE
RIGHT_BORDER = 960 - 6 * SCALE
TOP_BORDER = 640 + 2 * SCALE
ENEMY_SPAWN_HEIGHT = 342
ANIMATION_SPEED = 2
INVADER_LARGE = 1
INVADER_MEDIUM = 2
INVADER_SMALL = 3

pew = new Sound
pew.init 0.2, [5800,4800,200], [1,0.8,0]

invaderPew = new Sound
invaderPew.init 0.2, [5400,4600,200], [1,0.8,0]

hitSnd = new Sound
hitSnd.init 0.25, [50,20], [1,0], Sound.noiseWave

wallHitSnd = new Sound
wallHitSnd.init 0.25, [70,40], [0.6,0], Sound.noiseWave

largeInvaderSheet = file.loadImage("images/large_invader.png")
largeInvaderFrames = [
    largeInvaderSheet.getImage(0,0,12,8),
    largeInvaderSheet.getImage(12,0,12,8)]
mediumInvaderSheet = file.loadImage("images/medium_invader.png")
mediumInvaderFrames = [
    mediumInvaderSheet.getImage(0,0,11,8),
    mediumInvaderSheet.getImage(11,0,11,8)]
smallInvaderSheet = file.loadImage("images/small_invader.png")
smallInvaderFrames = [
    smallInvaderSheet.getImage(0,0,8,8),
    smallInvaderSheet.getImage(8,0,8,8)]


display(2).mode = displayMode.tile
tileDisplay = display(2)
tileDisplay.tileSet = file.loadImage("images/barrier_tile_set.png")
tileDisplay.tileSetTileSize = 8
tileDisplay.cellSize = 4
tileDisplay.extent = [240,160]
tileDisplay.clear 0

for col in range(0,239)
    for row in range(0,159)
        tileDisplay.setCellTint col,row, color.lime
    end for
end for

spawnBarrier = function(col)
    for row in range(15,27)
        if row <= 24 then tileDisplay.setCell col, row, 1
        if row <= 25 then tileDisplay.setCell col+1, row, 1
        if row <= 26 then tileDisplay.setCell col+2, row, 1
        if row <= 27 then tileDisplay.setCell col+3, row, 1
        if row >= 19 then tileDisplay.setCell col+4, row, 1
        if row >= 20 then tileDisplay.setCell col+5, row, 1
        if row >= 21 then tileDisplay.setCell col+6, row, 1
        if row >= 21 then tileDisplay.setCell col+7, row, 1
        if row >= 21 then tileDisplay.setCell col+8, row, 1
        if row >= 21 then tileDisplay.setCell col+9, row, 1
        if row >= 21 then tileDisplay.setCell col+10, row, 1
        if row >= 21 then tileDisplay.setCell col+11, row, 1
        if row >= 21 then tileDisplay.setCell col+12, row, 1
        if row >= 20 then tileDisplay.setCell col+13, row, 1
        if row >= 19 then tileDisplay.setCell col+14, row, 1
        if row <= 27 then tileDisplay.setCell col+15, row, 1
        if row <= 26 then tileDisplay.setCell col+16, row, 1
        if row <= 25 then tileDisplay.setCell col+17, row, 1
        if row <= 24 then tileDisplay.setCell col+18, row, 1
    end for
end function

spawnBarrier 38
spawnBarrier 86
spawnBarrier 134
spawnBarrier 182

explosionSheet = file.loadImage("images/invader_explosion.png")
explosionFrames = [ 
    explosionSheet.getImage(0,0,12,8),
    explosionSheet.getImage(12,0,12,8),
    explosionSheet.getImage(24,0,12,8),
    explosionSheet.getImage(36,0,12,8)]

player = {}
player.sprite = new Sprite
player.sprite.image = file.loadImage("images/player.png")
player.sprite.tint = color.lime
player.sprite.scale = SCALE
player.sprite.localBounds = new Bounds
player.sprite.localBounds.width = player.sprite.image.width
player.sprite.localBounds.height = player.sprite.image.height
player.sprite.x = LEFT_BORDER
player.sprite.y = 3*SCALE+BOTTOM_OFFSET
player.speed = 400

extraLive1 = new Sprite
extraLive1.image = file.loadImage("images/player.png")
extraLive1.tint = color.lime
extraLive1.scale = SCALE
extraLive1.x = RIGHT_BORDER-(extraLive1.image.width/2+2*SCALE)
extraLive1.y = 640-18

extraLive2 = new Sprite
extraLive2.image = file.loadImage("images/player.png")
extraLive2.tint = color.lime
extraLive2.scale = SCALE
extraLive2.x = RIGHT_BORDER-(extraLive1.image.width/2+(4+extraLive1.image.width)*SCALE)
extraLive2.y = 640-18

missile = {}
missile.sprite = new Sprite
missile.sprite.image = file.loadImage("images/player_shot.png")
missile.sprite.scale = SCALE
missile.sprite.localBounds = new Bounds
missile.sprite.localBounds.width = missile.sprite.image.width
missile.sprite.localBounds.height = missile.sprite.image.height
missile.sprite.x = -1
missile.sprite.y = TOP_BORDER
missile.speed = 700
missile.deployed = false

enemyMissile = {}
enemyMissile.sprite = new Sprite
enemyMissile.sprite.image = file.loadImage("images/player_shot.png")
enemyMissile.sprite.scale = SCALE
enemyMissile.sprite.localBounds = new Bounds
enemyMissile.sprite.localBounds.width = enemyMissile.sprite.image.width
enemyMissile.sprite.localBounds.height = enemyMissile.sprite.image.height
enemyMissile.sprite.x = -1
enemyMissile.sprite.y = TOP_BORDER
enemyMissile.speed = 400
enemyMissile.deployed = false
enemyMissile.shotDelay = 2 + rnd

invaders = []
explosions = []

createInvaderRow = function(rowNumber, type, color)
    for i in range(0,11)
        noob = {}
        noob.sprite = new Sprite
        noob.type = type
        if type == INVADER_LARGE then noob.sprite.image = largeInvaderFrames[0]
        if type == INVADER_MEDIUM then noob.sprite.image = mediumInvaderFrames[0]
        if type == INVADER_SMALL then noob.sprite.image = smallInvaderFrames[0]
        noob.sprite.scale = SCALE
        noob.sprite.localBounds = new Bounds
        noob.sprite.localBounds.width = noob.sprite.image.width
        noob.sprite.localBounds.height = noob.sprite.image.height
        noob.sprite.x = LEFT_BORDER + i*SCALE*16
        noob.sprite.y = ENEMY_SPAWN_HEIGHT + rowNumber*SCALE*12
        noob.sprite.tint = color
        invaders.push noob
    end for
end function

addExplosion = function(x,y)
    noob = {}
    noob.sprite = new Sprite
    noob.sprite.scale = SCALE
    noob.sprite.x = x
    noob.sprite.y = y
    noob.sprite.image = explosionFrames[0]
    noob.elapsedTime = 0
    noob.timeToLive = 0.2
    explosions.push noob
    display(4).sprites.push noob.sprite
end function

startWave = function
    createInvaderRow 1, INVADER_LARGE, color.red
    createInvaderRow 2, INVADER_LARGE, color.orange
    createInvaderRow 3, INVADER_MEDIUM, color.yellow
    createInvaderRow 4, INVADER_MEDIUM, color.green
    createInvaderRow 5, INVADER_SMALL, color.purple
    globals.invaderSpeed = 10 + 10*globals.waves
    globals.killsTillSpeedup = 8
    globals.currentKillCounter = 0
    globals.invaderDir = 1
    for invader in invaders
        display(4).sprites.push invader.sprite
    end for
end function


printScore = function(score)  
    display(3).clear
    display(3).color = color.white
    display(3).row = 25
    display(3).column = 0
    display(3).print "Score:"
    display(3).row = 25
    display(3).color = color.lime
    display(3).column = 7
    display(3).print score
    display(3).row = 25
    display(3).column = 29
    display(3).color = color.white
    display(3).print "Wave:"
    display(3).row = 25
    display(3).color = color.lime
    display(3).column = 35
    display(3).print waves+1
    display(3).row = 25
    display(3).column =  53
    display(3).color = color.white
    display(3).print "Lives:"
end function

collideWithBarriers = function(missile)
    missleCorners = missile.sprite.worldBounds.corners
    left = missleCorners[0][0]
    right = missleCorners[0][0]
    top = missleCorners[0][1]
    bottom = missleCorners[0][0]
    for i in range(1,3)
        if missleCorners[i][0] < left then left = missleCorners[i][0]
        if missleCorners[i][0] > right then right = missleCorners[i][0]
        if missleCorners[i][1] < bottom then bottom = missleCorners[i][1]
        if missleCorners[i][1] > top then top = missleCorners[i][1]
    end for

    for col in range(floor((left)/4)-1,ceil((right)/4))
        for row in range(floor((bottom)/4)-1,ceil((top)/4)+1)
            if tileDisplay.cell(col, row) == 0 then continue
            if missile.sprite.contains(col*4,row*4) then
                wallHitSnd.play
                tileDisplay.setCell col, row, 0
                if rnd >= 0.5 then tileDisplay.setCell col-1, row, 0
                if rnd >= 0.5 then tileDisplay.setCell col+1, row, 0
                return true
            end if
        end for
    end for
    return false
end function

resetEnemyMissile = function
    enemyMissile.sprite.y = TOP_BORDER
    enemyMissile.deployed = false
    enemyMissile.shotDelay = 2 + rnd
end function

loseGame = function
    clear
    display(3).color = color.white
    display(3).row = 13
    display(3).column = 29
    print "GAME OVER!"
    display(3).row = 11
    display(3).column = 29
    print "SCORE: "
    display(3).row = 11
    display(3).column = 36
    display(3).color = color.lime
    print score
    globals.gameOver = true
    wait 2
end function

invaderSpeed = 10
invaderDir = 1
killsTillSpeedup = 8
currentKillCounter = 0
score = 0
extraLives = 2
waves = 0
startWave

display(4).sprites.push player.sprite
display(4).sprites.push missile.sprite
display(4).sprites.push enemyMissile.sprite
display(4).sprites.push extraLive1
display(4).sprites.push extraLive2

spaceJustPressed = false
lastTimestamp = time
gameOver = false

while not key.pressed("escape") and not gameOver
    currentTimestamp = time
    delta = currentTimestamp - lastTimestamp
    lastTimestamp = currentTimestamp
    changeDirection = false
    
    for invader in invaders
        if invader.type == INVADER_LARGE then
            invader.sprite.image = largeInvaderFrames[
                currentTimestamp * ANIMATION_SPEED % largeInvaderFrames.len]
        else if invader.type == INVADER_MEDIUM then
            invader.sprite.image = mediumInvaderFrames[
                currentTimestamp * ANIMATION_SPEED % mediumInvaderFrames.len]
        else if invader.type == INVADER_SMALL then
            invader.sprite.image = smallInvaderFrames[
                currentTimestamp * ANIMATION_SPEED % smallInvaderFrames.len]
        end if
        invader.sprite.x = mathUtil.clamp(
            invader.sprite.x + invaderDir*invaderSpeed*delta,
            LEFT_BORDER,
            RIGHT_BORDER)
        if invaderDir > 0 and invader.sprite.x >= RIGHT_BORDER then
            changeDirection = true
        else if invaderDir < 0 and invader.sprite.x <= LEFT_BORDER then
            changeDirection = true
        end if
    end for

    if changeDirection then
        invaderDir = invaderDir * -1
        for invader in invaders
            invader.sprite.y = invader.sprite.y - 12 * SCALE
        end for
    end if

    player.sprite.x = mathUtil.clamp(
        player.sprite.x + key.axis("Horizontal") * player.speed * delta,
        LEFT_BORDER,
        RIGHT_BORDER)
    
    if missile.deployed then
        missile.sprite.y = missile.sprite.y + missile.speed * delta
        hitBarrier = collideWithBarriers(missile)

        if hitBarrier then
            missile.sprite.y = TOP_BORDER
            missile.deployed = false
        else
            toBeRemoved = null
            for invader in invaders
                if invader.sprite.overlaps(missile.sprite) then
                    toBeRemoved = invader
                    break
                end if
            end for
            if toBeRemoved then
                hitSnd.play
                missile.sprite.y = TOP_BORDER
                invaders.remove invaders.indexOf(toBeRemoved)
                display(4).sprites.remove(
                    display(4).sprites.indexOf(toBeRemoved.sprite))
                currentKillCounter = currentKillCounter + 1
                if toBeRemoved.type == INVADER_LARGE then score = score + 10
                if toBeRemoved.type == INVADER_MEDIUM then score = score + 20
                if toBeRemoved.type == INVADER_SMALL then score = score + 30
                addExplosion toBeRemoved.sprite.x, toBeRemoved.sprite.y
            end if
            if missile.sprite.y > TOP_BORDER then missile.deployed = false
            if currentKillCounter >= killsTillSpeedup then
                currentKillCounter = 0
                killsTillSpeedup = ceil(killsTillSpeedup/2)
                invaderSpeed = invaderSpeed + 5
            end if
        end if
    else if key.pressed("space") and not spaceJustPressed then
        missile.sprite.x = player.sprite.x
        missile.sprite.y = player.sprite.y + 4*SCALE
        missile.deployed = true
        pew.play
    end if

    
    if enemyMissile.deployed then
        enemyMissile.sprite.y = enemyMissile.sprite.y - enemyMissile.speed * delta
        if collideWithBarriers(enemyMissile) or enemyMissile.sprite.y < -2*SCALE then resetEnemyMissile
        if player.sprite.overlaps(enemyMissile.sprite) then
            hitSnd.play
            addExplosion player.sprite.x, player.sprite.y
            player.sprite.x = LEFT_BORDER
            extraLives = extraLives - 1
            resetEnemyMissile
            if extraLives < 0 then loseGame
        end if
    else
        enemyMissile.shotDelay = enemyMissile.shotDelay - delta
        if enemyMissile.shotDelay <= 0 then
            shooter = invaders[floor(rnd*invaders.len)]
            enemyMissile.sprite.x = shooter.sprite.x
            enemyMissile.sprite.y = shooter.sprite.y
            invaderPew.play
            enemyMissile.deployed = true
        end if
    end if

    if invaders.len <= 0 then
        waves = waves + 1
        startWave
    end if

    for invader in invaders   
        if invader.sprite.y <= BOTTOM_OFFSET + 32*SCALE then
            loseGame
        end if
    end for

    toBeRemoved = null
    for explosion in explosions
        explosion.elapsedTime = explosion.elapsedTime + delta
        explosion.sprite.image = explosionFrames[mathUtil.clamp(
            floor(explosion.elapsedTime/(explosion.timeToLive/explosionFrames.len)),
            0,
            explosionFrames.len-1)]
        if explosion.elapsedTime >= explosion.timeToLive then
            toBeRemoved = explosion
            break
        end if
    end for

    if toBeRemoved then
        explosions.remove explosions.indexOf(toBeRemoved)
        display(4).sprites.remove display(4).sprites.indexOf(toBeRemoved.sprite)
    end if
    if extraLives >= 2 then extraLive2.tint = color.lime else extraLive2.tint = color.gray
    if extraLives >= 1 then extraLive1.tint = color.lime else extraLive1.tint = color.gray
    printScore score
    spaceJustPressed = key.pressed("space")
    yield
end while

key.clear
display(3).color = textColorBeforeStart
clear