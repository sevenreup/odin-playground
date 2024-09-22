package pong

import "core:fmt"
import b2 "vendor:box2d"
import raylib "vendor:raylib"

WINDOW_WIDTH: i32 : 800
WINDOW_HEIGHT: i32 : 450
SCALE: f32 : 450

PLAYER_WIDTH: f32 : 20
PLAYER_HEIGHT: f32 : 100

Paddle :: struct {
	Position: raylib.Vector2,
	Size:     raylib.Vector2,
	Color:    raylib.Color,
	Speed:    f32,
	BodyId:   b2.BodyId,
}

Ball :: struct {
	Position: raylib.Vector2,
	Radius:   f32,
	Color:    raylib.Color,
	Velocity: raylib.Vector2,
	BodyId:   b2.BodyId,
}

main :: proc() {
	raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Pong")

	raylib.SetTargetFPS(60)

	worldId := b2.CreateWorld(b2.DefaultWorldDef())

	world_def := b2.DefaultBodyDef()
	world_id := b2.CreateBody(worldId, world_def)
	tile_polygon := b2.MakeSquare(50)

	playerPaddleBodyId := b2.CreateBody(worldId, world_def)
	shape_def := b2.DefaultShapeDef()
	_ = b2.CreatePolygonShape(playerPaddleBodyId, shape_def, tile_polygon)
	playerPaddle := Paddle {
		raylib.Vector2{10, auto_cast (WINDOW_HEIGHT / 2) - auto_cast (PLAYER_HEIGHT / 2)},
		raylib.Vector2{PLAYER_WIDTH, PLAYER_HEIGHT},
		raylib.DARKBLUE,
		.2,
		playerPaddleBodyId,
	}

	enemyPaddle := Paddle {
		raylib.Vector2 {
			auto_cast (WINDOW_WIDTH - 10) - PLAYER_WIDTH,
			auto_cast (WINDOW_HEIGHT / 2) - auto_cast (PLAYER_HEIGHT / 2),
		},
		raylib.Vector2{PLAYER_WIDTH, PLAYER_HEIGHT},
		raylib.DARKBLUE,
		.2,
		b2.BodyId{},
	}

	ball_def := b2.DefaultBodyDef()
	ball_def.type = b2.BodyType.dynamicBody
	ballBodyId := b2.CreateBody(worldId, ball_def)
	_ = b2.CreateCircleShape(ballBodyId, shape_def, {.5, .5})
	ball := Ball {
		raylib.Vector2{auto_cast (WINDOW_WIDTH / 2), auto_cast (WINDOW_HEIGHT / 2)},
		10,
		raylib.RED,
		raylib.Vector2{.1, .1},
		ballBodyId,
	}


	for !raylib.WindowShouldClose() {
		dt := raylib.GetFrameTime()

		b2.World_Step(worldId, dt, 8)

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
	p := b2.Body_GetWorldPoint(ball.BodyId, {-0.5, 0.5})
	radians := b2.Body_GetPosition(ball.BodyId)

	ps := convertWorldToSreen(p)

	fmt.println("p: ", p, ps)

	raylib.DrawCircleV(ps, ball.Radius, ball.Color)
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

convertWorldToSreen :: proc(p: b2.Vec2) -> raylib.Vector2 {
	return {
		SCALE * p.x + 0.5 * auto_cast (WINDOW_WIDTH),
		0.5 * auto_cast (WINDOW_HEIGHT) - SCALE * p.y,
	}
}
