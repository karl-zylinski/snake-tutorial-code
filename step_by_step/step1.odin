//+build ignore
package snake

import rl "vendor:raylib"

WINDOW_SIZE :: 1000

main :: proc() {
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake")
	rl.SetConfigFlags({.VSYNC_HINT})
	
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({76, 53, 83, 255})
		rl.EndDrawing()
	}
	
	rl.CloseWindow()
}