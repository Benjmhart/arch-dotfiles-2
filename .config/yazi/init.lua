-- station-maintenance beast-arch 83, 2026-10-07: directories entered in yazi (including the
-- file picker) count toward zoxide's ranking, not just ones cd'd to in the shell.
require("zoxide"):setup { update_db = true }
