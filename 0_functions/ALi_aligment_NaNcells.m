[p_value_cell,z_value_cell]=circ_rtest(cell_main.all_directions);
mean_direction=circ_mean(cell_main.all_directions);
cell_main.mean_direction=mean_direction;
cell_main.p_value=p_value_cell;
clear p_value_cell z_value_cell mean_direction