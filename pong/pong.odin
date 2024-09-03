package pong

import "core:fmt"
import raylib "vendor:raylib"

WINDOW_WIDTH: i32 : 800
WINDOW_HEIGHT: i32 : 450

PLAYER_WIDTH: f32 : 20
PLAYER_HEIGHT: f32 : 100

Paddle :: struct {
	Position: raylib.Vector2,
	Size:     raylib.Vector2,
	Color:    raylib.Color,
	Speed:    f32,
}

Ball :: struct {
	Position: raylib.Vector2,
	Radius:   f32,
	Color:    raylib.Color,
	Velocity: raylib.Vector2,
}

main :: proc() {
	raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Pong")

	playerPaddle := Paddle {
		raylib.Vector2{10, auto_cast (WINDOW_HEIGHT / 2) - auto_cast (PLAYER_HEIGHT / 2)},
		raylib.Vector2{PLAYER_WIDTH, PLAYER_HEIGHT},
		raylib.DARKBLUE,
		.2,
	}

	enemyPaddle := Paddle {
		raylib.Vector2 {
			auto_cast (WINDOW_WIDTH - 10) - PLAYER_WIDTH,
			auto_cast (WINDOW_HEIGHT / 2) - auto_cast (PLAYER_HEIGHT / 2),
		},
		raylib.Vector2{PLAYER_WIDTH, PLAYER_HEIGHT},
		raylib.DARKBLUE,
		.2,
	}

	ball := Ball {
		raylib.Vector2{auto_cast (WINDOW_WIDTH / 2), auto_cast (WINDOW_HEIGHT / 2)},
		10,
		raylib.RED,
		raylib.Vector2{.1, .1},
	}

	for !raylib.WindowShouldClose() {

		updatePaddle(&playerPaddle)
		updateBall(&ball)

		collisionCheck(&ball, &playerPaddle)
		collisionCheck(&ball, &enemyPaddle)

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.WHITE)
		// raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, raylib.LIGHTGRAY)

		drawPaddle(playerPaddle)
		drawPaddle(enemyPaddle)
		drawBall(ball)

		raylib.EndDrawing()
	}
}

drawPaddle :: proc(paddle: Paddle) {
	raylib.DrawRectangleV(paddle.Position, paddle.Size, paddle.Color)
}

drawBall :: proc(ball: Ball) {
	raylib.DrawCircleV(ball.Position, ball.Radius, ball.Color)
}

updatePaddle :: proc(paddle: ^Paddle) {
	if raylib.IsKeyDown(.W) {
		paddle.Position.y -= paddle.Speed
		if paddle.Position.y < 0 {
			paddle.Position.y = 0
		} else if paddle.Position.y > auto_cast (WINDOW_HEIGHT) - PLAYER_HEIGHT {
			paddle.Position.y = auto_cast (WINDOW_HEIGHT) - PLAYER_HEIGHT
		}
	} else if raylib.IsKeyDown(.S) {
		paddle.Position.y += paddle.Speed
		if paddle.Position.y < 0 {
			paddle.Position.y = 0
		} else if paddle.Position.y > auto_cast (WINDOW_HEIGHT) - PLAYER_HEIGHT {
			paddle.Position.y = auto_cast (WINDOW_HEIGHT) - PLAYER_HEIGHT
		}
	}
}

updateBall :: proc(ball: ^Ball) {
	ball.Position += ball.Velocity

	if ball.Position.y >= auto_cast (WINDOW_HEIGHT) || ball.Position.y <= 0 {
		ball.Velocity.y *= -1
	} else if ball.Position.x > auto_cast (WINDOW_WIDTH) || ball.Position.x < 0 {
		ball.Velocity.x *= -1
	}
}


collisionCheck :: proc(ball: ^Ball, paddle: ^Paddle) {
	if raylib.CheckCollisionCircleRec(
		ball.Position,
		ball.Radius,
		raylib.Rectangle{paddle.Position.x, paddle.Position.y, paddle.Size.x, paddle.Size.y},
	) {
		fmt.println("Collision detected")
		ball.Velocity.x *= -1
	}
}
