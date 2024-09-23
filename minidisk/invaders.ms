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

largeInvaderSheet = file.loadImage("images/large_invader.png")
largeInvaderFrames = [largeInvaderSheet.getImage(0,0,12,8),largeInvaderSheet.getImage(12,0,12,8)]
mediumInvaderSheet = file.loadImage("images/medium_invader.png")
mediumInvaderFrames = [mediumInvaderSheet.getImage(0,0,11,8),mediumInvaderSheet.getImage(11,0,11,8)]
smallInvaderSheet = file.loadImage("images/small_invader.png")
smallInvaderFrames = [smallInvaderSheet.getImage(0,0,8,8), smallInvaderSheet.getImage(8,0,8,8)]

gfx.color = color.lime
gfx.fillRect 152, 64, 80, 20
gfx.fillRect 344, 64, 80, 20
gfx.fillRect 536, 64, 80, 20
gfx.fillRect 728, 64, 80, 20

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
player.sprite.x = LEFT_BORDER
player.sprite.y = 3*SCALE+BOTTOM_OFFSET
player.speed = 400

missile = {}
missile.sprite = new Sprite
missile.sprite.image = file.loadImage("images/player_shot.png")
missile.sprite.scale = SCALE
missile.sprite.localBounds = new Bounds
missile.sprite.localBounds.width = missile.sprite.image.width
missile.sprite.localBounds.height = missile.sprite.image.height
missile.sprite.x = -1
missile.sprite.y = TOP_BORDER
missile.speed = 1200
missile.deployed = false

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

createInvaderRow 0, INVADER_LARGE, color.red
createInvaderRow 1, INVADER_LARGE, color.orange
createInvaderRow 2, INVADER_LARGE, color.yellow
createInvaderRow 3, INVADER_MEDIUM, color.green
createInvaderRow 4, INVADER_MEDIUM, color.aqua
createInvaderRow 5, INVADER_SMALL, color.purple

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
end function

invaderSpeed = 10
invaderDir = 1

killsTillSpeedup = 16
currentKillCounter = 0
score = 0

for invader in invaders
    display(4).sprites.push invader.sprite
end for
display(4).sprites.push player.sprite
display(4).sprites.push missile.sprite

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
            invader.sprite.image = largeInvaderFrames[currentTimestamp * ANIMATION_SPEED % largeInvaderFrames.len]
        else if invader.type == INVADER_MEDIUM then
            invader.sprite.image = mediumInvaderFrames[currentTimestamp * ANIMATION_SPEED % mediumInvaderFrames.len]
        else if invader.type == INVADER_SMALL then
            invader.sprite.image = smallInvaderFrames[currentTimestamp * ANIMATION_SPEED % smallInvaderFrames.len]
        end if
        invader.sprite.x = mathUtil.clamp(invader.sprite.x + invaderDir*invaderSpeed*delta, LEFT_BORDER, RIGHT_BORDER)
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

    player.sprite.x = mathUtil.clamp(player.sprite.x + key.axis("Horizontal") * player.speed * delta,LEFT_BORDER,RIGHT_BORDER)
    
    if missile.deployed then
        missile.sprite.y = missile.sprite.y + missile.speed * delta
        toBeRemoved = null
        for invader in invaders
            if invader.sprite.overlaps(missile.sprite) then
                toBeRemoved = invader
                break
            end if
        end for
        if toBeRemoved then
            missile.sprite.y = TOP_BORDER
            invaders.remove invaders.indexOf(toBeRemoved)
            display(4).sprites.remove display(4).sprites.indexOf(toBeRemoved.sprite)
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
    else if key.pressed("space") and not spaceJustPressed then
        missile.sprite.x = player.sprite.x
        missile.sprite.y = player.sprite.y + 4*SCALE
        missile.deployed = true
    end if

    printScore score

    if invaders.len <= 0 then
        print "YOU WON!"
        gameOver = true
        wait 3
    end if

    for invader in invaders   
        if invader.sprite.y <= BOTTOM_OFFSET + 12*SCALE then
            print "YOU LOST!"
            gameOver = true
            wait 3
            break
        end if
    end for

    toBeRemoved = null
    for explosion in explosions
        explosion.elapsedTime = explosion.elapsedTime + delta
        explosion.sprite.image = explosionFrames[mathUtil.clamp(floor(explosion.elapsedTime/(explosion.timeToLive/explosionFrames.len)),0,explosionFrames.len-1)]
        if explosion.elapsedTime >= explosion.timeToLive then
            toBeRemoved = explosion
            break
        end if
    end for

    if toBeRemoved then
        explosions.remove explosions.indexOf(toBeRemoved)
        display(4).sprites.remove display(4).sprites.indexOf(toBeRemoved.sprite)
    end if

    spaceJustPressed = key.pressed("space")
    yield
end while

key.clear
display(3).color = textColorBeforeStart
clear