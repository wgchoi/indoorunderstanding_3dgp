function [pp] = line_projection(p0, dl, pl)

d = dot(dl, p0 - pl) / dot(dl, dl);
pp = pl + d * dl;

end