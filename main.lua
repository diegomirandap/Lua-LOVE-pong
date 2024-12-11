local ball, player1, player2
local score1, score2 = 0, 0
local game_state = "playing"
local winner = nil

local function newball()
  local width, height = love.graphics.getDimensions() 
  local x, y = width / 2, height / 2 
  local tam = 10 
  local dirX, dirY = -1, 1 
  local collision_margin = 5

  if love.math.random(2) == 1 then
    dirY = -1 
  else
    dirY = 1 
  end
  
  local ball_update = function(dt, player1, player2)
    while true do
      if game_state == "playing" then
        x = x + dirX * dt * 200
        y = y + dirY * dt * 200
        if y - collision_margin < 0 then
          y = collision_margin 
          dirY = -dirY 
        elseif y + tam + collision_margin > height then
          y = height - tam - collision_margin 
          dirY = -dirY 
        end
        
        if x < player1.x + 10 + collision_margin and x > player1.x - collision_margin
          and y + tam > player1.try() - collision_margin and y < player1.try() + 50 + collision_margin then
          dirX = -dirX 
        end
        if x + tam > player2.x - collision_margin and x + tam < player2.x + 10 + collision_margin
          and y + tam > player2.try() - collision_margin and y < player2.try() + 50 + collision_margin then
          dirX = -dirX 
        end

        if x < 0 then
          score2 = score2 + 1
          if score2 >= 5 then
            winner = 2
            game_state = "game_over"
          else
            x, y = width / 2, height / 2
            dirX = -dirX
            if love.math.random(2) == 1 then
              dirY = -1 
            else
              dirY = 1 
            end
          end
        elseif x + tam > width then
          score1 = score1 + 1
          if score1 >= 5 then
            winner = 1
            game_state = "game_over"
          else
            x, y = width / 2, height / 2 
            dirX = -dirX             
            if love.math.random(2) == 1 then
              dirY = -1 
            else
              dirY = 1
            end
          end
        end
      end
      dt, player1, player2 = coroutine.yield()
    end
  end
      

  return {
    update = coroutine.wrap(ball_update),
    draw = function()
      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("fill", x, y, tam, tam)
    end,
    getX = function()
      return x
    end,
    getY = function()
      return y
    end
  }
end

local function newplayer(num)
  local x, y
  local tam = 10
  local width, height = love.graphics.getDimensions()

  if num == 1 then
    x, y = 30, height / 2 - 50
  else
    x, y = width - tam - 30, height / 2 - 50
  end
  
  local player_update = function(dt)
    while true do
      if game_state == "playing" then
        if num == 1 then
          if love.keyboard.isDown("w") then
            y = y - 200 * dt
          elseif love.keyboard.isDown("s") then
            y = y + 200 * dt
          end
        else
          if love.keyboard.isDown("up") then
            y = y - 200 * dt
          elseif love.keyboard.isDown("down") then
            y = y + 200 * dt
          end
        end

        if y < 0 then
          y = 0
        elseif y + 50 > height then
          y = height - 50
        end
      else
        y = height / 2 - 50
      end
      dt = coroutine.yield()
    end
  end
  return {
    x = x,
    try = function()
      return y
    end,
    update = coroutine.wrap(player_update),
    draw = function()
      love.graphics.rectangle("fill", x, y, tam, 50)
    end
  }
end


function love.load()
  ball = newball()
  player1 = newplayer(1)
  player2 = newplayer(2)
end

function love.update(dt)
  if game_state == "playing" then
    player1.update(dt)
    player2.update(dt)
    ball.update(dt, player1, player2)
  elseif game_state == "game_over" then
    if love.keyboard.isDown("space") then
      score1, score2 = 0, 0
      game_state = "playing"
      winner = nil
      player1.update(dt)
      player2.update(dt)
      ball.update(dt, player1, player2)
    end
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1) 
  love.graphics.print("Player 1: " .. score1, 10, 10)
  love.graphics.print("Player 2: " .. score2, love.graphics.getWidth() - 100, 10)

  player1.draw()
  player2.draw()
  ball.draw()

  if game_state == "game_over" then
    love.graphics.print("Vencedor: Jogador " .. winner, love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2 - 50)
    love.graphics.print("Pressione Espaço para Reiniciar", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2)
  end
end