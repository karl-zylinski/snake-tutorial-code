//+build ignore
package snake

// draw graphics: load sprites, swap out food sprite
// then swap out body parts
// then add body part rotation
// then unload textures

import rl "vendor:raylib"
import "core:math"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
Vec2i :: [2]int
MAX_SNAKE_LENGTH :: GRID_WIDTH * GRID_WIDTH

snake: [MAX_SNAKE_LENGTH]Vec2i
snake_length: int
move_direction: Vec2i
tick_rate: f32 = 0.15
tick_timer := tick_rate
game_over: bool
food_pos: Vec2i

place_food :: proc() {
	occupied: [GRID_WIDTH][GRID_WIDTH]bool

	for i in 0..<snake_length {
		occupied[snake[i].x][snake[i].y] = true
	}

	free_cells := make([dynamic]Vec2i, context.temp_allocator)

	for x in 0..<GRID_WIDTH {
		for y in 0..<GRID_WIDTH {
			if !occupied[x][y] {
				append(&free_cells, Vec2i {x,y})
			}
		}
	}

	if len(free_cells) > 0 {
		food_pos = free_cells[rl.GetRandomValue(0, i32(len(free_cells) - 1))]
	}
}

restart :: proc() {
	start_head_pos := Vec2i{ GRID_WIDTH / 2, GRID_WIDTH / 2}
	snake[0] = start_head_pos
	snake[1] = start_head_pos - {0, 1}
	snake[2] = start_head_pos - {0, 2}
	snake_length = 3
	move_direction = {0, 1}
	game_over = false
	place_food()
}

main :: proc() {
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake")
	rl.SetConfigFlags({.VSYNC_HINT})

	restart()

	food_sprite := rl.LoadTexture("food.png")
	head_sprite := rl.LoadTexture("head.png")
	body_sprite := rl.LoadTexture("body.png")
	tail_sprite := rl.LoadTexture("tail.png")

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

			for i in 1..<snake_length-1 {
				if snake[i] == head_pos {
					game_over = true
				}
			}

			for i in 1..<snake_length {
				cur_pos := snake[i]
				snake[i] = next_part_pos
				next_part_pos = cur_pos
			}

			if head_pos == food_pos {
				snake_length += 1
				snake[snake_length - 1] = next_part_pos
				place_food()
			}

			tick_timer = tick_rate + tick_timer
		}

		rl.BeginDrawing()
		rl.ClearBackground({76, 53, 83, 255})

		camera := rl.Camera2D {
			zoom = f32(WINDOW_SIZE) / CANVAS_SIZE,
		}

		rl.BeginMode2D(camera)
k
		rl.DrawTextureV(food_sprite, {f32(food_pos.x), f32(food_pos.y)}*CELL_SIZE, rl.WHITE)

		for i in 0..<snake_length {
			pos := snake[i]
			part_sprite := body_sprite
			dir: Vec2i

			if i == 0 {
				part_sprite = head_sprite
				dir = pos - snake[i + 1]
			} else if i == snake_length - 1 {
				part_sprite = tail_sprite
				dir = snake[i - 1] - pos
			} else {
				dir = snake[i - 1] - pos
			}

			rot := math.atan2(f32(dir.y), f32(dir.x)) * math.DEG_PER_RAD
			
			source := rl.Rectangle {
				0, 0,
				f32(part_sprite.width), f32(part_sprite.height),
			}

			dest := rl.Rectangle {
				f32(pos.x)*CELL_SIZE + 0.5*CELL_SIZE, f32(pos.y)*CELL_SIZE + 0.5*CELL_SIZE,
				CELL_SIZE, CELL_SIZE,
			}

			rl.DrawTexturePro(part_sprite, source, dest, {CELL_SIZE, CELL_SIZE}*0.5, rot, rl.WHITE)
		}

		if game_over {
			rl.DrawText("Game Over!", 4, 4, 25, rl.RED)
			rl.DrawText("Press Enter to play again", 4, 30, 15, rl.BLACK)
		}

		rl.EndMode2D()
		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.UnloadTexture(body_sprite)
	rl.UnloadTexture(food_sprite)
	rl.UnloadTexture(head_sprite)
	rl.UnloadTexture(tail_sprite)

	rl.CloseWindow()
}