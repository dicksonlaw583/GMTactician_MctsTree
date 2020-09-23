///@desc Draw tree progress
if (instance_exists(mctsDaemon)) {
	draw_healthbar(x, y, x+100, y+16, 100*mctsDaemon.progress, c_black, c_red, c_lime, 0, true, true);
}
