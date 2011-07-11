[winrules]
s0_above_match = (any) & !(title=Top Panel)
s0_below_match = type=Desktop

[resize]
as_mode = 0

[wall]
as_preview_timeout = 0.400000
as_preview_scale = 100
as_border_width = 10
as_outline_color = #333333d9
as_background_gradient_base_color = #cccce6d9
as_background_gradient_highlight_color = #f3f3ffd9
as_background_gradient_shadow_color = #f3f3ffd9
as_thumb_gradient_base_color = #33333359
as_thumb_gradient_highlight_color = #3f3f3f3f
as_thumb_highlight_gradient_base_color = #fffffff3
as_thumb_highlight_gradient_shadow_color = #dfdfdfa6
as_arrow_base_color = #e6e6e6d9
as_arrow_shadow_color = #dcdcdcd9
as_slide_duration = 0.650000

[expo]
as_expo_key = F8
as_zoom_time = 0.250000
as_vp_distance = 0.050000
as_multioutput_mode = 1
as_vp_brightness = 75.000000
as_ground_color1 = #b3b3b3cc
as_ground_color2 = #b3b3b300
as_scale_factor = 0.750000

[resizeinfo]
as_always_show = true
as_gradient_1 = #e1e1e1e1

[thumbnail]
s0_thumb_size = 300
s0_show_delay = 750
s0_border = 10
s0_thumb_color = #000000a5
s0_fade_speed = 0.150000
s0_current_viewport = false
s0_window_like = false
s0_mipmap = true
s0_title_enabled = false
s0_font_bold = false
s0_font_size = 14
s0_font_color = #ffffffff

[staticswitcher]
as_next_key = <Control><Alt>Tab
as_prev_key = <Shift><Control><Alt>Tab
as_next_all_key = <Alt>Tab
as_prev_all_key = <Shift><Alt>Tab
as_next_group_key = <Alt>grave
as_prev_group_key = <Shift><Alt>asciitilde
s0_saturation = 95
s0_brightness = 95
s0_opacity = 80

[animation]
s0_open_effects = animation:Zoom;animation:Fade;animation:Fade;animation:Fade;animation:Fade;animation:Fade;animation:Fade;animation:None;
s0_open_durations = 200;175;175;175;175;175;175;175;
s0_open_matches = (type=Normal | Dialog | ModalDialog | Unknown) & !(name=gnome-screensaver)  & !(class=Google-chrome) & !(class=Chromium-browser) & !(class=Awn-applet) & !(title=volume-control) & !(Stacks_applet.py);(type=Menu | PopupMenu | DropdownMenu);(type=Tooltip | Notification | Utility) & !(name=compiz) & !(title=notify-osd);(type=Normal) & ((class=Google-chrome) |  (class=Chromium-browser));(type=Normal) & (class=Awn-applet);(type=Dock) & (class=Clock-applet);(type=Normal) & (title=volume-control);class=Stacks_applet.py;
s0_open_options = ;;;;;;;;
s0_open_random_effects = animation:Zoom;
s0_close_effects = animation:Zoom;animation:Fade;animation:Fade;animation:Fade;animation:Fade;animation:Fade;animation:Fade;animation:Fade;
s0_close_durations = 200;150;150;150;150;150;150;150;
s0_close_matches = (type=Normal | Dialog | ModalDialog | Unknown) & !(name=gnome-screensaver)  & !(class=Google-chrome) & !(class=Chromium-browser) & !(class=Awn-applet) & !(title=volume-control) & !(class=Stacks_applet.py);(type=Menu | PopupMenu | DropdownMenu);(type=Tooltip | Notification | Utility) & !(name=compiz) & !(title=notify-osd);(type=Normal) & ((class=Google-chrome) |  (class=Chromium-browser));(type=Normal) & (class=Awn-applet);(type=Dock) & (class=Clock-applet);(type=Normal) & (title=volume-control);class=Stacks_applet.py;
s0_close_options = ;;;;;;;;
s0_close_random_effects = animation:Zoom;
s0_minimize_effects = animation:Glide 2;
s0_minimize_durations = 250;
s0_focus_effects = animation:None;
s0_glide2_away_position = -0.400000
s0_glide2_away_angle = -45.000000
s0_horizontal_folds_amp_mult = 1.150000
s0_sidekick_springiness = 0.010000
s0_vacuum_grid_res = 94
s0_time_step = 1

[decoration]
as_shadow_radius = 9.000000

[scale]
as_key_bindings_toggle = false
as_initiate_key = Disabled
as_initiate_all_key = F9
as_initiate_group_key = F10
s0_speed = 2.500000
s0_darken_back = true
s0_opacity = 85
s0_overlay_icon = 1

[core]
as_active_plugins = core;ccp;move;resize;place;decoration;neg;session;workarounds;resizeinfo;png;svg;dbus;imgjpeg;snap;mousepoll;gnomecompat;regex;commands;text;wall;thumbnail;animation;fade;expo;scale;ezoom;staticswitcher;scaleaddon;
as_cursor_theme = DMZ-White
as_show_desktop_key = F11
s0_hsize = 2
s0_vsize = 2
s0_outputs = 1920x1200+1920+0;1920x1080+0+0;

