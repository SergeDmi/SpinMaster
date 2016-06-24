function opt = spin_options

% Provide the options to analyse
%
% They are loaded by spin_load_option.m,
% which also check for a local 'spin_options.m'
%
%

opt.radius           = 110;
opt.visual           = 0;
opt.local_background = 0;
opt.flatten_image    = 0;
opt.auto_center      = 0;
opt.use_mask         = 0;
opt.mask             = [];
opt.time_shift       = 0;
opt.catch_exceptions = 1;
opt.time_interval    = 1;
opt.time_start       = 0;
opt.contour_analysis = 0;
opt.max_bipo_ang     = pi/6.0;
opt.seg_number       = 3;
opt.max_polarity     = 10;

return