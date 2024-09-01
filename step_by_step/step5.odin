//+build ignore
package snake

// add game_over and wall crash check, then add if to stop game when crashed
// then add restart proc and use in both places
// finally add game over text

import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
Vec2i :: [2]int
MAX_SNAKE_LENGTH :: GRID_WIDTH*GRID_WIDTH

snake: [MAX_SNAKE_LENGTH]Vec2i
snake_length: int
move_direction: Vec2i
tick_rate: f32 = 0.15
tick_timer := tick_rate
game_over: bool

restart :: proc() {
	start_head_pos := Vec2i{ GRID_WIDTH / 2, GRID_WIDTH / 2}
	snake[0] = start_head_pos
	snake[1] = start_head_pos - {0, 1}
	snake[2] = start_head_pos - {0, 2}
	snake_length = 3
	move_direction = {0, 1}
	game_over = false
}

main :: proc() {
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake")
	rl.SetConfigFlags({.VSYNC_HINT})

	restart()

	for !rl.WindowShouldClose() {
		if rl.IsKeyDown(.UP) {
			move_direction = {0, -1}
		}

		if rl.IsKeyDown(.DOWN) {
			move_direction = {0, 1}
		}

		if rl.IsKeyDown(.LEFT) {
			move_direction = {-1, 0}
		}

		if rl.IsKeyDown(.RIGHT) {
			move_direction = {1, 0}
		}

		if game_over {
			if rl.IsKeyPressed(.ENTER) {
				restart()
			}
		} else {
			tick_timer -= rl.GetFrameTime()
		}

		if tick_timer <= 0 {
			next_part_pos := snake[0]
			snake[0] = snake[0] + move_direction
			head_pos := snake[0]

			if head_pos.x < 0 || head_pos.y < 0 || head_pos.x >= GRID_WIDTH || head_pos.y >= GRID_WIDTH {
				game_over = true
			}

			for i in 1..<snake_length {
				cur_pos := snake[i]
				snake[i] = next_part_pos
				next_part_pos = cur_pos
			}

			tick_timer = tick_rate + tick_timer
		}

		rl.BeginDrawing()
		rl.ClearBackground({76, 53, 83, 255})

		camera := rl.Camera2D {
			zoom = f32(WINDOW_SIZE) / CANVAS_SIZE,
		}

		rl.BeginMode2D(camera)

		for i in 0..<snake_length {
			snake_part_rect := rl.Rectangle {
				f32(snake[i].x)*CELL_SIZE,
				f32(snake[i].y)*CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE,
			}

			rl.DrawRectangleRec(snake_part_rect, rl.WHITE)
		}

		if game_over {
			rl.DrawText("Game Over!", 4, 4, 25, rl.RED)
			rl.DrawText("Press Enter to play again", 4, 30, 15, rl.BLACK)
		}

		rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}