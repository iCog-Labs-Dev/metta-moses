!(register-module ../../metta-moses-reduction)
!(import! &self compress-tree)
!(import! &self helpers)

!(compressTree (AND (AND (AND x1 x2) (OR y1 y2)) c) NONE ())

